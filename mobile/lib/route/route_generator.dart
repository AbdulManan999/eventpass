import 'package:flutter/material.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/views/event_detail/event_detail_screen.dart';
import 'package:eventpass/views/home_screen/home_screen.dart';
import 'package:eventpass/views/login/login_screen.dart';
import 'package:eventpass/views/register/register_screen.dart';
import 'package:eventpass/views/scanner/scanner_screen.dart';
import 'package:eventpass/views/splash/splash_screen.dart';
import 'package:eventpass/views/tap_pass/tap_pass_screen.dart';
import 'package:eventpass/views/ticket_detail/ticket_detail_screen.dart';
// [MODULE_ROUTE_IMPORTS]

/// Maps route names to screens. Arguments arrive via `settings.arguments`;
/// cast them defensively and fall back to a sensible default.
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final dynamic args = settings.arguments;

    switch (settings.name) {
      case Routes.SPLASH:
        return MaterialPageRoute<dynamic>(builder: (_) => const SplashScreen());

      case Routes.LOGIN:
        return MaterialPageRoute<dynamic>(builder: (_) => const LoginScreen());

      case Routes.REGISTER:
        return MaterialPageRoute<dynamic>(builder: (_) => const RegisterScreen());

      case Routes.HOME:
        return MaterialPageRoute<dynamic>(builder: (_) => const HomeScreen());

      case Routes.EVENT_DETAIL:
        if (args is! Event) return _errorRoute(settings.name, args);
        return MaterialPageRoute<dynamic>(builder: (_) => EventDetailScreen(event: args));

      case Routes.TICKET_DETAIL:
        if (args is! Ticket) return _errorRoute(settings.name, args);
        return MaterialPageRoute<dynamic>(builder: (_) => TicketDetailScreen(ticket: args));

      case Routes.SCANNER:
        if (args is! Event) return _errorRoute(settings.name, args);
        return MaterialPageRoute<dynamic>(builder: (_) => ScannerScreen(event: args));

      case Routes.TAP_PASS:
        if (args is! Ticket) return _errorRoute(settings.name, args);
        // Zooms up out of the ticket, like the pass coming alive.
        return PageRouteBuilder<dynamic>(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, _, _) => TapPassScreen(ticket: args),
          transitionsBuilder: (_, animation, _, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(scale: Tween(begin: 0.88, end: 1.0).animate(curved), child: child),
            );
          },
        );

      // [MODULE_ROUTE_CASES]

      default:
        return _errorRoute(settings.name, args);
    }
  }

  static Route<dynamic> _errorRoute(String? name, dynamic args) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('No route defined for "$name"')),
      ),
    );
  }
}
