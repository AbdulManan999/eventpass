import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:eventpass/database/my_database.dart';
import 'package:eventpass/database/tables/tickets_table.dart';
import 'package:eventpass/models/Ticket.dart';

part 'tickets_dao.g.dart';

@DriftAccessor(tables: [TicketsTable])
class TicketsDao extends DatabaseAccessor<MyDatabase> with _$TicketsDaoMixin implements ITicketsTable {
  TicketsDao(super.db);

  @override
  Future<List<Ticket>> getAllData() => select(ticketsTable).get();

  @override
  Future<void> replaceAll(List<Ticket> tickets) => transaction(() async {
        await delete(ticketsTable).go();
        await batch((b) => b.insertAll(ticketsTable, tickets.map(_toCompanion)));
      });

  @override
  Future<void> upsert(Ticket ticket) => into(ticketsTable).insertOnConflictUpdate(_toCompanion(ticket));

  @override
  Future<int> deleteAll() => delete(ticketsTable).go();

  TicketsTableCompanion _toCompanion(Ticket t) => TicketsTableCompanion.insert(
        id: t.id ?? '',
        status: t.status ?? 'valid',
        issuedAt: t.issuedAt ?? '',
        token: t.token ?? '',
        eventJson: jsonEncode(t.event?.toJson() ?? {}),
      );
}

/// Every DAO implements an interface listing its operations.
abstract class ITicketsTable {
  Future<List<Ticket>> getAllData();

  /// Makes the cache an exact copy of [tickets] (drops tickets no longer held).
  Future<void> replaceAll(List<Ticket> tickets);

  Future<void> upsert(Ticket ticket);

  Future<int> deleteAll();
}
