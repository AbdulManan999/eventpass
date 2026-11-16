import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/l10n/app_localizations.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/route/route_generator.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/theme.dart';
import 'package:eventpass/utils/logger.dart';
import 'package:eventpass/utils/strings.dart';

/// Global navigator key – lets non-widget code (e.g. session-expiry handling) navigate.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(ProviderScope(observers: [Logger()], child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) => child!,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appName,
        navigatorKey: navigatorKey,
        theme: lightThemeData,
        darkTheme: darkThemeData,
        themeMode: ThemeMode.light,
        locale: ref.watch(localeProvider),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: Routes.SPLASH,
      ),
    );
  }
}
