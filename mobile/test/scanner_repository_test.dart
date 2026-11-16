import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:eventpass/database/my_database.dart';
import 'package:eventpass/models/QueuedScan.dart';
import 'package:eventpass/models/ScannerBundle.dart';
import 'package:eventpass/repository/network_repository.dart';
import 'package:eventpass/repository/scanner_repository.dart';
import 'package:eventpass/utils/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

/// Answers every request with [respond], or simulates "no network" when it is null.
class FakeAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final r = respond;
    if (r == null) throw DioException.connectionError(requestOptions: options, reason: 'offline');
    return r(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(Object body, {int status = 200}) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

Map<String, dynamic> bundleJson({List<String> revoked = const []}) => {
      'event': {
        'id': eventId,
        'title': 'Lahore Tech Conference',
        'category': 'tech',
        'venue': {'name': 'Arfa Tower', 'latitude': 31.47, 'longitude': 74.34, 'geofenceRadiusM': 250},
        'startsAt': '2026-11-16T10:00:00.000Z',
        'endsAt': '2026-11-16T18:00:00.000Z',
        'capacity': 300,
      },
      'publicKey': nodePublicKeyPem,
      'revokedTicketIds': revoked,
      'generatedAt': '2026-11-16T09:00:00.000Z',
    };

/// Server sync handler: accepts each ticket once, like the real backend.
ResponseBody Function(RequestOptions) fakeServer({Set<String>? alreadyUsedElsewhere}) {
  final accepted = <String>{...?alreadyUsedElsewhere};
  return (o) {
    if (o.path.endsWith('scanner-bundle')) return json(bundleJson());
    final scans = (o.data['scans'] as List).cast<Map<String, dynamic>>();
    return json({
      'results': [
        for (final s in scans)
          {
            'id': s['id'],
            'result': s['token'] == nodeToken ? (accepted.add(ticketId) ? 'accepted' : 'duplicate') : 'invalid',
          },
      ],
    });
  };
}

void main() {
  late FakeAdapter adapter;
  late MyDatabase db;
  late ProviderContainer container;
  late ScannerBundle bundle;

  setUp(() {
    SharedPreferences.setMockInitialValues({'token': 'staff-token', 'gate_name': 'North gate'});
    adapter = FakeAdapter();
    db = MyDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        clientProvider.overrideWithValue(Dio(BaseOptions(baseUrl: 'http://api.test/'))..httpClientAdapter = adapter),
        databaseProvider.overrideWithValue(db),
      ],
    );
    bundle = ScannerBundle.fromJson(bundleJson());
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  _ScannerRepositoryHandle repo() => _ScannerRepositoryHandle(container);

  test('scans offline: admits a valid ticket once, then flags the repeat as a duplicate', () async {
    adapter.respond = null; // no network at all

    final first = await repo().scan(bundle, nodeToken);
    final second = await repo().scan(bundle, nodeToken);
    final forged = await repo().scan(bundle, foreignToken);

    expect(first.localResult, ScanResults.accepted);
    expect(first.holderName, 'Ayesha Khan');
    expect(second.localResult, ScanResults.duplicate);
    expect(forged.localResult, ScanResults.invalid);
    expect(adapter.requests, isEmpty, reason: 'scanning must never touch the network');
    expect(await db.scansDao.pendingCount(), 3);
  });

  test('rejects tickets revoked in the bundle', () async {
    final revokedBundle = ScannerBundle.fromJson(bundleJson(revoked: [ticketId]));
    expect((await repo().scan(revokedBundle, nodeToken)).localResult, ScanResults.revoked);
  });

  test('sync uploads queued scans with the gate name and stores server results', () async {
    adapter.respond = null;
    await repo().scan(bundle, nodeToken);
    await repo().scan(bundle, foreignToken);

    adapter.respond = fakeServer();
    final summary = await repo().apiSyncScans(eventId);

    expect(summary.uploaded, 2);
    expect(summary.overruled, 0);
    final request = adapter.requests.single;
    expect(request.path, 'events/$eventId/scans/sync');
    expect(request.data['deviceId'], 'North gate');
    expect(request.headers['Authorization'], 'Bearer staff-token');
    expect(await db.scansDao.pendingCount(), 0);

    // Nothing left to send, so a second sync makes no request.
    await repo().apiSyncScans(eventId);
    expect(adapter.requests, hasLength(1));
  });

  test('a failed upload keeps scans queued for the next attempt', () async {
    await repo().scan(bundle, nodeToken);
    adapter.respond = null;
    await expectLater(
      repo().apiSyncScans(eventId),
      throwsA(isA<DataException>().having((e) => e.statusCode, 'statusCode', 0)),
    );
    expect(await db.scansDao.pendingCount(), 1);
  });

  test('reports scans the server overruled because another gate admitted the ticket first', () async {
    adapter.respond = null;
    await repo().scan(bundle, nodeToken);

    adapter.respond = fakeServer(alreadyUsedElsewhere: {ticketId});
    final summary = await repo().apiSyncScans(eventId);

    expect(summary.overruled, 1);
    final scan = (await repo().history(eventId)).single;
    expect(scan.localResult, ScanResults.accepted);
    expect(scan.serverResult, ScanResults.duplicate);
    expect(scan.overruled, isTrue);
  });

  test('uses the saved bundle when the server is unreachable', () async {
    adapter.respond = fakeServer();
    final online = await repo().apiLoadBundle(eventId);
    expect(online.fromCache, isFalse);

    adapter.respond = null;
    final offline = await repo().apiLoadBundle(eventId);
    expect(offline.fromCache, isTrue);
    expect(offline.bundle.publicKey, nodePublicKeyPem);
    expect(offline.bundle.event?.title, 'Lahore Tech Conference');
  });

  test('without a saved bundle, an offline open surfaces the network error', () async {
    adapter.respond = null;
    await expectLater(repo().apiLoadBundle(eventId), throwsA(isA<DataException>()));
  });
}

/// Thin wrapper so tests read naturally (the repository class is private).
class _ScannerRepositoryHandle {
  _ScannerRepositoryHandle(this._c);

  final ProviderContainer _c;

  Future<QueuedScan> scan(ScannerBundle b, String token) => _c.read(scannerRepository).scan(b, token);
  Future<SyncSummary> apiSyncScans(String id) => _c.read(scannerRepository).apiSyncScans(id);
  Future<BundleResult> apiLoadBundle(String id) => _c.read(scannerRepository).apiLoadBundle(id);
  Future<List<QueuedScan>> history(String id) => _c.read(scannerRepository).history(id);
}
