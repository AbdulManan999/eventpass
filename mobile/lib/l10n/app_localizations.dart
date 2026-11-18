import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @text_welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get text_welcome_back;

  /// No description provided for @text_login_description.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your tickets'**
  String get text_login_description;

  /// No description provided for @text_create_account.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get text_create_account;

  /// No description provided for @text_register_description.
  ///
  /// In en, this message translates to:
  /// **'Get tickets in seconds. They work even without signal.'**
  String get text_register_description;

  /// No description provided for @email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_label;

  /// No description provided for @email_hint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get email_hint;

  /// No description provided for @email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get email_required;

  /// No description provided for @email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get email_invalid;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get password_required;

  /// No description provided for @password_min.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get password_min;

  /// No description provided for @name_label.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get name_label;

  /// No description provided for @name_hint.
  ///
  /// In en, this message translates to:
  /// **'As it should appear on your ticket'**
  String get name_hint;

  /// No description provided for @name_required.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get name_required;

  /// No description provided for @text_login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get text_login;

  /// No description provided for @text_register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get text_register;

  /// No description provided for @text_no_account.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get text_no_account;

  /// No description provided for @text_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get text_have_account;

  /// No description provided for @text_events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get text_events;

  /// No description provided for @text_my_tickets.
  ///
  /// In en, this message translates to:
  /// **'My tickets'**
  String get text_my_tickets;

  /// No description provided for @text_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get text_profile;

  /// No description provided for @text_logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get text_logout;

  /// No description provided for @text_dialog_logout.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out? Saved tickets will be removed from this device.'**
  String get text_dialog_logout;

  /// No description provided for @text_no_events.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events yet'**
  String get text_no_events;

  /// No description provided for @text_no_tickets.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any tickets yet'**
  String get text_no_tickets;

  /// No description provided for @text_browse_events.
  ///
  /// In en, this message translates to:
  /// **'Browse events'**
  String get text_browse_events;

  /// No description provided for @text_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get text_retry;

  /// No description provided for @text_get_ticket.
  ///
  /// In en, this message translates to:
  /// **'Get ticket'**
  String get text_get_ticket;

  /// No description provided for @text_view_ticket.
  ///
  /// In en, this message translates to:
  /// **'View my ticket'**
  String get text_view_ticket;

  /// No description provided for @text_capacity.
  ///
  /// In en, this message translates to:
  /// **'{count} seats'**
  String text_capacity(int count);

  /// No description provided for @text_offline_tickets.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing saved tickets; they still scan at the gate.'**
  String get text_offline_tickets;

  /// No description provided for @text_show_at_gate.
  ///
  /// In en, this message translates to:
  /// **'Show this code at the entrance'**
  String get text_show_at_gate;

  /// No description provided for @text_ticket_revoked.
  ///
  /// In en, this message translates to:
  /// **'This ticket has been cancelled by the organizer'**
  String get text_ticket_revoked;

  /// No description provided for @text_ticket_ready.
  ///
  /// In en, this message translates to:
  /// **'Ticket ready'**
  String get text_ticket_ready;

  /// No description provided for @text_session_expired_title.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get text_session_expired_title;

  /// No description provided for @text_session_expired_message.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get text_session_expired_message;

  /// No description provided for @text_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get text_ok;

  /// No description provided for @text_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get text_close;

  /// No description provided for @text_signed_in_as.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get text_signed_in_as;

  /// No description provided for @text_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get text_language;

  /// No description provided for @text_hello_user.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String text_hello_user(String name);

  /// No description provided for @category_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get category_all;

  /// No description provided for @category_tech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get category_tech;

  /// No description provided for @category_music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get category_music;

  /// No description provided for @category_sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get category_sports;

  /// No description provided for @category_business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get category_business;

  /// No description provided for @category_community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get category_community;

  /// No description provided for @text_discover.
  ///
  /// In en, this message translates to:
  /// **'Find your next event'**
  String get text_discover;

  /// No description provided for @text_search_events.
  ///
  /// In en, this message translates to:
  /// **'Search events or venues'**
  String get text_search_events;

  /// No description provided for @text_happening_now.
  ///
  /// In en, this message translates to:
  /// **'Happening now'**
  String get text_happening_now;

  /// No description provided for @text_upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get text_upcoming;

  /// No description provided for @text_past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get text_past;

  /// No description provided for @text_live_now.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get text_live_now;

  /// No description provided for @text_spots_left.
  ///
  /// In en, this message translates to:
  /// **'{count} spots left'**
  String text_spots_left(int count);

  /// No description provided for @text_sold_out.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get text_sold_out;

  /// No description provided for @text_no_matching_events.
  ///
  /// In en, this message translates to:
  /// **'No events match your search'**
  String get text_no_matching_events;

  /// No description provided for @text_about_event.
  ///
  /// In en, this message translates to:
  /// **'About this event'**
  String get text_about_event;

  /// No description provided for @text_date_time.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get text_date_time;

  /// No description provided for @text_venue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get text_venue;

  /// No description provided for @text_tickets_claimed.
  ///
  /// In en, this message translates to:
  /// **'{issued} of {capacity} tickets claimed'**
  String text_tickets_claimed(int issued, int capacity);

  /// No description provided for @text_self_checkin_zone.
  ///
  /// In en, this message translates to:
  /// **'Self check-in works within {distance} of the venue'**
  String text_self_checkin_zone(String distance);

  /// No description provided for @text_checked_in.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get text_checked_in;

  /// No description provided for @text_checked_in_at.
  ///
  /// In en, this message translates to:
  /// **'Checked in at {time}'**
  String text_checked_in_at(String time);

  /// No description provided for @text_checked_in_via_qr.
  ///
  /// In en, this message translates to:
  /// **'Scanned at the gate'**
  String get text_checked_in_via_qr;

  /// No description provided for @text_checked_in_via_geofence.
  ///
  /// In en, this message translates to:
  /// **'Self check-in with location'**
  String get text_checked_in_via_geofence;

  /// No description provided for @text_starts_in.
  ///
  /// In en, this message translates to:
  /// **'Starts in {time}'**
  String text_starts_in(String time);

  /// No description provided for @text_ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get text_ended;

  /// No description provided for @text_revoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get text_revoked;

  /// No description provided for @text_check_in_with_location.
  ///
  /// In en, this message translates to:
  /// **'Check in with my location'**
  String get text_check_in_with_location;

  /// No description provided for @text_self_checkin_hint.
  ///
  /// In en, this message translates to:
  /// **'At the venue? Check in from your phone and skip the queue.'**
  String get text_self_checkin_hint;

  /// No description provided for @text_self_checkin_opens.
  ///
  /// In en, this message translates to:
  /// **'Self check-in opens 2 hours before the start'**
  String get text_self_checkin_opens;

  /// No description provided for @text_welcome_in.
  ///
  /// In en, this message translates to:
  /// **'You\'re in! Enjoy the event'**
  String get text_welcome_in;

  /// No description provided for @text_already_checked_in.
  ///
  /// In en, this message translates to:
  /// **'This ticket was already checked in'**
  String get text_already_checked_in;

  /// No description provided for @text_location_disabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to check in'**
  String get text_location_disabled;

  /// No description provided for @text_location_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to check in'**
  String get text_location_denied;

  /// No description provided for @text_location_denied_forever.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. Enable it in Settings.'**
  String get text_location_denied_forever;

  /// No description provided for @text_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get text_open_settings;

  /// No description provided for @text_scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get text_scan;

  /// No description provided for @text_gate_scanner.
  ///
  /// In en, this message translates to:
  /// **'Gate scanner'**
  String get text_gate_scanner;

  /// No description provided for @text_staff_events_hint.
  ///
  /// In en, this message translates to:
  /// **'Events you can scan tickets for'**
  String get text_staff_events_hint;

  /// No description provided for @text_no_staff_events.
  ///
  /// In en, this message translates to:
  /// **'You\'re not gate staff for any event yet. Ask the organizer to add your email.'**
  String get text_no_staff_events;

  /// No description provided for @text_role_organizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get text_role_organizer;

  /// No description provided for @text_role_staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get text_role_staff;

  /// No description provided for @text_gate_name.
  ///
  /// In en, this message translates to:
  /// **'Gate name'**
  String get text_gate_name;

  /// No description provided for @text_gate_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. North gate'**
  String get text_gate_name_hint;

  /// No description provided for @text_gate_name_help.
  ///
  /// In en, this message translates to:
  /// **'Shown on the organizer\'s dashboard for scans from this phone.'**
  String get text_gate_name_help;

  /// No description provided for @text_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get text_save;

  /// No description provided for @text_admitted.
  ///
  /// In en, this message translates to:
  /// **'Admitted'**
  String get text_admitted;

  /// No description provided for @text_already_used.
  ///
  /// In en, this message translates to:
  /// **'Already used'**
  String get text_already_used;

  /// No description provided for @text_invalid_ticket.
  ///
  /// In en, this message translates to:
  /// **'Invalid ticket'**
  String get text_invalid_ticket;

  /// No description provided for @text_wrong_event.
  ///
  /// In en, this message translates to:
  /// **'Ticket for another event'**
  String get text_wrong_event;

  /// No description provided for @text_point_camera.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a ticket QR code'**
  String get text_point_camera;

  /// No description provided for @text_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get text_rejected;

  /// No description provided for @text_pending_sync.
  ///
  /// In en, this message translates to:
  /// **'To sync'**
  String get text_pending_sync;

  /// No description provided for @text_synced.
  ///
  /// In en, this message translates to:
  /// **'Synced {time}'**
  String text_synced(String time);

  /// No description provided for @text_syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get text_syncing;

  /// No description provided for @text_offline_mode.
  ///
  /// In en, this message translates to:
  /// **'Offline: scans are saved on this phone'**
  String get text_offline_mode;

  /// No description provided for @text_sync_failed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Will retry.'**
  String get text_sync_failed;

  /// No description provided for @text_verified_offline.
  ///
  /// In en, this message translates to:
  /// **'Verified on this phone with the event\'s key · {count} revoked'**
  String text_verified_offline(int count);

  /// No description provided for @text_overruled.
  ///
  /// In en, this message translates to:
  /// **'{count} admitted here had already been used at another gate'**
  String text_overruled(int count);

  /// No description provided for @text_scan_history.
  ///
  /// In en, this message translates to:
  /// **'Scan history'**
  String get text_scan_history;

  /// No description provided for @text_no_scans.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get text_no_scans;

  /// No description provided for @text_camera_error.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Allow camera access in Settings.'**
  String get text_camera_error;

  /// No description provided for @text_sync_now.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get text_sync_now;

  /// No description provided for @text_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get text_pending;

  /// No description provided for @text_logout_pending.
  ///
  /// In en, this message translates to:
  /// **'{count} scans haven\'t synced yet and will be lost. Log out anyway?'**
  String text_logout_pending(int count);

  /// No description provided for @text_scanned_by_server.
  ///
  /// In en, this message translates to:
  /// **'Server: {result}'**
  String text_scanned_by_server(String result);

  /// No description provided for @text_ready_to_scan.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get text_ready_to_scan;

  /// No description provided for @text_scan_mode_qr.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get text_scan_mode_qr;

  /// No description provided for @text_scan_mode_nfc.
  ///
  /// In en, this message translates to:
  /// **'NFC tap'**
  String get text_scan_mode_nfc;

  /// No description provided for @text_nfc_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready for taps'**
  String get text_nfc_ready;

  /// No description provided for @text_nfc_hold_hint.
  ///
  /// In en, this message translates to:
  /// **'Hold a wristband or phone to the back of this phone'**
  String get text_nfc_hold_hint;

  /// No description provided for @text_nfc_wristbands.
  ///
  /// In en, this message translates to:
  /// **'Wristbands'**
  String get text_nfc_wristbands;

  /// No description provided for @text_nfc_phones.
  ///
  /// In en, this message translates to:
  /// **'Phones'**
  String get text_nfc_phones;

  /// No description provided for @text_nfc_cards.
  ///
  /// In en, this message translates to:
  /// **'Cards & stickers'**
  String get text_nfc_cards;

  /// No description provided for @text_nfc_off.
  ///
  /// In en, this message translates to:
  /// **'NFC is turned off'**
  String get text_nfc_off;

  /// No description provided for @text_nfc_off_hint.
  ///
  /// In en, this message translates to:
  /// **'Turn on NFC to check tickets with a tap.'**
  String get text_nfc_off_hint;

  /// No description provided for @text_turn_on_nfc.
  ///
  /// In en, this message translates to:
  /// **'Turn on NFC'**
  String get text_turn_on_nfc;

  /// No description provided for @text_nfc_unsupported.
  ///
  /// In en, this message translates to:
  /// **'This phone has no NFC. Use QR scanning instead.'**
  String get text_nfc_unsupported;

  /// No description provided for @text_nfc_start_reading.
  ///
  /// In en, this message translates to:
  /// **'Start reading'**
  String get text_nfc_start_reading;

  /// No description provided for @text_nfc_no_ticket.
  ///
  /// In en, this message translates to:
  /// **'No EventPass ticket on this tag'**
  String get text_nfc_no_ticket;

  /// No description provided for @text_nfc_check_in.
  ///
  /// In en, this message translates to:
  /// **'Check in with NFC'**
  String get text_nfc_check_in;

  /// No description provided for @text_tap_phone.
  ///
  /// In en, this message translates to:
  /// **'Tap your phone'**
  String get text_tap_phone;

  /// No description provided for @text_tap_phone_hint.
  ///
  /// In en, this message translates to:
  /// **'Your phone becomes the ticket'**
  String get text_tap_phone_hint;

  /// No description provided for @text_save_to_wristband.
  ///
  /// In en, this message translates to:
  /// **'Save to wristband'**
  String get text_save_to_wristband;

  /// No description provided for @text_save_to_wristband_hint.
  ///
  /// In en, this message translates to:
  /// **'Write it to an NFC band or sticker'**
  String get text_save_to_wristband_hint;

  /// No description provided for @text_tap_to_check_in.
  ///
  /// In en, this message translates to:
  /// **'Tap to check in'**
  String get text_tap_to_check_in;

  /// No description provided for @text_tap_waiting.
  ///
  /// In en, this message translates to:
  /// **'Hold the back of your phone to the gate phone'**
  String get text_tap_waiting;

  /// No description provided for @text_tap_step_open.
  ///
  /// In en, this message translates to:
  /// **'Keep this screen open'**
  String get text_tap_step_open;

  /// No description provided for @text_tap_step_hold.
  ///
  /// In en, this message translates to:
  /// **'Hold the phones back to back'**
  String get text_tap_step_hold;

  /// No description provided for @text_tap_step_buzz.
  ///
  /// In en, this message translates to:
  /// **'Wait for the buzz'**
  String get text_tap_step_buzz;

  /// No description provided for @text_tap_sent.
  ///
  /// In en, this message translates to:
  /// **'Ticket sent to the gate'**
  String get text_tap_sent;

  /// No description provided for @text_tap_waiting_confirm.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the gate to confirm…'**
  String get text_tap_waiting_confirm;

  /// No description provided for @text_tap_sent_offline.
  ///
  /// In en, this message translates to:
  /// **'The gate has your ticket. It will confirm once it syncs.'**
  String get text_tap_sent_offline;

  /// No description provided for @text_youre_in.
  ///
  /// In en, this message translates to:
  /// **'You\'re in!'**
  String get text_youre_in;

  /// No description provided for @text_tap_failed.
  ///
  /// In en, this message translates to:
  /// **'This phone couldn\'t start NFC. Show your QR code instead.'**
  String get text_tap_failed;

  /// No description provided for @text_write_waiting.
  ///
  /// In en, this message translates to:
  /// **'Hold a blank NFC wristband or sticker to your phone'**
  String get text_write_waiting;

  /// No description provided for @text_write_tag_size.
  ///
  /// In en, this message translates to:
  /// **'Works with NTAG215 or larger'**
  String get text_write_tag_size;

  /// No description provided for @text_write_success.
  ///
  /// In en, this message translates to:
  /// **'Saved! Tap the wristband at the gate.'**
  String get text_write_success;

  /// No description provided for @text_write_too_small.
  ///
  /// In en, this message translates to:
  /// **'This tag is too small for a ticket. Use an NTAG215 or larger.'**
  String get text_write_too_small;

  /// No description provided for @text_write_read_only.
  ///
  /// In en, this message translates to:
  /// **'This tag is locked and can\'t be written.'**
  String get text_write_read_only;

  /// No description provided for @text_write_not_ndef.
  ///
  /// In en, this message translates to:
  /// **'This tag isn\'t supported. Try an NFC sticker or wristband.'**
  String get text_write_not_ndef;

  /// No description provided for @text_write_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t write the tag. Hold it still and try again.'**
  String get text_write_failed;

  /// No description provided for @text_checked_in_via_nfc.
  ///
  /// In en, this message translates to:
  /// **'Checked in with an NFC tap'**
  String get text_checked_in_via_nfc;

  /// No description provided for @text_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get text_done;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
