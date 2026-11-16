import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/models/QueuedScan.dart';
import 'package:eventpass/models/ScannerBundle.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/repository/scanner_repository.dart';
import 'package:eventpass/utils/exceptions.dart';

final apiScannerNotifierProvider = StateNotifierProvider.autoDispose<ApiScannerNotifier, ApiStatesModel>(
  (ref) => ApiScannerNotifier(ref),
  name: 'apiScannerNotifierProvider',
);

/// Events the user can scan for; null until loaded.
final staffEventsProvider = StateProvider<List<Event>?>((ref) => null, name: 'staffEventsProvider');

/// The bundle the scanner screen is verifying against.
final scannerBundleProvider = StateProvider<ScannerBundle?>((ref) => null, name: 'scannerBundleProvider');

/// True when [scannerBundleProvider] came from the device because the server was unreachable.
final bundleFromCacheProvider = StateProvider<bool>((ref) => false, name: 'bundleFromCacheProvider');

/// Scans for the open event, newest first.
final scanHistoryProvider = StateProvider<List<QueuedScan>>((ref) => const [], name: 'scanHistoryProvider');

/// The most recent scan, shown as the big result card.
final lastScanProvider = StateProvider<QueuedScan?>((ref) => null, name: 'lastScanProvider');

enum SyncStatus { idle, syncing, offline, failed }

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle, name: 'syncStatusProvider');
final lastSyncedAtProvider = StateProvider<DateTime?>((ref) => null, name: 'lastSyncedAtProvider');

/// Scans the server overruled since the scanner was opened (ticket used at another gate first).
final overruledCountProvider = StateProvider<int>((ref) => 0, name: 'overruledCountProvider');

/// Gate scanning. Only loading the event list and opening an event use
/// States.LOADING (the blocking spinner); scanning and syncing never block
/// the camera, and report through their own providers.
class ApiScannerNotifier extends StateNotifier<ApiStatesModel> {
  ApiScannerNotifier(this._ref) : super(ApiStatesModel(States.IDLE, '', null));

  final Ref _ref;
  bool _syncing = false;

  Future<void> apiGetStaffEvents({bool silent = false}) async {
    try {
      if (!silent) state = ApiStatesModel(States.LOADING, '', null);
      final events = await _ref.read(scannerRepository).apiGetStaffEvents();
      _ref.read(staffEventsProvider.notifier).state = events;
      state = ApiStatesModel(States.IDLE, '', null);
    } on DataException catch (ex) {
      if (silent && ex.statusCode != 401) {
        state = ApiStatesModel(States.IDLE, '', null);
        return;
      }
      _setError(ex);
    } catch (ex) {
      state = ApiStatesModel(States.ERROR, ex.toString(), null);
    }
  }

  /// Loads the event's bundle (fresh, or saved when offline) and its scan history.
  Future<void> apiOpenScanner(String eventId) async {
    try {
      state = ApiStatesModel(States.LOADING, '', null);
      _ref.read(lastScanProvider.notifier).state = null;
      _ref.read(overruledCountProvider.notifier).state = 0;
      final result = await _ref.read(scannerRepository).apiLoadBundle(eventId);
      _ref.read(scannerBundleProvider.notifier).state = result.bundle;
      _ref.read(bundleFromCacheProvider.notifier).state = result.fromCache;
      await _refreshHistory(eventId);
      state = ApiStatesModel(States.DATA, '', result.bundle);
      if (!result.fromCache) await apiSync();
    } on DataException catch (ex) {
      _setError(ex);
    } catch (ex) {
      state = ApiStatesModel(States.ERROR, ex.toString(), null);
    }
  }

  /// Verifies a QR code offline and queues it, then tries to sync in the background.
  Future<QueuedScan?> scan(String token) async {
    final bundle = _ref.read(scannerBundleProvider);
    if (bundle == null) return null;
    final scan = await _ref.read(scannerRepository).scan(bundle, token);
    _ref.read(lastScanProvider.notifier).state = scan;
    await _refreshHistory(bundle.event!.id!);
    unawaited(apiSync());
    return scan;
  }

  /// Uploads queued scans, then refreshes the bundle so new revocations reach the gate.
  Future<void> apiSync() async {
    final bundle = _ref.read(scannerBundleProvider);
    if (bundle == null || _syncing) return;
    final eventId = bundle.event!.id!;
    _syncing = true;
    _ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
    try {
      final repo = _ref.read(scannerRepository);
      final summary = await repo.apiSyncScans(eventId);
      if (summary.overruled > 0) _ref.read(overruledCountProvider.notifier).update((n) => n + summary.overruled);

      final fresh = await repo.apiLoadBundle(eventId);
      if (!fresh.fromCache) {
        _ref.read(scannerBundleProvider.notifier).state = fresh.bundle;
        _ref.read(bundleFromCacheProvider.notifier).state = false;
      }
      await _refreshHistory(eventId);
      _ref.read(lastSyncedAtProvider.notifier).state = DateTime.now();
      _ref.read(syncStatusProvider.notifier).state = fresh.fromCache ? SyncStatus.offline : SyncStatus.idle;
    } on DataException catch (ex) {
      if (ex.statusCode == 401) {
        state = ApiStatesModel(States.SESSIONEXPIRED, ex.toString(), null);
      }
      _ref.read(syncStatusProvider.notifier).state = ex.statusCode == 0 ? SyncStatus.offline : SyncStatus.failed;
    } catch (_) {
      _ref.read(syncStatusProvider.notifier).state = SyncStatus.failed;
    } finally {
      _syncing = false;
    }
  }

  Future<void> _refreshHistory(String eventId) async {
    _ref.read(scanHistoryProvider.notifier).state = await _ref.read(scannerRepository).history(eventId);
  }

  void _setError(DataException ex) {
    state = ex.statusCode == 401
        ? ApiStatesModel(States.SESSIONEXPIRED, ex.toString(), null)
        : ApiStatesModel(States.ERROR, ex.toString(), null);
  }
}
