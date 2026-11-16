import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/database/my_database.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/models/response/tickets/CheckInResponse.dart';
import 'package:eventpass/models/response/tickets/MyTicketsResponse.dart';
import 'package:eventpass/network/environment_config.dart';
import 'package:eventpass/repository/network_repository.dart';
import 'package:eventpass/utils/exceptions.dart';
import 'package:eventpass/utils/location_service.dart';

final ticketsRepository = Provider((ref) => _TicketsRepository(ref));

class _TicketsRepository {
  _TicketsRepository(this.ref);

  final Ref ref;

  /// Network first; every successful fetch refreshes the local cache.
  /// When the server can't be reached (statusCode 0), falls back to the cache
  /// so tickets still open at a venue with no signal.
  Future<MyTicketsResponse> apiGetMyTickets() async {
    final dao = ref.read(databaseProvider).ticketsDao;
    try {
      final Response response = await ref.read(networkRepositoryProvider).getRequest(
            EnvironmentConfig.MY_TICKETS,
            UrlSuffix.GET,
            true,
          );
      final result = MyTicketsResponse.fromJson(response.data);
      await dao.replaceAll(result.tickets);
      return result;
    } on DataException catch (e) {
      if (e.statusCode != 0) rethrow;
      final cached = await dao.getAllData();
      if (cached.isEmpty) rethrow;
      return MyTicketsResponse(tickets: cached, fromCache: true);
    } catch (error) {
      throw DataException(message: error.toString(), statusCode: 0);
    }
  }

  /// Claims a ticket for [eventId]. The server returns the existing ticket if
  /// the user already holds one, so retrying is safe.
  Future<Ticket> apiClaimTicket(String eventId) async {
    try {
      final Response response = await ref.read(networkRepositoryProvider).getRequest(
            EnvironmentConfig.CLAIM_TICKET(eventId),
            UrlSuffix.POST,
            true,
            // Fastify rejects an empty body sent as application/json.
            data: <String, dynamic>{},
          );
      final ticket = Ticket.fromJson(response.data);
      await ref.read(databaseProvider).ticketsDao.upsert(ticket);
      return ticket;
    } on DataException {
      rethrow;
    } catch (error) {
      throw DataException(message: error.toString(), statusCode: 0);
    }
  }

  /// Geofenced self check-in: takes one GPS fix and lets the server decide
  /// whether the phone is inside the venue's radius. On success the cached
  /// ticket is marked as checked in.
  Future<CheckInResponse> apiSelfCheckIn(Ticket ticket) async {
    try {
      final fix = await ref.read(locationServiceProvider).currentFix();
      final Response response = await ref.read(networkRepositoryProvider).getRequest(
            EnvironmentConfig.SELF_CHECK_IN(ticket.event!.id!),
            UrlSuffix.POST,
            true,
            data: {
              'latitude': fix.latitude,
              'longitude': fix.longitude,
              'accuracyM': fix.accuracyM,
              'isMocked': fix.isMocked,
            },
          );
      final result = CheckInResponse.fromJson(response.data);
      await ref.read(databaseProvider).ticketsDao.upsert(ticket.checkedIn(result.checkedInAt!, result.method ?? 'geofence'));
      return result;
    } on LocationException catch (e) {
      // statusCode -1: not an HTTP error; the message is a code the screen translates.
      throw DataException(message: e.code, statusCode: -1);
    } on DataException {
      rethrow;
    } catch (error) {
      throw DataException(message: error.toString(), statusCode: 0);
    }
  }
}
