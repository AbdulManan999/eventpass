import 'dart:convert';

import 'Event.dart';

/// A ticket the user holds. [token] is the signed `EP1.…` string shown as the
/// QR code. Gate scanners verify it offline, so a cached copy works with no
/// connection.
class Ticket {
  Ticket({
    String? id,
    String? status,
    String? issuedAt,
    String? token,
    Event? event,
    String? checkedInAt,
    String? checkInMethod,
  }) {
    _id = id;
    _status = status;
    _issuedAt = issuedAt;
    _token = token;
    _event = event;
    _checkedInAt = checkedInAt;
    _checkInMethod = checkInMethod;
  }

  Ticket.fromJson(dynamic json) {
    _id = json['id'];
    _status = json['status'];
    _issuedAt = json['issuedAt'];
    _token = json['token'];
    _event = json['event'] != null ? Event.fromJson(json['event']) : null;
    _checkedInAt = json['checkedInAt'];
    _checkInMethod = json['checkInMethod'];
  }

  /// Row constructor for Drift (`@UseRowClass`): parameter names match the
  /// column getters in TicketsTable.
  Ticket.fromDb({
    required String id,
    required String status,
    required String issuedAt,
    required String token,
    required String eventJson,
    String? checkedInAt,
    String? checkInMethod,
  }) {
    _id = id;
    _status = status;
    _issuedAt = issuedAt;
    _token = token;
    _event = Event.fromJson(jsonDecode(eventJson));
    _checkedInAt = checkedInAt;
    _checkInMethod = checkInMethod;
  }

  String? _id;
  String? _status;
  String? _issuedAt;
  String? _token;
  Event? _event;
  String? _checkedInAt;
  String? _checkInMethod;

  String? get id => _id;

  /// `valid` or `revoked`.
  String? get status => _status;
  String? get issuedAt => _issuedAt;
  String? get token => _token;
  Event? get event => _event;

  /// ISO-8601 time of the accepted check-in, or null if not checked in.
  String? get checkedInAt => _checkedInAt;

  /// `qr` or `nfc` (read at a gate), or `geofence` (self check-in).
  String? get checkInMethod => _checkInMethod;

  bool get isRevoked => _status == 'revoked';
  bool get isCheckedIn => _checkedInAt != null;

  /// A copy marked as checked in, e.g. after a successful self check-in.
  Ticket checkedIn(String at, String method) => Ticket(
        id: _id,
        status: _status,
        issuedAt: _issuedAt,
        token: _token,
        event: _event,
        checkedInAt: at,
        checkInMethod: method,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['status'] = _status;
    map['issuedAt'] = _issuedAt;
    map['token'] = _token;
    if (_event != null) map['event'] = _event?.toJson();
    map['checkedInAt'] = _checkedInAt;
    map['checkInMethod'] = _checkInMethod;
    return map;
  }
}
