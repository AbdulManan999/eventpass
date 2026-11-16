import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/models/response/events/EventsResponse.dart';
import 'package:eventpass/network/environment_config.dart';
import 'package:eventpass/repository/network_repository.dart';
import 'package:eventpass/utils/exceptions.dart';

final eventsRepository = Provider((ref) => _EventsRepository(ref));

class _EventsRepository {
  _EventsRepository(this.ref);

  final Ref ref;

  Future<EventsResponse> apiGetEvents() async {
    try {
      final Response response = await ref.read(networkRepositoryProvider).getRequest(
            EnvironmentConfig.EVENTS,
            UrlSuffix.GET,
            false,
          );
      return EventsResponse.fromJson(response.data);
    } on DataException {
      rethrow;
    } catch (error) {
      throw DataException(message: error.toString(), statusCode: 0);
    }
  }
}
