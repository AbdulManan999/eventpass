import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventpass/models/User.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/constants.dart';

/// Static helpers: session persistence (SharedPreferences), validation, formatting.
class Utils {
  Utils._();

  // ── Access token ────────────────────────────────────────────────────────
  static Future<void> setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.prefToken, token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.prefToken);
  }

  static Future<void> removeAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.prefToken);
  }

  // ── Gate name (scanner device id) ──────────────────────────────────────
  static Future<void> setGateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.prefGateName, name);
  }

  static Future<String> getGateName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(Constants.prefGateName)?.trim();
    return (name == null || name.isEmpty) ? Constants.defaultGateName : name;
  }

  // ── Appearance and language (device settings, survive logout) ─────────
  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.prefThemeMode, mode.name);
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(Constants.prefThemeMode);
    return ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
  }

  /// Null follows the device language.
  static Future<void> setLanguage(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    code == null ? await prefs.remove(Constants.prefLanguage) : await prefs.setString(Constants.prefLanguage, code);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.prefLanguage);
  }

  // ── Logged-in flag ──────────────────────────────────────────────────────
  static Future<void> setIsLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.prefIsLoggedIn, value);
  }

  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Constants.prefIsLoggedIn) ?? false;
  }

  static Future<void> removeIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.prefIsLoggedIn);
  }

  // ── Logged-in user (stored as JSON) ─────────────────────────────────────
  static Future<void> setUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.prefUserData, jsonEncode(user.toJson()));
  }

  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(Constants.prefUserData);
    if (data == null || data.isEmpty) return null;
    return User.fromJson(jsonDecode(data));
  }

  static Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.prefUserData);
  }

  /// Clears the session and returns to login. For also resetting in-memory
  /// providers call `ref.read(authRepository).removeAllData()` first.
  static Future<void> logoutUser(BuildContext context) async {
    await removeAccessToken();
    await removeUserData();
    await removeIsLoggedIn();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.LOGIN, (_) => false);
    }
  }

  // ── Validation / formatting ─────────────────────────────────────────────
  static String? validateFields(String? value, {required String errorText}) {
    if (value == null || value.trim().isEmpty) return errorText;
    return null;
  }

  static String? validateEmail(String? value, {required String requiredText, required String invalidText}) {
    if (value == null || value.trim().isEmpty) return requiredText;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim()) ? null : invalidText;
  }

  static String formatDate(String? isoDate, {String pattern = 'dd MMM yyyy'}) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final parsed = DateTime.tryParse(isoDate);
    return parsed == null ? isoDate : DateFormat(pattern).format(parsed.toLocal());
  }

  /// Compact countdown: "2d 4h", "3h 20m" or "12m".
  static String formatCountdown(Duration d) {
    if (d.isNegative) return '0m';
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes.clamp(1, 59)}m';
  }
}
