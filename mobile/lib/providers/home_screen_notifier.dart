import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/models/User.dart';

/// Home module UI state: selected bottom-navigation tab and the signed-in user.
final navigationIndexProvider = StateProvider<int>((ref) => 0, name: 'navigationIndexProvider');
final currentUserProvider = StateProvider<User?>((ref) => null, name: 'currentUserProvider');

/// App language; null follows the device. Toggled from the Profile tab.
final localeProvider = StateProvider<Locale?>((ref) => null, name: 'localeProvider');
