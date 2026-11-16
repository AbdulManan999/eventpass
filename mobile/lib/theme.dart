import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventpass/utils/colors.dart';

/// Fonts come from google_fonts, so no font files need to be bundled.
final String kHeadingFont = GoogleFonts.poppins().fontFamily!;
final String kBodyFont = GoogleFonts.inter().fontFamily!;

final ThemeData lightThemeData = _buildLightTheme();
final ThemeData darkThemeData = _buildDarkTheme();

TextTheme _buildTextTheme(TextTheme base, {required Color heading, required Color body}) {
  return base.copyWith(
    headlineLarge: base.headlineLarge?.copyWith(
      fontFamily: kHeadingFont,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      color: heading,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontFamily: kHeadingFont,
      fontWeight: FontWeight.w600,
      fontSize: 26,
      color: heading,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontFamily: kHeadingFont,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: heading,
    ),
    titleLarge: base.titleLarge?.copyWith(fontFamily: kBodyFont, color: body),
    titleMedium: base.titleMedium?.copyWith(fontFamily: kBodyFont, color: body),
    titleSmall: base.titleSmall?.copyWith(fontFamily: kBodyFont, color: body),
    bodyLarge: base.bodyLarge?.copyWith(fontFamily: kBodyFont, fontSize: 16, color: body),
    bodyMedium: base.bodyMedium?.copyWith(fontFamily: kBodyFont, fontSize: 14, color: body),
    bodySmall: base.bodySmall?.copyWith(fontFamily: kBodyFont, fontSize: 12, color: body),
  );
}

ThemeData _buildLightTheme() {
  final colorScheme = const ColorScheme.light().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: whiteColor,
    error: redColor,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    snackBarTheme: const SnackBarThemeData(backgroundColor: primaryColor),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: whiteColor,
      iconTheme: IconThemeData(color: whiteColor),
      titleTextStyle: TextStyle(color: whiteColor, fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );
  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme, heading: headingColor, body: textColor),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme, heading: headingColor, body: textColor),
  );
}

ThemeData _buildDarkTheme() {
  final colorScheme = const ColorScheme.dark().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: darkSurfaceColor,
    error: redColor,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    snackBarTheme: const SnackBarThemeData(backgroundColor: primaryColor),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: whiteColor),
      titleTextStyle: TextStyle(color: whiteColor, fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );
  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme, heading: whiteColor, body: darkModeTextColor),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme, heading: whiteColor, body: darkModeTextColor),
  );
}
