import 'dart:convert';

import 'Event.dart';

/// Everything a gate phone needs to verify tickets with no connection:
/// the event's Ed25519 public key and the ids of revoked tickets.
class ScannerBundle {
  ScannerBundle({Event? event, String? publicKey, List<String>? revokedTicketIds, String? generatedAt}) {
    _event = event;
    _publicKey = publicKey;
    _revokedTicketIds = revokedTicketIds;
    _generatedAt = generatedAt;
  }

  ScannerBundle.fromJson(dynamic json) {
    _event = json['event'] != null ? Event.fromJson(json['event']) : null;
    _publicKey = json['publicKey'];
    _revokedTicketIds = (json['revokedTicketIds'] as List?)?.map((e) => e.toString()).toList();
    _generatedAt = json['generatedAt'];
  }

  /// Row constructor for Drift (`@UseRowClass`).
  factory ScannerBundle.fromDb({required String eventId, required String bundleJson}) =>
      ScannerBundle.fromJson(jsonDecode(bundleJson));

  Event? _event;
  String? _publicKey;
  List<String>? _revokedTicketIds;
  String? _generatedAt;

  Event? get event => _event;

  /// PEM-encoded SPKI public key.
  String? get publicKey => _publicKey;
  List<String> get revokedTicketIds => _revokedTicketIds ?? const [];

  /// When the server built this bundle; revocations after it aren't known offline.
  String? get generatedAt => _generatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_event != null) map['event'] = _event?.toJson();
    map['publicKey'] = _publicKey;
    map['revokedTicketIds'] = _revokedTicketIds;
    map['generatedAt'] = _generatedAt;
    return map;
  }
}
