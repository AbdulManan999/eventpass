import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/models/User.dart';

/// Home module UI state: selected bottom-navigation tab and the signed-in user.
final navigationIndexProvider = StateProvider<int>((ref) => 0, name: 'navigationIndexProvider');
final currentUserProvider = StateProvider<User?>((ref) => null, name: 'currentUserProvider');

/// App language; null follows the device. Chosen in Profile → Settings, saved
/// by [Utils.setLanguage] and restored in main() before the first frame.
final localeProvider = StateProvider<Locale?>((ref) => null, name: 'localeProvider');

/// Light, dark, or follow the phone. Chosen in Profile → Settings, saved by
/// [Utils.setThemeMode] and restored in main() so the first frame is right.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system, name: 'themeModeProvider');
