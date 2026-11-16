// ignore_for_file: constant_identifier_names
/// Every named route in the app. Screens are opened ONLY via these names.
class Routes {
  Routes._();

  static const String SPLASH = '/';
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String HOME = '/home';

  /// Argument: `Event`.
  static const String EVENT_DETAIL = '/event-detail';

  /// Argument: `Ticket`.
  static const String TICKET_DETAIL = '/ticket-detail';
  // [MODULE_ROUTES]
}
