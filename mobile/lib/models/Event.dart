import 'Venue.dart';

class Event {
  Event({String? id, String? title, Venue? venue, String? startsAt, String? endsAt, int? capacity}) {
    _id = id;
    _title = title;
    _venue = venue;
    _startsAt = startsAt;
    _endsAt = endsAt;
    _capacity = capacity;
  }

  Event.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _venue = json['venue'] != null ? Venue.fromJson(json['venue']) : null;
    _startsAt = json['startsAt'];
    _endsAt = json['endsAt'];
    _capacity = (json['capacity'] as num?)?.toInt();
  }

  String? _id;
  String? _title;
  Venue? _venue;
  String? _startsAt;
  String? _endsAt;
  int? _capacity;

  String? get id => _id;
  String? get title => _title;
  Venue? get venue => _venue;

  /// ISO-8601, UTC.
  String? get startsAt => _startsAt;

  /// ISO-8601, UTC.
  String? get endsAt => _endsAt;
  int? get capacity => _capacity;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    if (_venue != null) map['venue'] = _venue?.toJson();
    map['startsAt'] = _startsAt;
    map['endsAt'] = _endsAt;
    map['capacity'] = _capacity;
    return map;
  }
}
