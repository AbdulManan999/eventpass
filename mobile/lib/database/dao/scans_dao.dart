import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:eventpass/database/my_database.dart';
import 'package:eventpass/database/tables/scan_queue_table.dart';
import 'package:eventpass/database/tables/scanner_bundles_table.dart';
import 'package:eventpass/models/QueuedScan.dart';
import 'package:eventpass/models/ScannerBundle.dart';

part 'scans_dao.g.dart';

@DriftAccessor(tables: [ScanQueueTable, ScannerBundlesTable])
class ScansDao extends DatabaseAccessor<MyDatabase> with _$ScansDaoMixin implements IScansTable {
  ScansDao(super.db);

  @override
  Future<void> saveBundle(String eventId, ScannerBundle bundle) => into(scannerBundlesTable).insertOnConflictUpdate(
        ScannerBundlesTableCompanion.insert(eventId: eventId, bundleJson: jsonEncode(bundle.toJson())),
      );

  @override
  Future<ScannerBundle?> getBundle(String eventId) =>
      (select(scannerBundlesTable)..where((t) => t.eventId.equals(eventId))).getSingleOrNull();

  @override
  Future<void> insertScan(QueuedScan scan) => into(scanQueueTable).insert(
        ScanQueueTableCompanion.insert(
          id: scan.id,
          eventId: scan.eventId,
          token: scan.token,
          scannedAt: scan.scannedAt,
          localResult: scan.localResult,
          method: Value(scan.method),
          ticketId: Value(scan.ticketId),
          holderName: Value(scan.holderName),
        ),
      );

  @override
  Future<List<QueuedScan>> scansForEvent(String eventId) => (select(scanQueueTable)
        ..where((t) => t.eventId.equals(eventId))
        ..orderBy([(t) => OrderingTerm.desc(t.scannedAt)]))
      .get();

  @override
  Future<List<QueuedScan>> pendingScans(String eventId) => (select(scanQueueTable)
        ..where((t) => t.eventId.equals(eventId) & t.serverResult.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.scannedAt)]))
      .get();

  @override
  Future<bool> wasAdmittedHere(String eventId, String ticketId) async {
    final rows = await (select(scanQueueTable)
          ..where((t) => t.eventId.equals(eventId) & t.ticketId.equals(ticketId) & t.localResult.equals(ScanResults.accepted))
          ..limit(1))
        .get();
    return rows.isNotEmpty;
  }

  @override
  Future<void> markSynced(String id, String serverResult, String syncedAt) =>
      (update(scanQueueTable)..where((t) => t.id.equals(id))).write(
        ScanQueueTableCompanion(serverResult: Value(serverResult), syncedAt: Value(syncedAt)),
      );

  @override
  Future<int> pendingCount() async {
    final count = scanQueueTable.id.count();
    final row = await (selectOnly(scanQueueTable)
          ..addColumns([count])
          ..where(scanQueueTable.serverResult.isNull()))
        .getSingle();
    return row.read(count) ?? 0;
  }

  @override
  Future<void> deleteAll() => transaction(() async {
        await delete(scanQueueTable).go();
        await delete(scannerBundlesTable).go();
      });
}

abstract class IScansTable {
  Future<void> saveBundle(String eventId, ScannerBundle bundle);

  Future<ScannerBundle?> getBundle(String eventId);

  Future<void> insertScan(QueuedScan scan);

  /// Newest first.
  Future<List<QueuedScan>> scansForEvent(String eventId);

  /// Not yet uploaded, oldest first.
  Future<List<QueuedScan>> pendingScans(String eventId);

  /// True if this phone already let [ticketId] in (before or after sync).
  Future<bool> wasAdmittedHere(String eventId, String ticketId);

  Future<void> markSynced(String id, String serverResult, String syncedAt);

  /// Scans not yet uploaded, across all events.
  Future<int> pendingCount();

  /// Logout: drops queued scans and bundles.
  Future<void> deleteAll();
}
