import 'package:eventpass/models/Event.dart';

/// `GET events` returns a bare JSON array of events.
class EventsResponse {
  EventsResponse({List<Event>? events}) {
    _events = events ?? [];
  }

  EventsResponse.fromJson(dynamic json) {
    _events = (json as List).map((e) => Event.fromJson(e)).toList();
  }

  List<Event> _events = [];

  List<Event> get events => _events;
}
