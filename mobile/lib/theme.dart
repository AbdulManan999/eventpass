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

/// Shared component styling; only the palette differs between light and dark.
ThemeData _build({required Brightness brightness, required ColorScheme scheme, required AppPalette p}) {
  final dark = brightness == Brightness.dark;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    primaryColor: scheme.primary,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    dividerColor: p.border,
    extensions: [p],
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.primarySoft,
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? p.onPrimarySoft : p.hint),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? p.heading : p.hint,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? nightSurfaceHighColor : primaryColor,
      contentTextStyle: const TextStyle(color: whiteColor),
      actionTextColor: dark ? nightOnPrimarySoftColor : whiteColor,
    ),
    // Light: the brand-coloured bar. Dark: a quiet surface bar.
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? p.surface : primaryColor,
      foregroundColor: dark ? p.heading : whiteColor,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: dark ? p.heading : whiteColor),
      titleTextStyle: TextStyle(color: dark ? p.heading : whiteColor, fontSize: 18, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(color: p.surface, surfaceTintColor: Colors.transparent),
    dialogTheme: DialogThemeData(backgroundColor: p.surface, surfaceTintColor: Colors.transparent),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: p.surface, surfaceTintColor: Colors.transparent),
    dividerTheme: DividerThemeData(color: p.border),
    listTileTheme: ListTileThemeData(iconColor: p.label, textColor: p.heading),
    chipTheme: ChipThemeData(backgroundColor: p.surface, side: BorderSide(color: p.border), labelStyle: TextStyle(color: p.body)),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.primarySoft : p.surface),
        foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.onPrimarySoft : p.body),
        side: WidgetStatePropertyAll(BorderSide(color: p.border)),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary, linearTrackColor: p.border),
    inputDecorationTheme: InputDecorationTheme(fillColor: p.inputFill, hintStyle: TextStyle(color: p.hint)),
  );
  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme, heading: p.heading, body: p.body),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme, heading: p.heading, body: p.body),
  );
}

ThemeData _buildLightTheme() => _build(
      brightness: Brightness.light,
      scheme: const ColorScheme.light().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: whiteColor,
        onSurface: headingColor,
        error: redColor,
      ),
      p: AppPalette.light,
    );

ThemeData _buildDarkTheme() => _build(
      brightness: Brightness.dark,
      scheme: const ColorScheme.dark().copyWith(
        primary: nightPrimaryColor,
        onPrimary: whiteColor,
        secondary: secondaryColor,
        surface: nightSurfaceColor,
        onSurface: Color(0xFFF8FAFC),
        error: Color(0xFFF87171),
      ),
      p: AppPalette.dark,
    );
