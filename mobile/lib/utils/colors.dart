import 'package:flutter/material.dart';

/// Single source of truth for colours. theme.dart and all widgets import this.
const Color primaryColor = Color(0xFF4338CA);
const Color primaryDarkColor = Color(0xFF312E81);
const Color primaryLightColor = Color(0xFFEEF2FF);
const Color secondaryColor = Color(0xFF0D9488);

const Color headingColor = Color(0xFF111827);
const Color textColor = Color(0xFF374151);
const Color hintColor = Color(0xFF6B7280);
const Color labelColor = Color(0xFF4B5563);

const Color whiteColor = Colors.white;
const Color blackColor = Color(0xFF030712);
const Color redColor = Color(0xFFDC2626);
const Color greenColor = Color(0xFF16A34A);
const Color amberColor = Color(0xFFD97706);
const Color greyColor = Color(0xFFE5E7EB);

const Color backgroundColor = Color(0xFFF8FAFC);
const Color textFieldBorderColor = Color(0xFFD1D5DB);
const Color textFieldFillColor = Color(0xFFFFFFFF);
const Color shadowColor = Color(0xFFE5E7EB);

/// The gate scanner is always dark (it's used in bright and dim venues alike).
const Color darkBackgroundColor = Color(0xFF111827);
const Color darkSurfaceColor = Color(0xFF1F2937);
const Color darkModeTextColor = Color(0xFFD1D5DB);

/// Dark mode: deep navy rather than pure black, with an indigo tint.
const Color nightBackgroundColor = Color(0xFF0B1020);
const Color nightSurfaceColor = Color(0xFF151B2E);
const Color nightSurfaceHighColor = Color(0xFF1E2640);
const Color nightBorderColor = Color(0xFF2A3350);
const Color nightPrimaryColor = Color(0xFF6366F1);
const Color nightPrimarySoftColor = Color(0xFF262A5C);
const Color nightOnPrimarySoftColor = Color(0xFFC7D2FE);

/// Colours that change between light and dark mode. Screens read these via
/// `context.palette` instead of the raw constants above, so they follow the
/// theme the user picked in Settings.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.heading,
    required this.body,
    required this.label,
    required this.hint,
    required this.primarySoft,
    required this.onPrimarySoft,
    required this.inputFill,
    required this.inputBorder,
  });

  final Color background;

  /// Cards, sheets, the search field.
  final Color surface;

  /// Raised elements on a surface (selected chips, previews).
  final Color surfaceHigh;
  final Color border;
  final Color heading;
  final Color body;
  final Color label;
  final Color hint;

  /// Tinted backgrounds for icons and badges, with [onPrimarySoft] on top.
  final Color primarySoft;
  final Color onPrimarySoft;
  final Color inputFill;
  final Color inputBorder;

  static const light = AppPalette(
    background: backgroundColor,
    surface: whiteColor,
    surfaceHigh: Color(0xFFF1F5F9),
    border: greyColor,
    heading: headingColor,
    body: textColor,
    label: labelColor,
    hint: hintColor,
    primarySoft: primaryLightColor,
    onPrimarySoft: primaryColor,
    inputFill: textFieldFillColor,
    inputBorder: textFieldBorderColor,
  );

  static const dark = AppPalette(
    background: nightBackgroundColor,
    surface: nightSurfaceColor,
    surfaceHigh: nightSurfaceHighColor,
    border: nightBorderColor,
    heading: Color(0xFFF8FAFC),
    body: Color(0xFFCBD5E1),
    label: Color(0xFFA3B0C6),
    hint: Color(0xFF8391AB),
    primarySoft: nightPrimarySoftColor,
    onPrimarySoft: nightOnPrimarySoftColor,
    inputFill: nightSurfaceColor,
    inputBorder: nightBorderColor,
  );

  @override
  AppPalette copyWith() => this;

  /// Blends every colour, so switching themes animates smoothly.
  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceHigh: l(surfaceHigh, other.surfaceHigh),
      border: l(border, other.border),
      heading: l(heading, other.heading),
      body: l(body, other.body),
      label: l(label, other.label),
      hint: l(hint, other.hint),
      primarySoft: l(primarySoft, other.primarySoft),
      onPrimarySoft: l(onPrimarySoft, other.onPrimarySoft),
      inputFill: l(inputFill, other.inputFill),
      inputBorder: l(inputBorder, other.inputBorder),
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Brand and category colours are tuned for white backgrounds; on dark
  /// surfaces they're lightened so text and icons keep their contrast.
  Color accent(Color color) => isDark ? Color.lerp(color, Colors.white, 0.42)! : color;
}
