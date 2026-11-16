import 'package:flutter/material.dart';
import 'package:eventpass/l10n/app_localizations.dart';

/// Colour, gradient and icon per event category. Matches the admin dashboard.
class CategoryStyle {
  const CategoryStyle(this.color, this.gradient, this.icon);

  final Color color;
  final List<Color> gradient;
  final IconData icon;

  static const categories = ['tech', 'music', 'sports', 'business', 'community'];

  static CategoryStyle of(String category) => switch (category) {
        'music' => const CategoryStyle(Color(0xFFBE185D), [Color(0xFFDB2777), Color(0xFF7C3AED)], Icons.music_note_rounded),
        'sports' => const CategoryStyle(Color(0xFF047857), [Color(0xFF059669), Color(0xFF0D9488)], Icons.directions_run_rounded),
        'business' => const CategoryStyle(Color(0xFFB45309), [Color(0xFFF59E0B), Color(0xFFEA580C)], Icons.trending_up_rounded),
        'community' => const CategoryStyle(Color(0xFF0369A1), [Color(0xFF0EA5E9), Color(0xFF2563EB)], Icons.groups_rounded),
        _ => const CategoryStyle(Color(0xFF4338CA), [Color(0xFF6366F1), Color(0xFF4338CA)], Icons.memory_rounded),
      };

  static String label(AppLocalizations loc, String category) => switch (category) {
        'music' => loc.category_music,
        'sports' => loc.category_sports,
        'business' => loc.category_business,
        'community' => loc.category_community,
        'all' => loc.category_all,
        _ => loc.category_tech,
      };

  LinearGradient get linearGradient =>
      LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight);
}
