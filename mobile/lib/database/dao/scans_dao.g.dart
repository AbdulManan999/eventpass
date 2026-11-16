// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scans_dao.dart';

// ignore_for_file: type=lint
mixin _$ScansDaoMixin on DatabaseAccessor<MyDatabase> {
  $ScanQueueTableTable get scanQueueTable => attachedDatabase.scanQueueTable;
  $ScannerBundlesTableTable get scannerBundlesTable =>
      attachedDatabase.scannerBundlesTable;
  ScansDaoManager get managers => ScansDaoManager(this);
}

class ScansDaoManager {
  final _$ScansDaoMixin _db;
  ScansDaoManager(this._db);
  $$ScanQueueTableTableTableManager get scanQueueTable =>
      $$ScanQueueTableTableTableManager(
        _db.attachedDatabase,
        _db.scanQueueTable,
      );
  $$ScannerBundlesTableTableTableManager get scannerBundlesTable =>
      $$ScannerBundlesTableTableTableManager(
        _db.attachedDatabase,
        _db.scannerBundlesTable,
      );
}
