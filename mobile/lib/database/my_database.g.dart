// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_database.dart';

// ignore_for_file: type=lint
class $TicketsTableTable extends TicketsTable
    with TableInfo<$TicketsTableTable, Ticket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<String> issuedAt = GeneratedColumn<String>(
    'issued_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventJsonMeta = const VerificationMeta(
    'eventJson',
  );
  @override
  late final GeneratedColumn<String> eventJson = GeneratedColumn<String>(
    'event_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedInAtMeta = const VerificationMeta(
    'checkedInAt',
  );
  @override
  late final GeneratedColumn<String> checkedInAt = GeneratedColumn<String>(
    'checked_in_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkInMethodMeta = const VerificationMeta(
    'checkInMethod',
  );
  @override
  late final GeneratedColumn<String> checkInMethod = GeneratedColumn<String>(
    'check_in_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    issuedAt,
    token,
    eventJson,
    checkedInAt,
    checkInMethod,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tickets_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ticket> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_issuedAtMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('event_json')) {
      context.handle(
        _eventJsonMeta,
        eventJson.isAcceptableOrUnknown(data['event_json']!, _eventJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_eventJsonMeta);
    }
    if (data.containsKey('checked_in_at')) {
      context.handle(
        _checkedInAtMeta,
        checkedInAt.isAcceptableOrUnknown(
          data['checked_in_at']!,
          _checkedInAtMeta,
        ),
      );
    }
    if (data.containsKey('check_in_method')) {
      context.handle(
        _checkInMethodMeta,
        checkInMethod.isAcceptableOrUnknown(
          data['check_in_method']!,
          _checkInMethodMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ticket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ticket.fromDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issued_at'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      )!,
      eventJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_json'],
      )!,
      checkedInAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checked_in_at'],
      ),
      checkInMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_in_method'],
      ),
    );
  }

  @override
  $TicketsTableTable createAlias(String alias) {
    return $TicketsTableTable(attachedDatabase, alias);
  }
}

class TicketsTableCompanion extends UpdateCompanion<Ticket> {
  final Value<String> id;
  final Value<String> status;
  final Value<String> issuedAt;
  final Value<String> token;
  final Value<String> eventJson;
  final Value<String?> checkedInAt;
  final Value<String?> checkInMethod;
  final Value<int> rowid;
  const TicketsTableCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.token = const Value.absent(),
    this.eventJson = const Value.absent(),
    this.checkedInAt = const Value.absent(),
    this.checkInMethod = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TicketsTableCompanion.insert({
    required String id,
    required String status,
    required String issuedAt,
    required String token,
    required String eventJson,
    this.checkedInAt = const Value.absent(),
    this.checkInMethod = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       issuedAt = Value(issuedAt),
       token = Value(token),
       eventJson = Value(eventJson);
  static Insertable<Ticket> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<String>? issuedAt,
    Expression<String>? token,
    Expression<String>? eventJson,
    Expression<String>? checkedInAt,
    Expression<String>? checkInMethod,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (token != null) 'token': token,
      if (eventJson != null) 'event_json': eventJson,
      if (checkedInAt != null) 'checked_in_at': checkedInAt,
      if (checkInMethod != null) 'check_in_method': checkInMethod,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TicketsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? status,
    Value<String>? issuedAt,
    Value<String>? token,
    Value<String>? eventJson,
    Value<String?>? checkedInAt,
    Value<String?>? checkInMethod,
    Value<int>? rowid,
  }) {
    return TicketsTableCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      issuedAt: issuedAt ?? this.issuedAt,
      token: token ?? this.token,
      eventJson: eventJson ?? this.eventJson,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkInMethod: checkInMethod ?? this.checkInMethod,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<String>(issuedAt.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (eventJson.present) {
      map['event_json'] = Variable<String>(eventJson.value);
    }
    if (checkedInAt.present) {
      map['checked_in_at'] = Variable<String>(checkedInAt.value);
    }
    if (checkInMethod.present) {
      map['check_in_method'] = Variable<String>(checkInMethod.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketsTableCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('token: $token, ')
          ..write('eventJson: $eventJson, ')
          ..write('checkedInAt: $checkedInAt, ')
          ..write('checkInMethod: $checkInMethod, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanQueueTableTable extends ScanQueueTable
    with TableInfo<$ScanQueueTableTable, QueuedScan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scannedAtMeta = const VerificationMeta(
    'scannedAt',
  );
  @override
  late final GeneratedColumn<String> scannedAt = GeneratedColumn<String>(
    'scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localResultMeta = const VerificationMeta(
    'localResult',
  );
  @override
  late final GeneratedColumn<String> localResult = GeneratedColumn<String>(
    'local_result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('qr'),
  );
  static const VerificationMeta _ticketIdMeta = const VerificationMeta(
    'ticketId',
  );
  @override
  late final GeneratedColumn<String> ticketId = GeneratedColumn<String>(
    'ticket_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _holderNameMeta = const VerificationMeta(
    'holderName',
  );
  @override
  late final GeneratedColumn<String> holderName = GeneratedColumn<String>(
    'holder_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverResultMeta = const VerificationMeta(
    'serverResult',
  );
  @override
  late final GeneratedColumn<String> serverResult = GeneratedColumn<String>(
    'server_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    token,
    scannedAt,
    localResult,
    method,
    ticketId,
    holderName,
    serverResult,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_queue_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueuedScan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(
        _scannedAtMeta,
        scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    if (data.containsKey('local_result')) {
      context.handle(
        _localResultMeta,
        localResult.isAcceptableOrUnknown(
          data['local_result']!,
          _localResultMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localResultMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('ticket_id')) {
      context.handle(
        _ticketIdMeta,
        ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta),
      );
    }
    if (data.containsKey('holder_name')) {
      context.handle(
        _holderNameMeta,
        holderName.isAcceptableOrUnknown(data['holder_name']!, _holderNameMeta),
      );
    }
    if (data.containsKey('server_result')) {
      context.handle(
        _serverResultMeta,
        serverResult.isAcceptableOrUnknown(
          data['server_result']!,
          _serverResultMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueuedScan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueuedScan.fromDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      )!,
      scannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scanned_at'],
      )!,
      localResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_result'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      ticketId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_id'],
      ),
      holderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holder_name'],
      ),
      serverResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_result'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ScanQueueTableTable createAlias(String alias) {
    return $ScanQueueTableTable(attachedDatabase, alias);
  }
}

class ScanQueueTableCompanion extends UpdateCompanion<QueuedScan> {
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> token;
  final Value<String> scannedAt;
  final Value<String> localResult;
  final Value<String> method;
  final Value<String?> ticketId;
  final Value<String?> holderName;
  final Value<String?> serverResult;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const ScanQueueTableCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.token = const Value.absent(),
    this.scannedAt = const Value.absent(),
    this.localResult = const Value.absent(),
    this.method = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.holderName = const Value.absent(),
    this.serverResult = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanQueueTableCompanion.insert({
    required String id,
    required String eventId,
    required String token,
    required String scannedAt,
    required String localResult,
    this.method = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.holderName = const Value.absent(),
    this.serverResult = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       token = Value(token),
       scannedAt = Value(scannedAt),
       localResult = Value(localResult);
  static Insertable<QueuedScan> custom({
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? token,
    Expression<String>? scannedAt,
    Expression<String>? localResult,
    Expression<String>? method,
    Expression<String>? ticketId,
    Expression<String>? holderName,
    Expression<String>? serverResult,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (token != null) 'token': token,
      if (scannedAt != null) 'scanned_at': scannedAt,
      if (localResult != null) 'local_result': localResult,
      if (method != null) 'method': method,
      if (ticketId != null) 'ticket_id': ticketId,
      if (holderName != null) 'holder_name': holderName,
      if (serverResult != null) 'server_result': serverResult,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanQueueTableCompanion copyWith({
    Value<String>? id,
    Value<String>? eventId,
    Value<String>? token,
    Value<String>? scannedAt,
    Value<String>? localResult,
    Value<String>? method,
    Value<String?>? ticketId,
    Value<String?>? holderName,
    Value<String?>? serverResult,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ScanQueueTableCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      token: token ?? this.token,
      scannedAt: scannedAt ?? this.scannedAt,
      localResult: localResult ?? this.localResult,
      method: method ?? this.method,
      ticketId: ticketId ?? this.ticketId,
      holderName: holderName ?? this.holderName,
      serverResult: serverResult ?? this.serverResult,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<String>(scannedAt.value);
    }
    if (localResult.present) {
      map['local_result'] = Variable<String>(localResult.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<String>(ticketId.value);
    }
    if (holderName.present) {
      map['holder_name'] = Variable<String>(holderName.value);
    }
    if (serverResult.present) {
      map['server_result'] = Variable<String>(serverResult.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('token: $token, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('localResult: $localResult, ')
          ..write('method: $method, ')
          ..write('ticketId: $ticketId, ')
          ..write('holderName: $holderName, ')
          ..write('serverResult: $serverResult, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScannerBundlesTableTable extends ScannerBundlesTable
    with TableInfo<$ScannerBundlesTableTable, ScannerBundle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScannerBundlesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bundleJsonMeta = const VerificationMeta(
    'bundleJson',
  );
  @override
  late final GeneratedColumn<String> bundleJson = GeneratedColumn<String>(
    'bundle_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [eventId, bundleJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scanner_bundles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScannerBundle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('bundle_json')) {
      context.handle(
        _bundleJsonMeta,
        bundleJson.isAcceptableOrUnknown(data['bundle_json']!, _bundleJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_bundleJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  ScannerBundle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannerBundle.fromDb(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      bundleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bundle_json'],
      )!,
    );
  }

  @override
  $ScannerBundlesTableTable createAlias(String alias) {
    return $ScannerBundlesTableTable(attachedDatabase, alias);
  }
}

class ScannerBundlesTableCompanion extends UpdateCompanion<ScannerBundle> {
  final Value<String> eventId;
  final Value<String> bundleJson;
  final Value<int> rowid;
  const ScannerBundlesTableCompanion({
    this.eventId = const Value.absent(),
    this.bundleJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScannerBundlesTableCompanion.insert({
    required String eventId,
    required String bundleJson,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       bundleJson = Value(bundleJson);
  static Insertable<ScannerBundle> custom({
    Expression<String>? eventId,
    Expression<String>? bundleJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (bundleJson != null) 'bundle_json': bundleJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScannerBundlesTableCompanion copyWith({
    Value<String>? eventId,
    Value<String>? bundleJson,
    Value<int>? rowid,
  }) {
    return ScannerBundlesTableCompanion(
      eventId: eventId ?? this.eventId,
      bundleJson: bundleJson ?? this.bundleJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (bundleJson.present) {
      map['bundle_json'] = Variable<String>(bundleJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScannerBundlesTableCompanion(')
          ..write('eventId: $eventId, ')
          ..write('bundleJson: $bundleJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MyDatabase extends GeneratedDatabase {
  _$MyDatabase(QueryExecutor e) : super(e);
  $MyDatabaseManager get managers => $MyDatabaseManager(this);
  late final $TicketsTableTable ticketsTable = $TicketsTableTable(this);
  late final $ScanQueueTableTable scanQueueTable = $ScanQueueTableTable(this);
  late final $ScannerBundlesTableTable scannerBundlesTable =
      $ScannerBundlesTableTable(this);
  late final TicketsDao ticketsDao = TicketsDao(this as MyDatabase);
  late final ScansDao scansDao = ScansDao(this as MyDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ticketsTable,
    scanQueueTable,
    scannerBundlesTable,
  ];
}

typedef $$TicketsTableTableCreateCompanionBuilder =
    TicketsTableCompanion Function({
      required String id,
      required String status,
      required String issuedAt,
      required String token,
      required String eventJson,
      Value<String?> checkedInAt,
      Value<String?> checkInMethod,
      Value<int> rowid,
    });
typedef $$TicketsTableTableUpdateCompanionBuilder =
    TicketsTableCompanion Function({
      Value<String> id,
      Value<String> status,
      Value<String> issuedAt,
      Value<String> token,
      Value<String> eventJson,
      Value<String?> checkedInAt,
      Value<String?> checkInMethod,
      Value<int> rowid,
    });

class $$TicketsTableTableFilterComposer
    extends Composer<_$MyDatabase, $TicketsTableTable> {
  $$TicketsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventJson => $composableBuilder(
    column: $table.eventJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkedInAt => $composableBuilder(
    column: $table.checkedInAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkInMethod => $composableBuilder(
    column: $table.checkInMethod,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TicketsTableTableOrderingComposer
    extends Composer<_$MyDatabase, $TicketsTableTable> {
  $$TicketsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventJson => $composableBuilder(
    column: $table.eventJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkedInAt => $composableBuilder(
    column: $table.checkedInAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkInMethod => $composableBuilder(
    column: $table.checkInMethod,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TicketsTableTableAnnotationComposer
    extends Composer<_$MyDatabase, $TicketsTableTable> {
  $$TicketsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get eventJson =>
      $composableBuilder(column: $table.eventJson, builder: (column) => column);

  GeneratedColumn<String> get checkedInAt => $composableBuilder(
    column: $table.checkedInAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checkInMethod => $composableBuilder(
    column: $table.checkInMethod,
    builder: (column) => column,
  );
}

class $$TicketsTableTableTableManager
    extends
        RootTableManager<
          _$MyDatabase,
          $TicketsTableTable,
          Ticket,
          $$TicketsTableTableFilterComposer,
          $$TicketsTableTableOrderingComposer,
          $$TicketsTableTableAnnotationComposer,
          $$TicketsTableTableCreateCompanionBuilder,
          $$TicketsTableTableUpdateCompanionBuilder,
          (Ticket, BaseReferences<_$MyDatabase, $TicketsTableTable, Ticket>),
          Ticket,
          PrefetchHooks Function()
        > {
  $$TicketsTableTableTableManager(_$MyDatabase db, $TicketsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> issuedAt = const Value.absent(),
                Value<String> token = const Value.absent(),
                Value<String> eventJson = const Value.absent(),
                Value<String?> checkedInAt = const Value.absent(),
                Value<String?> checkInMethod = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketsTableCompanion(
                id: id,
                status: status,
                issuedAt: issuedAt,
                token: token,
                eventJson: eventJson,
                checkedInAt: checkedInAt,
                checkInMethod: checkInMethod,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String status,
                required String issuedAt,
                required String token,
                required String eventJson,
                Value<String?> checkedInAt = const Value.absent(),
                Value<String?> checkInMethod = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketsTableCompanion.insert(
                id: id,
                status: status,
                issuedAt: issuedAt,
                token: token,
                eventJson: eventJson,
                checkedInAt: checkedInAt,
                checkInMethod: checkInMethod,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TicketsTableTable, Ticket>(table),
                  BaseReferences<_$MyDatabase, $TicketsTableTable, Ticket>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TicketsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$MyDatabase,
      $TicketsTableTable,
      Ticket,
      $$TicketsTableTableFilterComposer,
      $$TicketsTableTableOrderingComposer,
      $$TicketsTableTableAnnotationComposer,
      $$TicketsTableTableCreateCompanionBuilder,
      $$TicketsTableTableUpdateCompanionBuilder,
      (Ticket, BaseReferences<_$MyDatabase, $TicketsTableTable, Ticket>),
      Ticket,
      PrefetchHooks Function()
    >;
typedef $$ScanQueueTableTableCreateCompanionBuilder =
    ScanQueueTableCompanion Function({
      required String id,
      required String eventId,
      required String token,
      required String scannedAt,
      required String localResult,
      Value<String> method,
      Value<String?> ticketId,
      Value<String?> holderName,
      Value<String?> serverResult,
      Value<String?> syncedAt,
      Value<int> rowid,
    });
typedef $$ScanQueueTableTableUpdateCompanionBuilder =
    ScanQueueTableCompanion Function({
      Value<String> id,
      Value<String> eventId,
      Value<String> token,
      Value<String> scannedAt,
      Value<String> localResult,
      Value<String> method,
      Value<String?> ticketId,
      Value<String?> holderName,
      Value<String?> serverResult,
      Value<String?> syncedAt,
      Value<int> rowid,
    });

class $$ScanQueueTableTableFilterComposer
    extends Composer<_$MyDatabase, $ScanQueueTableTable> {
  $$ScanQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localResult => $composableBuilder(
    column: $table.localResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticketId => $composableBuilder(
    column: $table.ticketId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holderName => $composableBuilder(
    column: $table.holderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverResult => $composableBuilder(
    column: $table.serverResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanQueueTableTableOrderingComposer
    extends Composer<_$MyDatabase, $ScanQueueTableTable> {
  $$ScanQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localResult => $composableBuilder(
    column: $table.localResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticketId => $composableBuilder(
    column: $table.ticketId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holderName => $composableBuilder(
    column: $table.holderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverResult => $composableBuilder(
    column: $table.serverResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanQueueTableTableAnnotationComposer
    extends Composer<_$MyDatabase, $ScanQueueTableTable> {
  $$ScanQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);

  GeneratedColumn<String> get localResult => $composableBuilder(
    column: $table.localResult,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get ticketId =>
      $composableBuilder(column: $table.ticketId, builder: (column) => column);

  GeneratedColumn<String> get holderName => $composableBuilder(
    column: $table.holderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverResult => $composableBuilder(
    column: $table.serverResult,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ScanQueueTableTableTableManager
    extends
        RootTableManager<
          _$MyDatabase,
          $ScanQueueTableTable,
          QueuedScan,
          $$ScanQueueTableTableFilterComposer,
          $$ScanQueueTableTableOrderingComposer,
          $$ScanQueueTableTableAnnotationComposer,
          $$ScanQueueTableTableCreateCompanionBuilder,
          $$ScanQueueTableTableUpdateCompanionBuilder,
          (
            QueuedScan,
            BaseReferences<_$MyDatabase, $ScanQueueTableTable, QueuedScan>,
          ),
          QueuedScan,
          PrefetchHooks Function()
        > {
  $$ScanQueueTableTableTableManager(_$MyDatabase db, $ScanQueueTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> token = const Value.absent(),
                Value<String> scannedAt = const Value.absent(),
                Value<String> localResult = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String?> ticketId = const Value.absent(),
                Value<String?> holderName = const Value.absent(),
                Value<String?> serverResult = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanQueueTableCompanion(
                id: id,
                eventId: eventId,
                token: token,
                scannedAt: scannedAt,
                localResult: localResult,
                method: method,
                ticketId: ticketId,
                holderName: holderName,
                serverResult: serverResult,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventId,
                required String token,
                required String scannedAt,
                required String localResult,
                Value<String> method = const Value.absent(),
                Value<String?> ticketId = const Value.absent(),
                Value<String?> holderName = const Value.absent(),
                Value<String?> serverResult = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScanQueueTableCompanion.insert(
                id: id,
                eventId: eventId,
                token: token,
                scannedAt: scannedAt,
                localResult: localResult,
                method: method,
                ticketId: ticketId,
                holderName: holderName,
                serverResult: serverResult,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanQueueTableTable, QueuedScan>(table),
                  BaseReferences<
                    _$MyDatabase,
                    $ScanQueueTableTable,
                    QueuedScan
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$MyDatabase,
      $ScanQueueTableTable,
      QueuedScan,
      $$ScanQueueTableTableFilterComposer,
      $$ScanQueueTableTableOrderingComposer,
      $$ScanQueueTableTableAnnotationComposer,
      $$ScanQueueTableTableCreateCompanionBuilder,
      $$ScanQueueTableTableUpdateCompanionBuilder,
      (
        QueuedScan,
        BaseReferences<_$MyDatabase, $ScanQueueTableTable, QueuedScan>,
      ),
      QueuedScan,
      PrefetchHooks Function()
    >;
typedef $$ScannerBundlesTableTableCreateCompanionBuilder =
    ScannerBundlesTableCompanion Function({
      required String eventId,
      required String bundleJson,
      Value<int> rowid,
    });
typedef $$ScannerBundlesTableTableUpdateCompanionBuilder =
    ScannerBundlesTableCompanion Function({
      Value<String> eventId,
      Value<String> bundleJson,
      Value<int> rowid,
    });

class $$ScannerBundlesTableTableFilterComposer
    extends Composer<_$MyDatabase, $ScannerBundlesTableTable> {
  $$ScannerBundlesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bundleJson => $composableBuilder(
    column: $table.bundleJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScannerBundlesTableTableOrderingComposer
    extends Composer<_$MyDatabase, $ScannerBundlesTableTable> {
  $$ScannerBundlesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bundleJson => $composableBuilder(
    column: $table.bundleJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScannerBundlesTableTableAnnotationComposer
    extends Composer<_$MyDatabase, $ScannerBundlesTableTable> {
  $$ScannerBundlesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get bundleJson => $composableBuilder(
    column: $table.bundleJson,
    builder: (column) => column,
  );
}

class $$ScannerBundlesTableTableTableManager
    extends
        RootTableManager<
          _$MyDatabase,
          $ScannerBundlesTableTable,
          ScannerBundle,
          $$ScannerBundlesTableTableFilterComposer,
          $$ScannerBundlesTableTableOrderingComposer,
          $$ScannerBundlesTableTableAnnotationComposer,
          $$ScannerBundlesTableTableCreateCompanionBuilder,
          $$ScannerBundlesTableTableUpdateCompanionBuilder,
          (
            ScannerBundle,
            BaseReferences<
              _$MyDatabase,
              $ScannerBundlesTableTable,
              ScannerBundle
            >,
          ),
          ScannerBundle,
          PrefetchHooks Function()
        > {
  $$ScannerBundlesTableTableTableManager(
    _$MyDatabase db,
    $ScannerBundlesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScannerBundlesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScannerBundlesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScannerBundlesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> bundleJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScannerBundlesTableCompanion(
                eventId: eventId,
                bundleJson: bundleJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String bundleJson,
                Value<int> rowid = const Value.absent(),
              }) => ScannerBundlesTableCompanion.insert(
                eventId: eventId,
                bundleJson: bundleJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScannerBundlesTableTable, ScannerBundle>(table),
                  BaseReferences<
                    _$MyDatabase,
                    $ScannerBundlesTableTable,
                    ScannerBundle
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScannerBundlesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$MyDatabase,
      $ScannerBundlesTableTable,
      ScannerBundle,
      $$ScannerBundlesTableTableFilterComposer,
      $$ScannerBundlesTableTableOrderingComposer,
      $$ScannerBundlesTableTableAnnotationComposer,
      $$ScannerBundlesTableTableCreateCompanionBuilder,
      $$ScannerBundlesTableTableUpdateCompanionBuilder,
      (
        ScannerBundle,
        BaseReferences<_$MyDatabase, $ScannerBundlesTableTable, ScannerBundle>,
      ),
      ScannerBundle,
      PrefetchHooks Function()
    >;

class $MyDatabaseManager {
  final _$MyDatabase _db;
  $MyDatabaseManager(this._db);
  $$TicketsTableTableTableManager get ticketsTable =>
      $$TicketsTableTableTableManager(_db, _db.ticketsTable);
  $$ScanQueueTableTableTableManager get scanQueueTable =>
      $$ScanQueueTableTableTableManager(_db, _db.scanQueueTable);
  $$ScannerBundlesTableTableTableManager get scannerBundlesTable =>
      $$ScannerBundlesTableTableTableManager(_db, _db.scannerBundlesTable);
}
