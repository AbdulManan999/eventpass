// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tickets_dao.dart';

// ignore_for_file: type=lint
mixin _$TicketsDaoMixin on DatabaseAccessor<MyDatabase> {
  $TicketsTableTable get ticketsTable => attachedDatabase.ticketsTable;
  TicketsDaoManager get managers => TicketsDaoManager(this);
}

class TicketsDaoManager {
  final _$TicketsDaoMixin _db;
  TicketsDaoManager(this._db);
  $$TicketsTableTableTableManager get ticketsTable =>
      $$TicketsTableTableTableManager(_db.attachedDatabase, _db.ticketsTable);
}
