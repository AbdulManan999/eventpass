import 'dart:convert';

import 'Event.dart';

/// A ticket the user holds. [token] is the signed `EP1.…` string shown as the
/// QR code. Gate scanners verify it offline, so a cached copy works with no
/// connection.
class Ticket {
  Ticket({String? id, String? status, String? issuedAt, String? token, Event? event}) {
    _id = id;
    _status = status;
    _issuedAt = issuedAt;
    _token = token;
    _event = event;
  }

  Ticket.fromJson(dynamic json) {
    _id = json['id'];
    _status = json['status'];
    _issuedAt = json['issuedAt'];
    _token = json['token'];
    _event = json['event'] != null ? Event.fromJson(json['event']) : null;
  }

  /// Row constructor for Drift (`@UseRowClass`): parameter names match the
  /// column getters in TicketsTable.
  Ticket.fromDb({
    required String id,
    required String status,
    required String issuedAt,
    required String token,
    required String eventJson,
  }) {
    _id = id;
    _status = status;
    _issuedAt = issuedAt;
    _token = token;
    _event = Event.fromJson(jsonDecode(eventJson));
  }

  String? _id;
  String? _status;
  String? _issuedAt;
  String? _token;
  Event? _event;

  String? get id => _id;

  /// `valid` or `revoked`.
  String? get status => _status;
  String? get issuedAt => _issuedAt;
  String? get token => _token;
  Event? get event => _event;

  bool get isRevoked => _status == 'revoked';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['status'] = _status;
    map['issuedAt'] = _issuedAt;
    map['token'] = _token;
    if (_event != null) map['event'] = _event?.toJson();
    return map;
  }
}
