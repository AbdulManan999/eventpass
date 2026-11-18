# EventPass mobile app

One Flutter app with two roles:

- **Attendees:** browse events, claim a ticket, show a QR code at the gate even with no signal, tap their phone (Android) or an NFC wristband at the gate, or check in with their location when they're inside the venue's geofence.
- **Gate staff:** scan QR codes with the camera or switch to NFC to read wristbands and phones. Each ticket is verified on the phone with the event's Ed25519 public key, so scanning works with no connection; scans queue locally and sync in the background.

The Scan tab appears for organizers and for anyone the organizer added as gate staff.

## Run it

Requirements: Flutter 3.47+, and the [backend](../backend) running locally (`npm run seed` creates demo data).

```bash
flutter pub get
flutter run                                                      # Android emulator → http://10.0.2.2:3000/
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/ # physical phone → your PC's LAN IP
flutter test
```

Debug builds allow plain HTTP to reach the local backend; release builds don't. Demo accounts use the password `eventpass-demo`: `attendee@eventpass.dev` for tickets and self check-in, `staff@eventpass.dev` for the scanner.

## How it's built

Each feature module has exactly one **repository** (the only code that knows URLs and JSON) and one **notifier** (the only thing screens observe). Every API call goes through one `NetworkRepository`, so auth headers and error mapping live in one place.

```
Screen ──ref.read(...notifier).apiX()──▶ Notifier (StateNotifier<ApiStatesModel>)
       ◀──ref.listen / ref.watch: IDLE · LOADING · DATA · ERROR · SESSIONEXPIRED
                                             │ ref.read(xRepository).apiX()
                                             ▼
                          Repository ──▶ NetworkRepository (Dio) ──▶ API
                               └──▶ Drift (tickets, scan queue, scanner bundles)
```

| Module | Repository | Notifier | Screens |
| --- | --- | --- | --- |
| Auth | `auth_repository.dart` | `api_auth_notifier.dart` | Login, Register |
| Events | `events_repository.dart` | `api_events_notifier.dart` | Events tab, Event detail (map + geofence) |
| Tickets | `tickets_repository.dart` | `api_tickets_notifier.dart` | My tickets, Ticket (QR + self check-in) |
| Scanner | `scanner_repository.dart` | `api_scanner_notifier.dart` | Staff events, Scanner |

### Offline tickets

`TicketsRepository.apiGetMyTickets()` is network-first. Every successful fetch replaces the local Drift cache; when the server can't be reached, it returns the cached tickets and the UI shows an offline banner. A `401` is never masked by the cache. Logging out deletes cached tickets and queued scans.

### Offline scanning

1. Opening the scanner downloads the event's **scanner bundle** (public key + revoked ticket ids) and saves it, so a phone that loses its connection or restarts can keep scanning.
2. `TicketVerifier` checks the token's Ed25519 signature with the `cryptography` package, then the event id and the revoked list. A ticket this phone already admitted is a duplicate.
3. The scan is written to the `scan_queue` table with a device-generated UUID, *before* anything else happens.
4. A background sync uploads pending scans (on each scan and every 20 s) with the gate name as device id, stores the server's verdict next to the phone's, and refreshes the bundle to pick up new revocations.
5. If another gate admitted the same ticket first, the server answers `duplicate` and the scanner reports it as *overruled*.

### NFC check-in

An NFC ticket is the same signed token as the QR code, stored as one NDEF Text record (`utils/nfc/ticket_ndef.dart`). All NFC access goes through `NfcService` (`utils/nfc/nfc_service.dart`), which screens get from a provider so tests can replace it.

- **Gate (NFC mode):** reader mode stays on while the mode is selected (Android) or the system sheet is open (iOS). Each tag's token goes through the same `scan()` as a QR code, saved with `method: nfc`. Tags without a ticket show a "No EventPass ticket" hint and are not queued.
- **Tap your phone (Android):** `TapPassScreen` starts host card emulation. `TicketHceService.kt` answers the gate as a read-only NFC Forum Type 4 Tag, using `Type4TagEmulator.kt` (pure Kotlin, JUnit-tested). When the reader has read the whole message, an event channel tells Flutter, which shows "Ticket sent" and polls `/me/tickets` until the gate's sync confirms the check-in.
- **Save to wristband:** writes the record to a blank tag, checking that it is writable and big enough (NTAG215 or larger).

To try it you need two phones (one Android for tap-to-check-in) or one phone and an NTAG215 sticker. NFC can't be tested on an emulator.

### Geofenced self check-in

The ticket screen offers "Check in with my location" from 2 hours before the start until the end. The app takes one high-accuracy GPS fix (`geolocator`) and sends it with its accuracy and the OS's mock-location flag; the **server** computes the distance to the venue and decides. The event screen shows the venue and its radius on an OpenStreetMap map (`flutter_map`).

## Stack

Flutter 3.47 · Riverpod · Dio · Drift (SQLite) · mobile_scanner · nfc_manager + Kotlin host card emulation · cryptography (Ed25519) · geolocator · flutter_map · qr_flutter · flutter_animate · ScreenUtil · English and Urdu (`flutter gen-l10n`)

## Tests

- `ticket_verifier_test.dart`: verifies a token **signed by the Node backend**; rejects other keys, edited payloads, junk QR codes, revoked and wrong-event tickets.
- `scanner_repository_test.dart`: scanning with no network, duplicate detection, sync with the gate name, failed uploads stay queued, overruled scans, cached bundle fallback.
- `tickets_repository_test.dart`: online fetch, airplane mode, empty cache, 401 handling, revoked tickets, claiming, sold-out, self check-in (success, outside geofence, permission denied).
- `ticket_ndef_test.dart`: NDEF encoding matches the bytes the phone emulates, short and long records, tokens in records written by other apps, tag size limits.
- `nfc_screens_test.dart`: the gate NFC reader (tickets, tags without a ticket, NFC off), the animated result overlay, and the whole tap-to-check-in flow (emulating, sent, confirmed), driven by a fake `NfcService`.
- `android/app/src/test/.../Type4TagEmulatorTest.kt`: a full Type 4 Tag reader conversation. Run with `cd android && ./gradlew :app:testDebugUnitTest`.
