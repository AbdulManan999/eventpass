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
