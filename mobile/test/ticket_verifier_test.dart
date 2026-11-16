import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:eventpass/models/QueuedScan.dart';
import 'package:eventpass/utils/geo.dart';
import 'package:eventpass/utils/ticket_verifier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  group('TicketVerifier', () {
    final verifier = TicketVerifier(publicKeyPem: nodePublicKeyPem, eventId: eventId);

    test('accepts a ticket signed by the backend and reads its claims', () async {
      final r = await verifier.verify(nodeToken);
      expect(r.result, ScanResults.accepted);
      expect(r.claims?.ticketId, ticketId);
      expect(r.claims?.holderName, 'Ayesha Khan');
      expect(r.claims?.issuedAt, DateTime.fromMillisecondsSinceEpoch(1763290000 * 1000, isUtc: true));
    });

    test('rejects a ticket signed with another key', () async {
      expect((await verifier.verify(foreignToken)).result, ScanResults.invalid);
    });

    test('rejects an edited payload, even with the original signature', () async {
      final parts = nodeToken.split('.');
      final claims = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))) as Map<String, dynamic>;
      claims['name'] = 'Someone Else';
      final forgedPayload = base64Url.encode(utf8.encode(jsonEncode(claims))).replaceAll('=', '');
      expect((await verifier.verify('EP1.$forgedPayload.${parts[2]}')).result, ScanResults.invalid);
    });

    test('rejects garbage and other QR codes', () async {
      for (final junk in ['', 'https://example.com', 'EP1.only-two', 'EP2.a.b', 'EP1.!!!.???']) {
        expect((await verifier.verify(junk)).result, ScanResults.invalid, reason: junk);
      }
    });

    test('reports revoked tickets and tickets for another event', () async {
      final revoked = TicketVerifier(publicKeyPem: nodePublicKeyPem, eventId: eventId, revokedTicketIds: [ticketId]);
      expect((await revoked.verify(nodeToken)).result, ScanResults.revoked);

      final otherEvent = TicketVerifier(publicKeyPem: nodePublicKeyPem, eventId: 'some-other-event');
      expect((await otherEvent.verify(nodeToken)).result, ScanResults.wrongEvent);
    });

    test('works with keys generated on the device', () async {
      final keyPair = await Ed25519().newKeyPair();
      final pub = await keyPair.extractPublicKey();
      // SPKI DER = fixed Ed25519 header + 32-byte key.
      final der = [0x30, 0x2a, 0x30, 0x05, 0x06, 0x03, 0x2b, 0x65, 0x70, 0x03, 0x21, 0x00, ...pub.bytes];
      final pem = '-----BEGIN PUBLIC KEY-----\n${base64.encode(der)}\n-----END PUBLIC KEY-----\n';

      final payload = base64Url.encode(utf8.encode(jsonEncode({'tid': 't1', 'eid': 'e1', 'name': 'Bilal', 'iat': 0}))).replaceAll('=', '');
      final sig = await Ed25519().sign(utf8.encode('EP1.$payload'), keyPair: keyPair);
      final token = 'EP1.$payload.${base64Url.encode(sig.bytes).replaceAll('=', '')}';

      final r = await TicketVerifier(publicKeyPem: pem, eventId: 'e1').verify(token);
      expect(r.result, ScanResults.accepted);
      expect(r.claims?.holderName, 'Bilal');
    });
  });

  group('geo', () {
    test('distanceMeters matches the backend', () {
      expect(distanceMeters(31.4757, 74.3424, 31.4757, 74.3424), 0);
      expect(distanceMeters(31.4757, 74.3424, 31.4767, 74.3424), closeTo(111.2, 0.5));
    });

    test('formatDistance', () {
      expect(formatDistance(180.4), '180 m');
      expect(formatDistance(1530), '1.5 km');
    });
  });
}
