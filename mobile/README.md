# EventPass mobile app

Flutter app for attendees: browse events, claim a ticket, and show a QR code at the gate even with no signal. The gate-staff scanner mode comes next (see the root [roadmap](../README.md#roadmap)).

## Run it

Requirements: Flutter 3.47+, and the [backend](../backend) running locally.

```bash
flutter pub get
flutter run                                                      # Android emulator → http://10.0.2.2:3000/
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/ # physical phone → your PC's LAN IP
flutter test
```

Debug builds allow plain HTTP to reach the local backend; release builds don't.

## How it's built

Each feature module has exactly one **repository** (the only code that knows URLs and JSON) and one **notifier** (the only thing screens observe). Every API call goes through one `NetworkRepository`, so auth headers and error mapping live in one place.

```
Screen ──ref.read(...notifier).apiX()──▶ Notifier (StateNotifier<ApiStatesModel>)
       ◀──ref.listen / ref.watch: IDLE · LOADING · DATA · ERROR · SESSIONEXPIRED
                                             │ ref.read(xRepository).apiX()
                                             ▼
                          Repository ──▶ NetworkRepository (Dio) ──▶ API
                               └──▶ Drift (offline ticket cache)
```

| Module | Repository | Notifier | Screens |
| --- | --- | --- | --- |
| Auth | `auth_repository.dart` | `api_auth_notifier.dart` | Login, Register |
| Events | `events_repository.dart` | `api_events_notifier.dart` | Events tab, Event detail |
| Tickets | `tickets_repository.dart` | `api_tickets_notifier.dart` | My tickets tab, Ticket QR |

### Offline tickets

`TicketsRepository.apiGetMyTickets()` is network-first. Every successful fetch replaces the local Drift cache. When the server can't be reached, it returns the cached tickets with `fromCache: true`, and the UI shows an offline banner. The QR code still works: its token is already signed, and the scanner verifies it offline.

A `401` is never masked by the cache, so an expired session still goes through the sign-in-again flow. Logging out deletes the cached tickets, so the next user on the device can't see them.

## Stack

Flutter 3.47 · Riverpod · Dio · Drift (SQLite) · qr_flutter · ScreenUtil · English and Urdu (`flutter gen-l10n`)

## Tests

`test/tickets_repository_test.dart` runs the real repository against a fake HTTP adapter and an in-memory database. It covers the online fetch, airplane mode, an empty cache, a 401 during offline fallback, revoked tickets, claiming, and sold-out events.
