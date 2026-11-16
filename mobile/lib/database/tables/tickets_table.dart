import 'package:drift/drift.dart';
import 'package:eventpass/models/Ticket.dart';

/// Local copy of the user's tickets so QR codes open with no connection.
/// @UseRowClass maps rows straight onto [Ticket] via `Ticket.fromDb`
/// (constructor parameter names MUST equal the column getter names).
@UseRowClass(Ticket, constructor: 'fromDb')
class TicketsTable extends Table {
  TextColumn get id => text()();
  TextColumn get status => text()();
  TextColumn get issuedAt => text()();
  TextColumn get token => text()();

  /// The ticket's event, stored as JSON — it is only ever read back whole.
  TextColumn get eventJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
