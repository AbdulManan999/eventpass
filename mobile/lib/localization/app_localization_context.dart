import 'package:flutter/widgets.dart';
import 'package:eventpass/l10n/app_localizations.dart';

/// Short-hand for translated strings:  Text(context.loc.text_welcome_back)
extension LocalizedBuildContext on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;

  bool get isUrdu => Localizations.localeOf(this).languageCode == 'ur';
}
