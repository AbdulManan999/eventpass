import 'Venue.dart';

class Event {
  Event({
    String? id,
    String? title,
    String? description,
    String? category,
    Venue? venue,
    String? startsAt,
    String? endsAt,
    int? capacity,
    int? ticketsIssued,
    String? role,
  }) {
    _id = id;
    _title = title;
    _description = description;
    _category = category;
    _venue = venue;
    _startsAt = startsAt;
    _endsAt = endsAt;
    _capacity = capacity;
    _ticketsIssued = ticketsIssued;
    _role = role;
  }

  Event.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _description = json['description'];
    _category = json['category'];
    _venue = json['venue'] != null ? Venue.fromJson(json['venue']) : null;
    _startsAt = json['startsAt'];
    _endsAt = json['endsAt'];
    _capacity = (json['capacity'] as num?)?.toInt();
    _ticketsIssued = (json['ticketsIssued'] as num?)?.toInt();
    _role = json['role'];
  }

  /// Self check-in opens this long before the start (matches the backend).
  static const selfCheckInOpensBefore = Duration(hours: 2);

  String? _id;
  String? _title;
  String? _description;
  String? _category;
  Venue? _venue;
  String? _startsAt;
  String? _endsAt;
  int? _capacity;
  int? _ticketsIssued;
  String? _role;

  String? get id => _id;
  String? get title => _title;
  String get description => _description ?? '';

  /// tech, music, sports, business or community.
  String get category => _category ?? 'tech';
  Venue? get venue => _venue;

  /// ISO-8601, UTC.
  String? get startsAt => _startsAt;

  /// ISO-8601, UTC.
  String? get endsAt => _endsAt;
  int? get capacity => _capacity;
  int? get ticketsIssued => _ticketsIssued;

  /// Only set on staff events: `organizer` or `staff`.
  String? get role => _role;

  DateTime? get startsAtDate => DateTime.tryParse(_startsAt ?? '');
  DateTime? get endsAtDate => DateTime.tryParse(_endsAt ?? '');

  int? get spotsLeft => (_capacity != null && _ticketsIssued != null) ? (_capacity! - _ticketsIssued!).clamp(0, _capacity!) : null;

  bool isLive([DateTime? now]) {
    final n = now ?? DateTime.now();
    final s = startsAtDate, e = endsAtDate;
    return s != null && e != null && n.isAfter(s) && n.isBefore(e);
  }

  bool isEnded([DateTime? now]) {
    final e = endsAtDate;
    return e != null && (now ?? DateTime.now()).isAfter(e);
  }

  bool isSelfCheckInOpen([DateTime? now]) {
    final n = now ?? DateTime.now();
    final s = startsAtDate, e = endsAtDate;
    return s != null && e != null && n.isAfter(s.subtract(selfCheckInOpensBefore)) && n.isBefore(e);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['description'] = _description;
    map['category'] = _category;
    if (_venue != null) map['venue'] = _venue?.toJson();
    map['startsAt'] = _startsAt;
    map['endsAt'] = _endsAt;
    map['capacity'] = _capacity;
    map['ticketsIssued'] = _ticketsIssued;
    if (_role != null) map['role'] = _role;
    return map;
  }
}
