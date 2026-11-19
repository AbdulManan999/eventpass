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

  @override
  String get category_all => 'سب';

  @override
  String get category_tech => 'ٹیک';

  @override
  String get category_music => 'موسیقی';

  @override
  String get category_sports => 'کھیل';

  @override
  String get category_business => 'کاروبار';

  @override
  String get category_community => 'کمیونٹی';

  @override
  String get text_discover => 'اپنا اگلا ایونٹ تلاش کریں';

  @override
  String get text_search_events => 'ایونٹ یا مقام تلاش کریں';

  @override
  String get text_happening_now => 'ابھی جاری';

  @override
  String get text_upcoming => 'آنے والے';

  @override
  String get text_past => 'گزشتہ';

  @override
  String get text_live_now => 'ابھی جاری';

  @override
  String text_spots_left(int count) {
    return '$count جگہیں باقی';
  }

  @override
  String get text_sold_out => 'مکمل بک';

  @override
  String get text_no_matching_events => 'آپ کی تلاش سے کوئی ایونٹ نہیں ملا';

  @override
  String get text_about_event => 'اس ایونٹ کے بارے میں';

  @override
  String get text_date_time => 'تاریخ اور وقت';

  @override
  String get text_venue => 'مقام';

  @override
  String text_tickets_claimed(int issued, int capacity) {
    return '$capacity میں سے $issued ٹکٹ لیے جا چکے';
  }

  @override
  String text_self_checkin_zone(String distance) {
    return 'مقام کے $distance کے اندر خود چیک اِن ممکن ہے';
  }

  @override
  String get text_checked_in => 'چیک اِن ہو گیا';

  @override
  String text_checked_in_at(String time) {
    return '$time پر چیک اِن ہوا';
  }

  @override
  String get text_checked_in_via_qr => 'گیٹ پر اسکین ہوا';

  @override
  String get text_checked_in_via_geofence => 'لوکیشن سے خود چیک اِن';

  @override
  String text_starts_in(String time) {
    return '$time میں شروع';
  }

  @override
  String get text_ended => 'ختم';

  @override
  String get text_revoked => 'منسوخ';

  @override
  String get text_check_in_with_location => 'میری لوکیشن سے چیک اِن کریں';

  @override
  String get text_self_checkin_hint =>
      'مقام پر ہیں؟ فون سے چیک اِن کریں اور قطار سے بچیں۔';

  @override
  String get text_self_checkin_opens =>
      'خود چیک اِن آغاز سے 2 گھنٹے پہلے کھلتا ہے';

  @override
  String get text_welcome_in => 'آپ اندر ہیں! ایونٹ کا لطف اٹھائیں';

  @override
  String get text_already_checked_in => 'یہ ٹکٹ پہلے ہی چیک اِن ہو چکا ہے';

  @override
  String get text_location_disabled => 'چیک اِن کے لیے لوکیشن آن کریں';

  @override
  String get text_location_denied => 'چیک اِن کے لیے لوکیشن کی اجازت درکار ہے';

  @override
  String get text_location_denied_forever =>
      'لوکیشن کی اجازت بند ہے۔ سیٹنگز میں فعال کریں۔';

  @override
  String get text_open_settings => 'سیٹنگز کھولیں';

  @override
  String get text_scan => 'اسکین';

  @override
  String get text_gate_scanner => 'گیٹ اسکینر';

  @override
  String get text_staff_events_hint =>
      'وہ ایونٹس جن کے ٹکٹ آپ اسکین کر سکتے ہیں';

  @override
  String get text_no_staff_events =>
      'آپ ابھی کسی ایونٹ کے گیٹ اسٹاف نہیں ہیں۔ منتظم سے اپنی ای میل شامل کروائیں۔';

  @override
  String get text_role_organizer => 'منتظم';

  @override
  String get text_role_staff => 'اسٹاف';

  @override
  String get text_gate_name => 'گیٹ کا نام';

  @override
  String get text_gate_name_hint => 'مثلاً شمالی گیٹ';

  @override
  String get text_gate_name_help =>
      'اس فون کے اسکین منتظم کے ڈیش بورڈ پر اسی نام سے دکھائے جائیں گے۔';

  @override
  String get text_save => 'محفوظ کریں';

  @override
  String get text_admitted => 'داخلہ منظور';

  @override
  String get text_already_used => 'پہلے استعمال ہو چکا';

  @override
  String get text_invalid_ticket => 'غلط ٹکٹ';

  @override
  String get text_wrong_event => 'کسی اور ایونٹ کا ٹکٹ';

  @override
  String get text_point_camera => 'کیمرہ ٹکٹ کے QR کوڈ کی طرف کریں';

  @override
  String get text_rejected => 'مسترد';

  @override
  String get text_pending_sync => 'سنک باقی';

  @override
  String text_synced(String time) {
    return '$time سنک ہوا';
  }

  @override
  String get text_syncing => 'سنک ہو رہا ہے…';

  @override
  String get text_offline_mode => 'آف لائن: اسکین اس فون پر محفوظ ہیں';

  @override
  String get text_sync_failed => 'سنک ناکام۔ دوبارہ کوشش ہوگی۔';

  @override
  String text_verified_offline(int count) {
    return 'ایونٹ کی کلید سے اسی فون پر تصدیق · $count منسوخ';
  }

  @override
  String text_overruled(int count) {
    return 'یہاں داخل کیے گئے $count ٹکٹ پہلے کسی اور گیٹ پر استعمال ہو چکے تھے';
  }

  @override
  String get text_scan_history => 'اسکین کی تاریخ';

  @override
  String get text_no_scans => 'ابھی کوئی اسکین نہیں';

  @override
  String get text_camera_error =>
      'کیمرہ دستیاب نہیں۔ سیٹنگز میں کیمرے کی اجازت دیں۔';

  @override
  String get text_sync_now => 'ابھی سنک کریں';

  @override
  String get text_pending => 'باقی';

  @override
  String text_logout_pending(int count) {
    return '$count اسکین ابھی سنک نہیں ہوئے اور ضائع ہو جائیں گے۔ پھر بھی لاگ آؤٹ کریں؟';
  }

  @override
  String text_scanned_by_server(String result) {
    return 'سرور: $result';
  }

  @override
  String get text_ready_to_scan => 'اسکین کے لیے تیار';

  @override
  String get text_scan_mode_qr => 'کیو آر کوڈ';

  @override
  String get text_scan_mode_nfc => 'این ایف سی ٹیپ';

  @override
  String get text_nfc_ready => 'ٹیپ کے لیے تیار';

  @override
  String get text_nfc_hold_hint => 'رسٹ بینڈ یا فون اس فون کی پشت سے لگائیں';

  @override
  String get text_nfc_wristbands => 'رسٹ بینڈ';

  @override
  String get text_nfc_phones => 'فون';

  @override
  String get text_nfc_cards => 'کارڈ اور اسٹیکر';

  @override
  String get text_nfc_off => 'این ایف سی بند ہے';

  @override
  String get text_nfc_off_hint =>
      'ٹیپ سے ٹکٹ چیک کرنے کے لیے این ایف سی آن کریں۔';

  @override
  String get text_turn_on_nfc => 'این ایف سی آن کریں';

  @override
  String get text_nfc_unsupported =>
      'اس فون میں این ایف سی نہیں ہے۔ اس کے بجائے کیو آر اسکین کریں۔';

  @override
  String get text_nfc_start_reading => 'پڑھنا شروع کریں';

  @override
  String get text_nfc_no_ticket => 'اس ٹیگ پر کوئی ایونٹ پاس ٹکٹ نہیں';

  @override
  String get text_nfc_check_in => 'این ایف سی سے چیک ان';

  @override
  String get text_tap_phone => 'اپنا فون ٹیپ کریں';

  @override
  String get text_tap_phone_hint => 'آپ کا فون ہی ٹکٹ بن جاتا ہے';

  @override
  String get text_save_to_wristband => 'رسٹ بینڈ میں محفوظ کریں';

  @override
  String get text_save_to_wristband_hint =>
      'اسے این ایف سی بینڈ یا اسٹیکر پر لکھیں';

  @override
  String get text_tap_to_check_in => 'چیک ان کے لیے ٹیپ کریں';

  @override
  String get text_tap_waiting => 'اپنے فون کی پشت گیٹ والے فون سے لگائیں';

  @override
  String get text_tap_step_open => 'یہ اسکرین کھلی رکھیں';

  @override
  String get text_tap_step_hold => 'دونوں فون پشت سے پشت ملائیں';

  @override
  String get text_tap_step_buzz => 'وائبریشن کا انتظار کریں';

  @override
  String get text_tap_sent => 'ٹکٹ گیٹ کو بھیج دیا گیا';

  @override
  String get text_tap_waiting_confirm => 'گیٹ کی تصدیق کا انتظار…';

  @override
  String get text_tap_sent_offline =>
      'گیٹ کو آپ کا ٹکٹ مل گیا ہے۔ سنک ہونے پر تصدیق ہو جائے گی۔';

  @override
  String get text_youre_in => 'آپ اندر ہیں!';

  @override
  String get text_tap_failed =>
      'یہ فون این ایف سی شروع نہیں کر سکا۔ اس کے بجائے اپنا کیو آر کوڈ دکھائیں۔';

  @override
  String get text_write_waiting =>
      'خالی این ایف سی رسٹ بینڈ یا اسٹیکر اپنے فون سے لگائیں';

  @override
  String get text_write_tag_size =>
      'NTAG215 یا اس سے بڑے ٹیگ کے ساتھ کام کرتا ہے';

  @override
  String get text_write_success => 'محفوظ ہو گیا! گیٹ پر رسٹ بینڈ ٹیپ کریں۔';

  @override
  String get text_write_too_small =>
      'یہ ٹیگ ٹکٹ کے لیے بہت چھوٹا ہے۔ NTAG215 یا اس سے بڑا استعمال کریں۔';

  @override
  String get text_write_read_only =>
      'یہ ٹیگ لاک ہے اور اس پر لکھا نہیں جا سکتا۔';

  @override
  String get text_write_not_ndef =>
      'یہ ٹیگ سپورٹڈ نہیں۔ این ایف سی اسٹیکر یا رسٹ بینڈ آزمائیں۔';

  @override
  String get text_write_failed =>
      'ٹیگ پر نہیں لکھا جا سکا۔ اسے ساکن رکھیں اور دوبارہ کوشش کریں۔';

  @override
  String get text_checked_in_via_nfc => 'این ایف سی ٹیپ سے چیک ان ہوا';

  @override
  String get text_done => 'ہو گیا';

  @override
  String get text_settings => 'ترتیبات';

  @override
  String get text_appearance => 'ظاہری شکل';

  @override
  String get text_theme_system => 'سسٹم';

  @override
  String get text_theme_light => 'لائٹ';

  @override
  String get text_theme_dark => 'ڈارک';

  @override
  String get text_theme_system_hint => 'آپ کے فون کی ترتیب کے مطابق';
}
