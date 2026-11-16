// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get text_welcome_back => 'خوش آمدید';

  @override
  String get text_login_description => 'اپنے ٹکٹ دیکھنے کے لیے لاگ ان کریں';

  @override
  String get text_create_account => 'اکاؤنٹ بنائیں';

  @override
  String get text_register_description =>
      'سیکنڈوں میں ٹکٹ حاصل کریں۔ یہ سگنل کے بغیر بھی کام کرتے ہیں۔';

  @override
  String get email_label => 'ای میل';

  @override
  String get email_hint => 'you@example.com';

  @override
  String get email_required => 'ای میل درکار ہے';

  @override
  String get email_invalid => 'درست ای میل درج کریں';

  @override
  String get password_label => 'پاس ورڈ';

  @override
  String get password_required => 'پاس ورڈ درکار ہے';

  @override
  String get password_min => 'کم از کم 8 حروف استعمال کریں';

  @override
  String get name_label => 'پورا نام';

  @override
  String get name_hint => 'جیسا ٹکٹ پر ہونا چاہیے';

  @override
  String get name_required => 'نام درکار ہے';

  @override
  String get text_login => 'لاگ ان';

  @override
  String get text_register => 'اکاؤنٹ بنائیں';

  @override
  String get text_no_account => 'نئے ہیں؟ اکاؤنٹ بنائیں';

  @override
  String get text_have_account => 'پہلے سے اکاؤنٹ ہے؟ لاگ ان کریں';

  @override
  String get text_events => 'ایونٹس';

  @override
  String get text_my_tickets => 'میرے ٹکٹ';

  @override
  String get text_profile => 'پروفائل';

  @override
  String get text_logout => 'لاگ آؤٹ';

  @override
  String get text_dialog_logout =>
      'کیا آپ لاگ آؤٹ کرنا چاہتے ہیں؟ محفوظ ٹکٹ اس ڈیوائس سے ہٹا دیے جائیں گے۔';

  @override
  String get text_no_events => 'ابھی کوئی آنے والا ایونٹ نہیں';

  @override
  String get text_no_tickets => 'آپ کے پاس ابھی کوئی ٹکٹ نہیں';

  @override
  String get text_browse_events => 'ایونٹس دیکھیں';

  @override
  String get text_retry => 'دوبارہ کوشش کریں';

  @override
  String get text_get_ticket => 'ٹکٹ حاصل کریں';

  @override
  String get text_view_ticket => 'میرا ٹکٹ دیکھیں';

  @override
  String text_capacity(int count) {
    return '$count نشستیں';
  }

  @override
  String get text_offline_tickets =>
      'آپ آف لائن ہیں۔ محفوظ ٹکٹ دکھائے جا رہے ہیں؛ یہ گیٹ پر پھر بھی اسکین ہوں گے۔';

  @override
  String get text_show_at_gate => 'داخلے پر یہ کوڈ دکھائیں';

  @override
  String get text_ticket_revoked => 'یہ ٹکٹ منتظم نے منسوخ کر دیا ہے';

  @override
  String get text_ticket_ready => 'ٹکٹ تیار ہے';

  @override
  String get text_session_expired_title => 'سیشن ختم ہو گیا';

  @override
  String get text_session_expired_message => 'براہ کرم دوبارہ لاگ ان کریں۔';

  @override
  String get text_ok => 'ٹھیک ہے';

  @override
  String get text_close => 'بند کریں';

  @override
  String get text_signed_in_as => 'بطور لاگ ان';

  @override
  String get text_language => 'زبان';

  @override
  String text_hello_user(String name) {
    return 'السلام علیکم، $name';
  }
}
