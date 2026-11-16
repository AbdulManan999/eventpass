class Constants {
  Constants._();

  static const String dbName = 'eventpass.sqlite';

  // ── Networking ──────────────────────────────────────────────────────────
  static int connectionTimeOut = 15000; // ms
  static int receiveTimeOut = 20000; // ms

  // ── Error messages used by DataException / NetworkRepository ────────────
  static const String errorRequestCancelled = 'Request was cancelled';
  static const String errorConnectionTimeout = 'Connection timeout';
  static const String errorReceiveTimeout = 'Receive timeout';
  static const String errorSendTimeout = 'Send timeout';
  static const String errorInternetConnection = 'Please check your internet connection';
  static const String errorBadRequest = 'Bad request';
  static const String errorRequestNotFound = 'Request not found';
  static const String errorInternalServer = 'Internal server error';
  static const String errorSomethingWentWrong = 'Something went wrong';
  static const String errorValidation = 'Validation errors occurred.';
  static const String errorSessionExpired = 'Session expired, please log in again';

  // ── SharedPreferences keys ──────────────────────────────────────────────
  static const String prefToken = 'token';
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserData = 'user_data';
  static const String prefGateName = 'gate_name';

  /// Sent as the scanner's device id; shown per gate on the admin dashboard.
  static const String defaultGateName = 'Main gate';
}
