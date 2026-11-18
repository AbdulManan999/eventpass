import 'dart:convert';
import 'dart:typed_data';

import 'package:nfc_manager/ndef_record.dart';

/// How a ticket is stored on NFC: one NDEF Text record whose text is the
/// signed token (`EP1.<payload>.<signature>`), the same string as the QR code.
/// So a wristband, a sticker and a phone emulating a tag all carry exactly
/// what the gate already knows how to verify offline.
class TicketNdef {
  TicketNdef._();

  static final _token = RegExp(r'EP1\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+');

  /// Text record payload: status byte (UTF-8, language code length), language code, text.
  static const _language = 'en';

  /// Memory for NDEF data on common tags. NTAG213 is too small for a ticket.
  static const tagCapacities = {'NTAG213': 137, 'NTAG215': 496, 'NTAG216': 868};

  static NdefRecord record(String token) => NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x54]), // "T"
        identifier: Uint8List(0),
        payload: Uint8List.fromList([_language.length, ...ascii.encode(_language), ...utf8.encode(token)]),
      );

  static NdefMessage message(String token) => NdefMessage(records: [record(token)]);

  /// The raw bytes of [message], as a tag (or the phone's tag emulation) stores them.
  static Uint8List encode(String token) {
    final r = record(token);
    final shortRecord = r.payload.length < 256;
    final header = 0x80 | 0x40 | (shortRecord ? 0x10 : 0) | 0x01; // MB, ME, SR, TNF well-known
    final length = r.payload.length;
    return Uint8List.fromList([
      header,
      r.type.length,
      if (shortRecord) length else ...[length >> 24 & 0xFF, length >> 16 & 0xFF, length >> 8 & 0xFF, length & 0xFF],
      ...r.type,
      ...r.payload,
    ]);
  }

  /// The ticket token in [message], or null if it holds no ticket. Lenient:
  /// accepts the token in any record (text, URI or plain), since tags are
  /// sometimes written by other apps.
  static String? tokenFrom(NdefMessage? message) {
    for (final r in message?.records ?? const <NdefRecord>[]) {
      final match = _token.firstMatch(utf8.decode(r.payload, allowMalformed: true));
      if (match != null) return match.group(0);
    }
    return null;
  }
}
