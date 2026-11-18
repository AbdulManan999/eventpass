import 'dart:async';

import 'package:eventpass/l10n/app_localizations.dart';
import 'package:eventpass/models/QueuedScan.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/providers/api_tickets_notifier.dart';
import 'package:eventpass/utils/nfc/nfc_service.dart';
import 'package:eventpass/views/scanner/nfc_reader_view.dart';
import 'package:eventpass/views/scanner/scan_result_overlay.dart';
import 'package:eventpass/views/tap_pass/tap_pass_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

/// NFC hardware stand-in: tests put tags near the phone and play gate readers.
class FakeNfc extends NfcService {
  NfcStatus statusValue = NfcStatus.ready;
  void Function(String? token)? _onTag;
  final _reads = StreamController<void>.broadcast();
  String? emulatedToken;

  bool get reading => _onTag != null;
  void tap(String? token) => _onTag!(token);
  void gateReads() => _reads.add(null);

  @override
  bool get needsReadButton => false;

  @override
  Future<NfcStatus> status() async => statusValue;

  @override
  Future<void> startReading({required void Function(String? token) onTag, void Function()? onEnded}) async => _onTag = onTag;

  @override
  Future<void> stopReading() async => _onTag = null;

  @override
  Future<bool> canEmulate() async => true;

  @override
  Future<void> startEmulation(String token) async => emulatedToken = token;

  @override
  Future<void> stopEmulation() async => emulatedToken = null;

  @override
  Stream<void> get emulationReads => _reads.stream;
}

final ticket = Ticket.fromJson({
  'id': ticketId,
  'status': 'valid',
  'issuedAt': '2026-11-16T10:00:00.000Z',
  'token': nodeToken,
  'event': {
    'id': eventId,
    'title': 'Lahore Tech Conference',
    'category': 'tech',
    'venue': {'name': 'Arfa Tower', 'latitude': 31.47, 'longitude': 74.34, 'geofenceRadiusM': 250},
    'startsAt': '2026-11-16T10:00:00.000Z',
    'endsAt': '2026-11-16T18:00:00.000Z',
    'capacity': 300,
  },
});

void main() {
  late FakeNfc nfc;

  setUp(() => nfc = FakeNfc());

  Future<void> pumpApp(WidgetTester tester, Widget child) async {
    // A phone-sized screen, so ScreenUtil sizes match the design.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [nfcServiceProvider.overrideWithValue(nfc)],
        // ScreenUtil.init rather than ScreenUtilInit, which never unregisters
        // its metrics observer and breaks the next test.
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              ScreenUtil.init(context, designSize: const Size(390, 844));
              return Scaffold(body: child);
            },
          ),
        ),
      ),
    );
  }

  /// Repeating animations never settle, so step time instead of pumpAndSettle.
  Future<void> advance(WidgetTester tester, [int ms = 800]) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(Duration(milliseconds: ms ~/ 8));
    }
  }

  /// Unmount, then let delayed animation timers finish.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  }

  group('gate NFC reader', () {
    testWidgets('hands ticket tokens to the scanner and flags tags without a ticket', (tester) async {
      final tokens = <String>[];
      await pumpApp(tester, NfcReaderView(onTicket: tokens.add));
      await advance(tester);

      expect(find.text('Ready for taps'), findsOneWidget);
      expect(nfc.reading, isTrue, reason: 'Android reads as soon as the view opens');

      nfc.tap(nodeToken);
      expect(tokens, [nodeToken]);

      nfc.tap(null);
      await advance(tester);
      expect(find.text('No EventPass ticket on this tag'), findsOneWidget);
      await advance(tester, 2400);
      expect(find.text('No EventPass ticket on this tag'), findsNothing);

      await unmount(tester);
      expect(nfc.reading, isFalse, reason: 'leaving NFC mode stops reader mode');
    });

    testWidgets('asks to turn NFC on when it is off', (tester) async {
      nfc.statusValue = NfcStatus.disabled;
      await pumpApp(tester, NfcReaderView(onTicket: (_) {}));
      await advance(tester);
      expect(find.text('NFC is turned off'), findsOneWidget);
      expect(find.text('Turn on NFC'), findsOneWidget);
      expect(nfc.reading, isFalse);
      await unmount(tester);
    });
  });

  testWidgets('the result overlay names the attendee and how the ticket was read', (tester) async {
    final scan = QueuedScan.fromDb(
      id: 's1',
      eventId: eventId,
      token: nodeToken,
      scannedAt: '2026-11-16T10:00:00.000Z',
      localResult: ScanResults.accepted,
      method: ScanMethods.nfc,
      ticketId: ticketId,
      holderName: 'Ayesha Khan',
    );
    await pumpApp(tester, ScanResultOverlay(scan: scan));
    await advance(tester, 1200);
    expect(find.text('Admitted'), findsOneWidget);
    expect(find.text('Ayesha Khan'), findsOneWidget);
    expect(find.textContaining('NFC tap'), findsOneWidget);
    expect(find.textContaining('#6F1C2A54'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('tap to check in: emulates the ticket, then celebrates when the gate confirms', (tester) async {
    await pumpApp(tester, TapPassScreen(ticket: ticket));
    await advance(tester);

    expect(nfc.emulatedToken, nodeToken, reason: 'the phone offers the signed ticket over NFC');
    expect(find.text('Tap to check in'), findsOneWidget);
    expect(find.text('Hold the phones back to back'), findsOneWidget);

    nfc.gateReads();
    await advance(tester);
    expect(find.text('Ticket sent to the gate'), findsOneWidget);

    // The gate synced; the next ticket refresh shows the check-in.
    final container = ProviderScope.containerOf(tester.element(find.byType(TapPassScreen)));
    container.read(myTicketsProvider.notifier).state = [ticket.checkedIn('2026-11-16T10:05:00.000Z', 'nfc')];
    await advance(tester, 1600);

    expect(find.text("You're in!"), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(nfc.emulatedToken, isNull, reason: 'emulation stops once checked in');
    await unmount(tester);
  });
}
