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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    issuedAt,
    token,
    eventJson,
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
  final Value<int> rowid;
  const TicketsTableCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.token = const Value.absent(),
    this.eventJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TicketsTableCompanion.insert({
    required String id,
    required String status,
    required String issuedAt,
    required String token,
    required String eventJson,
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
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (token != null) 'token': token,
      if (eventJson != null) 'event_json': eventJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TicketsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? status,
    Value<String>? issuedAt,
    Value<String>? token,
    Value<String>? eventJson,
    Value<int>? rowid,
  }) {
    return TicketsTableCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      issuedAt: issuedAt ?? this.issuedAt,
      token: token ?? this.token,
      eventJson: eventJson ?? this.eventJson,
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MyDatabase extends GeneratedDatabase {
  _$MyDatabase(QueryExecutor e) : super(e);
  $MyDatabaseManager get managers => $MyDatabaseManager(this);
  late final $TicketsTableTable ticketsTable = $TicketsTableTable(this);
  late final TicketsDao ticketsDao = TicketsDao(this as MyDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [ticketsTable];
}

typedef $$TicketsTableTableCreateCompanionBuilder =
    TicketsTableCompanion Function({
      required String id,
      required String status,
      required String issuedAt,
      required String token,
      required String eventJson,
      Value<int> rowid,
    });
typedef $$TicketsTableTableUpdateCompanionBuilder =
    TicketsTableCompanion Function({
      Value<String> id,
      Value<String> status,
      Value<String> issuedAt,
      Value<String> token,
      Value<String> eventJson,
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
                Value<int> rowid = const Value.absent(),
              }) => TicketsTableCompanion(
                id: id,
                status: status,
                issuedAt: issuedAt,
                token: token,
                eventJson: eventJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String status,
                required String issuedAt,
                required String token,
                required String eventJson,
                Value<int> rowid = const Value.absent(),
              }) => TicketsTableCompanion.insert(
                id: id,
                status: status,
                issuedAt: issuedAt,
                token: token,
                eventJson: eventJson,
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

class $MyDatabaseManager {
  final _$MyDatabase _db;
  $MyDatabaseManager(this._db);
  $$TicketsTableTableTableManager get ticketsTable =>
      $$TicketsTableTableTableManager(_db, _db.ticketsTable);
}
