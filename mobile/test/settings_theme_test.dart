import 'package:eventpass/l10n/app_localizations.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/theme.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/constants.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/views/home_screen/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Tests run offline; fall back to the default font instead of downloading.
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// The real app shell: MaterialApp follows themeModeProvider.
  Future<void> pumpSettings(WidgetTester tester, {Brightness platform = Brightness.light}) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.platformBrightnessTestValue = platform;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            theme: lightThemeData,
            darkTheme: darkThemeData,
            themeMode: ref.watch(themeModeProvider),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                ScreenUtil.init(context, designSize: const Size(390, 844));
                return const Scaffold(body: ProfileTab());
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  /// One frame to start the theme animation, then let it finish.
  Future<void> crossFade(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Color scaffoldColor(WidgetTester tester) => Theme.of(tester.element(find.byType(ProfileTab))).scaffoldBackgroundColor;

  testWidgets('picking Dark in Settings switches the app and saves the choice', (tester) async {
    await pumpSettings(tester);
    expect(find.text('Appearance'), findsOneWidget);
    expect(scaffoldColor(tester), AppPalette.light.background);

    await tester.tap(find.text('Dark'));
    await crossFade(tester);

    expect(scaffoldColor(tester), AppPalette.dark.background);
    expect(Theme.of(tester.element(find.byType(ProfileTab))).extension<AppPalette>()!.surface, nightSurfaceColor);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(Constants.prefThemeMode), 'dark');
    expect(await Utils.getThemeMode(), ThemeMode.dark);

    await tester.tap(find.text('Light'));
    await crossFade(tester);
    expect(scaffoldColor(tester), AppPalette.light.background);
    expect(await Utils.getThemeMode(), ThemeMode.light);
  });

  testWidgets('System follows the phone', (tester) async {
    await pumpSettings(tester, platform: Brightness.dark);
    expect(scaffoldColor(tester), AppPalette.dark.background, reason: 'System is the default');
    expect(find.text("Matches your phone's setting"), findsOneWidget);
  });

  test('a fresh install follows the phone; language follows the device until chosen', () async {
    expect(await Utils.getThemeMode(), ThemeMode.system);
    expect(await Utils.getLanguage(), isNull);
    await Utils.setLanguage('ur');
    expect(await Utils.getLanguage(), 'ur');
  });

  test('palettes blend smoothly during the theme animation', () {
    final mid = AppPalette.light.lerp(AppPalette.dark, 0.5);
    expect(mid.surface, Color.lerp(AppPalette.light.surface, AppPalette.dark.surface, 0.5));
    expect(AppPalette.light.lerp(null, 0.5), AppPalette.light);
  });
}
