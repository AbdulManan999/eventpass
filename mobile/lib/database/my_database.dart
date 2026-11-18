import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:eventpass/database/dao/scans_dao.dart';
import 'package:eventpass/database/dao/tickets_dao.dart';
import 'package:eventpass/database/tables/scan_queue_table.dart';
import 'package:eventpass/database/tables/scanner_bundles_table.dart';
import 'package:eventpass/database/tables/tickets_table.dart';
import 'package:eventpass/models/QueuedScan.dart';
import 'package:eventpass/models/ScannerBundle.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/utils/constants.dart';

part 'my_database.g.dart';

/// THE one database provider. Import it from here — never redeclare
/// `databaseProvider` in a provider file (that creates a second DB instance).
final databaseProvider = Provider<MyDatabase>((ref) {
  final db = MyDatabase();
  ref.onDispose(db.close);
  return db;
});

@DriftDatabase(
  tables: [TicketsTable, ScanQueueTable, ScannerBundlesTable],
  daos: [TicketsDao, ScansDao],
)
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  /// For tests: `MyDatabase.forTesting(NativeDatabase.memory())`.
  MyDatabase.forTesting(super.executor);

  /// Bump whenever a table is added/changed, and add a step in [migration].
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: check-in status on tickets, and gate-staff scanning.
            await m.addColumn(ticketsTable, ticketsTable.checkedInAt);
            await m.addColumn(ticketsTable, ticketsTable.checkInMethod);
            await m.createTable(scanQueueTable);
            await m.createTable(scannerBundlesTable);
          }
          if (from == 2) {
            // v3: NFC check-in. (A v1 upgrade already created the table with this column.)
            await m.addColumn(scanQueueTable, scanQueueTable.method);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, Constants.dbName));
    return NativeDatabase.createInBackground(file);
  });
}
