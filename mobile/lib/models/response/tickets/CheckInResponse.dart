/// Result of a geofenced self check-in.
class CheckInResponse {
  CheckInResponse.fromJson(dynamic json)
      : status = json['status'],
        checkedInAt = json['checkedInAt'],
        method = json['method'],
        distanceM = (json['distanceM'] as num?)?.toInt();

  /// `checked_in`, or `already_checked_in` when the ticket was used before.
  final String? status;
  final String? checkedInAt;
  final String? method;

  /// How far the phone was from the venue centre.
  final int? distanceM;

  bool get alreadyCheckedIn => status == 'already_checked_in';
}
