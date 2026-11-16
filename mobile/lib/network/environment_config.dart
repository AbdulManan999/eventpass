// ignore_for_file: constant_identifier_names, non_constant_identifier_names

/// Single place for the base URL and every API endpoint path.
///
/// The API URL is passed at build time, so nothing secret lives in the app:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/
/// The default reaches a backend on the host machine from the Android emulator.
class EnvironmentConfig {
  EnvironmentConfig._();

  static const String BASE_API_URL = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/');

  // ── Endpoints (relative to BASE_API_URL, no leading slash) ──────────────
  static const String LOGIN = 'auth/login';
  static const String REGISTER = 'auth/register';
  static const String EVENTS = 'events';
  static const String MY_TICKETS = 'me/tickets';

  /// POST — claim a ticket for an event.
  static String CLAIM_TICKET(String eventId) => 'events/$eventId/tickets';
  // [MODULE_ENDPOINTS]
}
