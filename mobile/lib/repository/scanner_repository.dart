import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:eventpass/database/my_database.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/models/QueuedScan.dart';
import 'package:eventpass/models/ScannerBundle.dart';
import 'package:eventpass/network/environment_config.dart';
import 'package:eventpass/repository/network_repository.dart';
import 'package:eventpass/utils/exceptions.dart';
import 'package:eventpass/utils/ticket_verifier.dart';
import 'package:eventpass/utils/utils.dart';

final scannerRepository = Provider((ref) => _ScannerRepository(ref));

class BundleResult {
  BundleResult(this.bundle, {required this.fromCache});

  final ScannerBundle bundle;

  /// True when the server was unreachable and the last saved bundle is used.
  final bool fromCache;
}

class SyncSummary {
  SyncSummary({required this.uploaded, required this.overruled});

  final int uploaded;

  /// Scans this phone admitted that the server rejected (used at another gate first).
  final int overruled;
}

/// Gate-staff scanning. Tickets are verified on the phone with the event's
/// public key, every scan is written to Drift first, and queued scans are
/// uploaded whenever there is a connection. The server has the final say.
class _ScannerRepository {
  _ScannerRepository(this.ref);

  final Ref ref;
  static const _uuid = Uuid();

  /// The server accepts at most this many scans per request.
  static const _syncBatch = 500;

  /// Longer QR contents can't be valid tickets; truncating keeps the batch valid.
  static const _maxTokenLength = 2000;

  Future<List<Event>> apiGetStaffEvents() async {
    try {
      final Response response = await ref.read(networkRepositoryProvider).getRequest(
            EnvironmentConfig.STAFF_EVENTS,
            UrlSuffix.GET,
            true,
          );
      return (response.data as List).map(Event.fromJson).toList();
    } on DataException {
      rethrow;
    } catch (error) {
      throw DataException(message: error.toString(), statusCode: 0);
    }
  }

  /// Downloads a fresh bundle and saves it. When the server can't be reached,
  /// returns the last saved bundle so scanning keeps working offline.
  Future<BundleResult> apiLoadBundle(String eventId) async {
    final dao = ref.read(databaseProvider).scansDao;
    try {
      final Response response = await ref.read(networkRepositoryProvider).getRequest(
            EnvironmentConfig.SCANNER_BUNDLE(eventId),
            UrlSuffix.GET,
            true,
          );
      final bundle = ScannerBundle.fromJson(response.data);
      await dao.saveBundle(eventId, bundle);
      return BundleResult(bundle, fromCache: false);
    } on DataException catch (e) {
      if (e.statusCode != 0) rethrow;
      final cached = await dao.getBundle(eventId);
      if (cached == null) rethrow;
      return BundleResult(cached, fromCache: true);
    } catch (error) {
      throw DataException(message: error.toString(), statusCode: 0);
    }
  }

  /// Verifies [rawToken] offline and records the scan. Never touches the network.
  Future<QueuedScan> scan(ScannerBundle bundle, String rawToken, {DateTime? now}) async {
    final dao = ref.read(databaseProvider).scansDao;
    final eventId = bundle.event!.id!;
    final token = rawToken.length > _maxTokenLength ? rawToken.substring(0, _maxTokenLength) : rawToken;

    final verifier = TicketVerifier(
      publicKeyPem: bundle.publicKey!,
      eventId: eventId,
      revokedTicketIds: bundle.revokedTicketIds,
    );
    final verified = await verifier.verify(token);
    var result = verified.result;
    final ticketId = verified.claims?.ticketId;
    if (result == ScanResults.accepted && await dao.wasAdmittedHere(eventId, ticketId!)) {
      result = ScanResults.duplicate;
    }

    final scan = QueuedScan.fromDb(
      id: _uuid.v4(),
      eventId: eventId,
      token: token,
      scannedAt: (now ?? DateTime.now()).toUtc().toIso8601String(),
      localResult: result,
      ticketId: ticketId,
      holderName: verified.claims?.holderName,
    );
    await dao.insertScan(scan);
    return scan;
  }

  /// Uploads every unsynced scan for [eventId] and stores the server's result.
  /// Safe to repeat: scan ids are generated here, so re-sent scans aren't doubled.
  Future<SyncSummary> apiSyncScans(String eventId) async {
    final dao = ref.read(databaseProvider).scansDao;
    final pending = await dao.pendingScans(eventId);
    if (pending.isEmpty) return SyncSummary(uploaded: 0, overruled: 0);

    try {
      final gate = await Utils.getGateName();
      final byId = {for (final s in pending) s.id: s};
      var overruled = 0;
      for (var i = 0; i < pending.length; i += _syncBatch) {
        final batch = pending.sublist(i, (i + _syncBatch).clamp(0, pending.length));
        final Response response = await ref.read(networkRepositoryProvider).getRequest(
              EnvironmentConfig.SYNC_SCANS(eventId),
              UrlSuffix.POST,
              true,
              data: {
                'deviceId': gate,
                'scans': [
                  for (final s in batch) {'id': s.id, 'token': s.token, 'scannedAt': s.scannedAt},
                ],
              },
            );
        final syncedAt = DateTime.now().toUtc().toIso8601String();
        for (final r in (response.data['results'] as List)) {
          final id = r['id'] as String, result = r['result'] as String;
          await dao.markSynced(id, result, syncedAt);
          if (byId[id]?.localResult == ScanResults.accepted && result != ScanResults.accepted) overruled++;
        }
      }
      return SyncSummary(uploaded: pending.length, overruled: overruled);
    } on DataException {
      rethrow;
    } catch (error) {
      throw DataException(message: error.toString(), statusCode: 0);
    }
  }

  Future<List<QueuedScan>> history(String eventId) => ref.read(databaseProvider).scansDao.scansForEvent(eventId);
}
