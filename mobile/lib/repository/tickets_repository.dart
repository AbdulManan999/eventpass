import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/database/my_database.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/models/response/tickets/MyTicketsResponse.dart';
import 'package:eventpass/network/environment_config.dart';
import 'package:eventpass/repository/network_repository.dart';
import 'package:eventpass/utils/exceptions.dart';

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
}
