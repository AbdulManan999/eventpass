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
}
