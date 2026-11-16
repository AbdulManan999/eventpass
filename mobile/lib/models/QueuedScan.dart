/// One scan made on this phone. Stored in Drift immediately (so nothing is lost
/// if the app closes) and uploaded to the server when there is a connection.
class QueuedScan {
  QueuedScan.fromDb({
    required this.id,
    required this.eventId,
    required this.token,
    required this.scannedAt,
    required this.localResult,
    this.ticketId,
    this.holderName,
    this.serverResult,
    this.syncedAt,
  });

  /// UUID generated on the device; makes re-uploading idempotent.
  final String id;
  final String eventId;
  final String token;

  /// ISO-8601, UTC.
  final String scannedAt;

  /// What this phone decided offline: see [ScanResults].
  final String localResult;
  final String? ticketId;
  final String? holderName;

  /// The server's final word after sync: accepted, duplicate, revoked or invalid.
  final String? serverResult;
  final String? syncedAt;

  bool get isSynced => serverResult != null;

  /// The result to show: the server's once synced, otherwise the local one.
  String get effectiveResult => serverResult ?? localResult;

  bool get admitted => effectiveResult == ScanResults.accepted;

  /// The phone let someone in, but the server later found the ticket was
  /// already used at another gate (or revoked after the bundle was downloaded).
  bool get overruled => localResult == ScanResults.accepted && serverResult != null && serverResult != ScanResults.accepted;
}

/// Scan results, shared with the backend's vocabulary.
class ScanResults {
  ScanResults._();

  static const accepted = 'accepted';
  static const duplicate = 'duplicate';
  static const revoked = 'revoked';
  static const invalid = 'invalid';

  /// Signed for a different event. Local only; the server records it as invalid.
  static const wrongEvent = 'wrong_event';
}
