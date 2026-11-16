import 'package:drift/drift.dart';
import 'package:eventpass/models/QueuedScan.dart';

/// Every scan made on this phone, synced or not. Rows with a null
/// [serverResult] are still waiting to be uploaded.
@UseRowClass(QueuedScan, constructor: 'fromDb')
class ScanQueueTable extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text()();
  TextColumn get token => text()();
  TextColumn get scannedAt => text()();
  TextColumn get localResult => text()();
  TextColumn get ticketId => text().nullable()();
  TextColumn get holderName => text().nullable()();
  TextColumn get serverResult => text().nullable()();
  TextColumn get syncedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
