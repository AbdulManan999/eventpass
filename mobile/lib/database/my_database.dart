import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:eventpass/database/dao/tickets_dao.dart';
import 'package:eventpass/database/tables/tickets_table.dart';
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
  tables: [TicketsTable],
  daos: [TicketsDao],
)
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  /// For tests: `MyDatabase.forTesting(NativeDatabase.memory())`.
  MyDatabase.forTesting(super.executor);

  /// Bump whenever a table is added/changed, and add a step in [migration].
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Example: if (from < 2) await m.createTable(scansTable);
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
