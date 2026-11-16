# EventPass mobile app

One Flutter app with two roles:

- **Attendees:** browse events, claim a ticket, show a QR code at the gate even with no signal, or check in with their location when they're inside the venue's geofence.
- **Gate staff:** scan tickets with the camera. Each QR is verified on the phone with the event's Ed25519 public key, so scanning works with no connection; scans queue locally and sync in the background.

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

### Geofenced self check-in

The ticket screen offers "Check in with my location" from 2 hours before the start until the end. The app takes one high-accuracy GPS fix (`geolocator`) and sends it with its accuracy and the OS's mock-location flag; the **server** computes the distance to the venue and decides. The event screen shows the venue and its radius on an OpenStreetMap map (`flutter_map`).

## Stack

Flutter 3.47 · Riverpod · Dio · Drift (SQLite) · mobile_scanner · cryptography (Ed25519) · geolocator · flutter_map · qr_flutter · ScreenUtil · English and Urdu (`flutter gen-l10n`)

## Tests

- `ticket_verifier_test.dart`: verifies a token **signed by the Node backend**; rejects other keys, edited payloads, junk QR codes, revoked and wrong-event tickets.
- `scanner_repository_test.dart`: scanning with no network, duplicate detection, sync with the gate name, failed uploads stay queued, overruled scans, cached bundle fallback.
- `tickets_repository_test.dart`: online fetch, airplane mode, empty cache, 401 handling, revoked tickets, claiming, sold-out, self check-in (success, outside geofence, permission denied).
