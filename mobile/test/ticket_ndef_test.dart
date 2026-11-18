import 'dart:convert';
import 'dart:typed_data';

import 'package:eventpass/utils/nfc/ticket_ndef.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_manager/ndef_record.dart';

import 'fixtures.dart';

void main() {
  test('a ticket round-trips through an NDEF text record', () {
    final message = TicketNdef.message(nodeToken);
    final record = message.records.single;
    expect(record.typeNameFormat, TypeNameFormat.wellKnown);
    expect(utf8.decode(record.type), 'T');
    expect(record.payload.sublist(0, 3), [2, ...ascii.encode('en')]);
    expect(TicketNdef.tokenFrom(message), nodeToken);
  });

  test('raw bytes match the NDEF wire format the phone emulates', () {
    // A short holder name fits a short record (1-byte payload length).
    const short = 'EP1.eyJ0aWQiOiJ4In0.c2ln';
    final bytes = TicketNdef.encode(short);
    expect(bytes.length, TicketNdef.message(short).byteLength);
    expect(bytes.sublist(0, 4), [0xD1, 1, 3 + short.length, 0x54]); // MB|ME|SR|TNF=1, type length, payload length, "T"
    expect(utf8.decode(bytes.sublist(7)), short);

    // Real tickets are usually over 255 bytes, so they use a 4-byte length.
    final real = TicketNdef.encode(nodeToken);
    expect(real.length, TicketNdef.message(nodeToken).byteLength);
    expect(utf8.decode(real.sublist(10)), nodeToken);
  });

  test('long payloads switch to a 4-byte length', () {
    final long = 'EP1.${'a' * 300}.sig';
    final bytes = TicketNdef.encode(long);
    expect(bytes[0], 0xC1); // no SR flag
    expect(bytes.sublist(2, 6), [0, 0, (303 + 8) >> 8, (303 + 8) & 0xFF]);
    expect(bytes.length, TicketNdef.message(long).byteLength);
  });

  test('finds the ticket in URI records written by other apps, ignores other tags', () {
    final uri = NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([0x55]), // "U"
      identifier: Uint8List(0),
      payload: Uint8List.fromList([0x04, ...utf8.encode('eventpass.app/t#$nodeToken')]),
    );
    expect(TicketNdef.tokenFrom(NdefMessage(records: [uri])), nodeToken);

    final other = NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([0x54]),
      identifier: Uint8List(0),
      payload: Uint8List.fromList([2, ...utf8.encode('enHello from a business card')]),
    );
    expect(TicketNdef.tokenFrom(NdefMessage(records: [other])), isNull);
    expect(TicketNdef.tokenFrom(null), isNull);
  });

  test('a ticket needs an NTAG215 or larger', () {
    final size = TicketNdef.message(nodeToken).byteLength;
    expect(size, greaterThan(TicketNdef.tagCapacities['NTAG213']!));
    expect(size, lessThan(TicketNdef.tagCapacities['NTAG215']!));
  });
}
