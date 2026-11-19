// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get text_welcome_back => 'Welcome back';

  @override
  String get text_login_description => 'Sign in to see your tickets';

  @override
  String get text_create_account => 'Create account';

  @override
  String get text_register_description =>
      'Get tickets in seconds. They work even without signal.';

  @override
  String get email_label => 'Email';

  @override
  String get email_hint => 'you@example.com';

  @override
  String get email_required => 'Email is required';

  @override
  String get email_invalid => 'Enter a valid email';

  @override
  String get password_label => 'Password';

  @override
  String get password_required => 'Password is required';

  @override
  String get password_min => 'Use at least 8 characters';

  @override
  String get name_label => 'Full name';

  @override
  String get name_hint => 'As it should appear on your ticket';

  @override
  String get name_required => 'Name is required';

  @override
  String get text_login => 'Sign in';

  @override
  String get text_register => 'Create account';

  @override
  String get text_no_account => 'New here? Create an account';

  @override
  String get text_have_account => 'Already have an account? Sign in';

  @override
  String get text_events => 'Events';

  @override
  String get text_my_tickets => 'My tickets';

  @override
  String get text_profile => 'Profile';

  @override
  String get text_logout => 'Log out';

  @override
  String get text_dialog_logout =>
      'Do you want to log out? Saved tickets will be removed from this device.';

  @override
  String get text_no_events => 'No upcoming events yet';

  @override
  String get text_no_tickets => 'You don\'t have any tickets yet';

  @override
  String get text_browse_events => 'Browse events';

  @override
  String get text_retry => 'Try again';

  @override
  String get text_get_ticket => 'Get ticket';

  @override
  String get text_view_ticket => 'View my ticket';

  @override
  String text_capacity(int count) {
    return '$count seats';
  }

  @override
  String get text_offline_tickets =>
      'You\'re offline. Showing saved tickets; they still scan at the gate.';

  @override
  String get text_show_at_gate => 'Show this code at the entrance';

  @override
  String get text_ticket_revoked =>
      'This ticket has been cancelled by the organizer';

  @override
  String get text_ticket_ready => 'Ticket ready';

  @override
  String get text_session_expired_title => 'Session expired';

  @override
  String get text_session_expired_message => 'Please sign in again.';

  @override
  String get text_ok => 'OK';

  @override
  String get text_close => 'Close';

  @override
  String get text_signed_in_as => 'Signed in as';

  @override
  String get text_language => 'Language';

  @override
  String text_hello_user(String name) {
    return 'Hello, $name';
  }

  @override
  String get category_all => 'All';

  @override
  String get category_tech => 'Tech';

  @override
  String get category_music => 'Music';

  @override
  String get category_sports => 'Sports';

  @override
  String get category_business => 'Business';

  @override
  String get category_community => 'Community';

  @override
  String get text_discover => 'Find your next event';

  @override
  String get text_search_events => 'Search events or venues';

  @override
  String get text_happening_now => 'Happening now';

  @override
  String get text_upcoming => 'Upcoming';

  @override
  String get text_past => 'Past';

  @override
  String get text_live_now => 'Live now';

  @override
  String text_spots_left(int count) {
    return '$count spots left';
  }

  @override
  String get text_sold_out => 'Sold out';

  @override
  String get text_no_matching_events => 'No events match your search';

  @override
  String get text_about_event => 'About this event';

  @override
  String get text_date_time => 'Date and time';

  @override
  String get text_venue => 'Venue';

  @override
  String text_tickets_claimed(int issued, int capacity) {
    return '$issued of $capacity tickets claimed';
  }

  @override
  String text_self_checkin_zone(String distance) {
    return 'Self check-in works within $distance of the venue';
  }

  @override
  String get text_checked_in => 'Checked in';

  @override
  String text_checked_in_at(String time) {
    return 'Checked in at $time';
  }

  @override
  String get text_checked_in_via_qr => 'Scanned at the gate';

  @override
  String get text_checked_in_via_geofence => 'Self check-in with location';

  @override
  String text_starts_in(String time) {
    return 'Starts in $time';
  }

  @override
  String get text_ended => 'Ended';

  @override
  String get text_revoked => 'Revoked';

  @override
  String get text_check_in_with_location => 'Check in with my location';

  @override
  String get text_self_checkin_hint =>
      'At the venue? Check in from your phone and skip the queue.';

  @override
  String get text_self_checkin_opens =>
      'Self check-in opens 2 hours before the start';

  @override
  String get text_welcome_in => 'You\'re in! Enjoy the event';

  @override
  String get text_already_checked_in => 'This ticket was already checked in';

  @override
  String get text_location_disabled => 'Turn on location services to check in';

  @override
  String get text_location_denied =>
      'Location permission is needed to check in';

  @override
  String get text_location_denied_forever =>
      'Location permission is blocked. Enable it in Settings.';

  @override
  String get text_open_settings => 'Open settings';

  @override
  String get text_scan => 'Scan';

  @override
  String get text_gate_scanner => 'Gate scanner';

  @override
  String get text_staff_events_hint => 'Events you can scan tickets for';

  @override
  String get text_no_staff_events =>
      'You\'re not gate staff for any event yet. Ask the organizer to add your email.';

  @override
  String get text_role_organizer => 'Organizer';

  @override
  String get text_role_staff => 'Staff';

  @override
  String get text_gate_name => 'Gate name';

  @override
  String get text_gate_name_hint => 'e.g. North gate';

  @override
  String get text_gate_name_help =>
      'Shown on the organizer\'s dashboard for scans from this phone.';

  @override
  String get text_save => 'Save';

  @override
  String get text_admitted => 'Admitted';

  @override
  String get text_already_used => 'Already used';

  @override
  String get text_invalid_ticket => 'Invalid ticket';

  @override
  String get text_wrong_event => 'Ticket for another event';

  @override
  String get text_point_camera => 'Point the camera at a ticket QR code';

  @override
  String get text_rejected => 'Rejected';

  @override
  String get text_pending_sync => 'To sync';

  @override
  String text_synced(String time) {
    return 'Synced $time';
  }

  @override
  String get text_syncing => 'Syncing…';

  @override
  String get text_offline_mode => 'Offline: scans are saved on this phone';

  @override
  String get text_sync_failed => 'Sync failed. Will retry.';

  @override
  String text_verified_offline(int count) {
    return 'Verified on this phone with the event\'s key · $count revoked';
  }

  @override
  String text_overruled(int count) {
    return '$count admitted here had already been used at another gate';
  }

  @override
  String get text_scan_history => 'Scan history';

  @override
  String get text_no_scans => 'No scans yet';

  @override
  String get text_camera_error =>
      'Camera unavailable. Allow camera access in Settings.';

  @override
  String get text_sync_now => 'Sync now';

  @override
  String get text_pending => 'Pending';

  @override
  String text_logout_pending(int count) {
    return '$count scans haven\'t synced yet and will be lost. Log out anyway?';
  }

  @override
  String text_scanned_by_server(String result) {
    return 'Server: $result';
  }

  @override
  String get text_ready_to_scan => 'Ready to scan';

  @override
  String get text_scan_mode_qr => 'QR code';

  @override
  String get text_scan_mode_nfc => 'NFC tap';

  @override
  String get text_nfc_ready => 'Ready for taps';

  @override
  String get text_nfc_hold_hint =>
      'Hold a wristband or phone to the back of this phone';

  @override
  String get text_nfc_wristbands => 'Wristbands';

  @override
  String get text_nfc_phones => 'Phones';

  @override
  String get text_nfc_cards => 'Cards & stickers';

  @override
  String get text_nfc_off => 'NFC is turned off';

  @override
  String get text_nfc_off_hint => 'Turn on NFC to check tickets with a tap.';

  @override
  String get text_turn_on_nfc => 'Turn on NFC';

  @override
  String get text_nfc_unsupported =>
      'This phone has no NFC. Use QR scanning instead.';

  @override
  String get text_nfc_start_reading => 'Start reading';

  @override
  String get text_nfc_no_ticket => 'No EventPass ticket on this tag';

  @override
  String get text_nfc_check_in => 'Check in with NFC';

  @override
  String get text_tap_phone => 'Tap your phone';

  @override
  String get text_tap_phone_hint => 'Your phone becomes the ticket';

  @override
  String get text_save_to_wristband => 'Save to wristband';

  @override
  String get text_save_to_wristband_hint =>
      'Write it to an NFC band or sticker';

  @override
  String get text_tap_to_check_in => 'Tap to check in';

  @override
  String get text_tap_waiting =>
      'Hold the back of your phone to the gate phone';

  @override
  String get text_tap_step_open => 'Keep this screen open';

  @override
  String get text_tap_step_hold => 'Hold the phones back to back';

  @override
  String get text_tap_step_buzz => 'Wait for the buzz';

  @override
  String get text_tap_sent => 'Ticket sent to the gate';

  @override
  String get text_tap_waiting_confirm => 'Waiting for the gate to confirm…';

  @override
  String get text_tap_sent_offline =>
      'The gate has your ticket. It will confirm once it syncs.';

  @override
  String get text_youre_in => 'You\'re in!';

  @override
  String get text_tap_failed =>
      'This phone couldn\'t start NFC. Show your QR code instead.';

  @override
  String get text_write_waiting =>
      'Hold a blank NFC wristband or sticker to your phone';

  @override
  String get text_write_tag_size => 'Works with NTAG215 or larger';

  @override
  String get text_write_success => 'Saved! Tap the wristband at the gate.';

  @override
  String get text_write_too_small =>
      'This tag is too small for a ticket. Use an NTAG215 or larger.';

  @override
  String get text_write_read_only =>
      'This tag is locked and can\'t be written.';

  @override
  String get text_write_not_ndef =>
      'This tag isn\'t supported. Try an NFC sticker or wristband.';

  @override
  String get text_write_failed =>
      'Couldn\'t write the tag. Hold it still and try again.';

  @override
  String get text_checked_in_via_nfc => 'Checked in with an NFC tap';

  @override
  String get text_done => 'Done';

  @override
  String get text_settings => 'Settings';

  @override
  String get text_appearance => 'Appearance';

  @override
  String get text_theme_system => 'System';

  @override
  String get text_theme_light => 'Light';

  @override
  String get text_theme_dark => 'Dark';

  @override
  String get text_theme_system_hint => 'Matches your phone\'s setting';
}
