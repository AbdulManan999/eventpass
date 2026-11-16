import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:eventpass/database/my_database.dart';
import 'package:eventpass/repository/network_repository.dart';
import 'package:eventpass/repository/tickets_repository.dart';
import 'package:eventpass/utils/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers every request with [respond], or simulates "no network" when it is null.
class FakeAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final r = respond;
    if (r == null) {
      throw DioException.connectionError(requestOptions: options, reason: 'offline');
    }
    return r(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(Object body, {int status = 200}) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

Map<String, dynamic> ticketJson(String id, {String status = 'valid'}) => {
      'id': id,
      'status': status,
      'issuedAt': '2026-11-16T10:00:00.000Z',
      'token': 'EP1.payload-$id.signature',
      'event': {
        'id': 'event-1',
        'title': 'Lahore Flutter Meetup',
        'venue': {'name': 'Arfa Tower', 'latitude': 31.47, 'longitude': 74.34, 'geofenceRadiusM': 200},
        'startsAt': '2026-12-01T13:00:00.000Z',
        'endsAt': '2026-12-01T16:00:00.000Z',
        'capacity': 100,
      },
    };

void main() {
  late FakeAdapter adapter;
  late MyDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
    adapter = FakeAdapter();
    db = MyDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        clientProvider.overrideWithValue(Dio(BaseOptions(baseUrl: 'http://api.test/'))..httpClientAdapter = adapter),
        databaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('online: returns server tickets, sends the bearer token and refreshes the cache', () async {
    adapter.respond = (_) => json([ticketJson('t1'), ticketJson('t2')]);

    final result = await container.read(ticketsRepository).apiGetMyTickets();

    expect(result.fromCache, isFalse);
    expect(result.tickets.map((t) => t.id), ['t1', 't2']);
    expect(adapter.requests.single.headers['Authorization'], 'Bearer test-token');
    expect((await db.ticketsDao.getAllData()).map((t) => t.id), unorderedEquals(['t1', 't2']));
  });

  test('offline: falls back to cached tickets, QR token and event intact', () async {
    adapter.respond = (_) => json([ticketJson('t1')]);
    await container.read(ticketsRepository).apiGetMyTickets();

    adapter.respond = null; // airplane mode
    final result = await container.read(ticketsRepository).apiGetMyTickets();

    expect(result.fromCache, isTrue);
    expect(result.tickets.single.token, 'EP1.payload-t1.signature');
    expect(result.tickets.single.event?.title, 'Lahore Flutter Meetup');
    expect(result.tickets.single.event?.venue?.geofenceRadiusM, 200);
  });

  test('offline with an empty cache surfaces the network error', () async {
    adapter.respond = null;
    expect(
      container.read(ticketsRepository).apiGetMyTickets(),
      throwsA(isA<DataException>().having((e) => e.statusCode, 'statusCode', 0)),
    );
  });

  test('a 401 is never masked by the cache, so the session-expired flow runs', () async {
    adapter.respond = (_) => json([ticketJson('t1')]);
    await container.read(ticketsRepository).apiGetMyTickets();

    adapter.respond = (_) => json({'error': 'unauthorized', 'message': 'Missing or invalid access token'}, status: 401);
    expect(
      container.read(ticketsRepository).apiGetMyTickets(),
      throwsA(isA<DataException>().having((e) => e.statusCode, 'statusCode', 401)),
    );
  });

  test('a refresh drops tickets the user no longer holds from the cache', () async {
    adapter.respond = (_) => json([ticketJson('t1'), ticketJson('t2')]);
    await container.read(ticketsRepository).apiGetMyTickets();

    adapter.respond = (_) => json([ticketJson('t2', status: 'revoked')]);
    await container.read(ticketsRepository).apiGetMyTickets();

    final cached = await db.ticketsDao.getAllData();
    expect(cached.map((t) => t.id), ['t2']);
    expect(cached.single.isRevoked, isTrue);
  });

  test('claiming a ticket posts a JSON body and caches the new ticket', () async {
    adapter.respond = (_) => json(ticketJson('t9'), status: 201);

    final ticket = await container.read(ticketsRepository).apiClaimTicket('event-1');

    expect(ticket.id, 't9');
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.path, 'events/event-1/tickets');
    expect(adapter.requests.single.data, isNotNull);
    expect((await db.ticketsDao.getAllData()).single.id, 't9');
  });

  test('a sold-out event surfaces the server message', () async {
    adapter.respond = (_) => json({'error': 'sold_out', 'message': 'This event is at full capacity'}, status: 409);
    expect(
      container.read(ticketsRepository).apiClaimTicket('event-1'),
      throwsA(isA<DataException>().having((e) => e.toString(), 'message', 'This event is at full capacity')),
    );
  });
}
