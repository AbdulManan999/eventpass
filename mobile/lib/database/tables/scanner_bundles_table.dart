import 'package:drift/drift.dart';
import 'package:eventpass/models/ScannerBundle.dart';

/// The last scanner bundle downloaded per event, so a gate phone that loses
/// its connection (or restarts) can keep verifying tickets.
@UseRowClass(ScannerBundle, constructor: 'fromDb')
class ScannerBundlesTable extends Table {
  TextColumn get eventId => text()();
  TextColumn get bundleJson => text()();

  @override
  Set<Column> get primaryKey => {eventId};
}
