import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:eventpass/models/QueuedScan.dart';

/// Claims inside a verified ticket token.
class TicketClaims {
  TicketClaims({required this.ticketId, required this.eventId, required this.holderName, required this.issuedAt});

  final String ticketId;
  final String eventId;
  final String holderName;
  final DateTime issuedAt;
}

class VerifyResult {
  VerifyResult(this.result, [this.claims]);

  /// One of [ScanResults]: accepted, revoked, wrong_event or invalid.
  final String result;
  final TicketClaims? claims;
}

/// Checks `EP1.<payload>.<signature>` tickets with only the event's public
/// key, so a gate phone needs no connection. Mirrors the backend's
/// `verifyTicket` in backend/src/lib/ticket-token.ts.
class TicketVerifier {
  TicketVerifier({required String publicKeyPem, required this.eventId, Iterable<String> revokedTicketIds = const []})
      : _publicKey = SimplePublicKey(rawEd25519KeyFromPem(publicKeyPem), type: KeyPairType.ed25519),
        _revoked = revokedTicketIds.toSet();

  static const _prefix = 'EP1';
  static final _ed25519 = Ed25519();

  final SimplePublicKey _publicKey;
  final String eventId;
  final Set<String> _revoked;

  Future<VerifyResult> verify(String token) async {
    final parts = token.trim().split('.');
    if (parts.length != 3 || parts[0] != _prefix) return VerifyResult(ScanResults.invalid);

    final Uint8List signature;
    final Map<String, dynamic> json;
    try {
      signature = _base64Url(parts[2]);
      json = jsonDecode(utf8.decode(_base64Url(parts[1]))) as Map<String, dynamic>;
    } catch (_) {
      return VerifyResult(ScanResults.invalid);
    }
    if (signature.length != 64) return VerifyResult(ScanResults.invalid);

    final ok = await _ed25519.verify(
      utf8.encode('$_prefix.${parts[1]}'),
      signature: Signature(signature, publicKey: _publicKey),
    );
    if (!ok) return VerifyResult(ScanResults.invalid);

    final tid = json['tid'], eid = json['eid'];
    if (tid is! String || eid is! String) return VerifyResult(ScanResults.invalid);
    final claims = TicketClaims(
      ticketId: tid,
      eventId: eid,
      holderName: json['name']?.toString() ?? '',
      issuedAt: DateTime.fromMillisecondsSinceEpoch(((json['iat'] as num?) ?? 0).toInt() * 1000, isUtc: true),
    );
    // The signature is only meaningful with this event's key, but check the
    // claim too so a ticket for another event is reported clearly.
    if (eid != eventId) return VerifyResult(ScanResults.wrongEvent, claims);
    if (_revoked.contains(tid)) return VerifyResult(ScanResults.revoked, claims);
    return VerifyResult(ScanResults.accepted, claims);
  }

  static Uint8List _base64Url(String s) => base64Url.decode(base64Url.normalize(s));
}

/// An Ed25519 SPKI public key is a fixed 12-byte header followed by the
/// 32-byte raw key, so the raw key is the last 32 bytes of the DER.
Uint8List rawEd25519KeyFromPem(String pem) {
  final body = pem.replaceAll(RegExp(r'-----[^-]+-----'), '').replaceAll(RegExp(r'\s'), '');
  final der = base64.decode(body);
  if (der.length != 44) throw const FormatException('Not an Ed25519 public key');
  return Uint8List.fromList(der.sublist(der.length - 32));
}
