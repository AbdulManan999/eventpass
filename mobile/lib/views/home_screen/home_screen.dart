import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/providers/api_scanner_notifier.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/views/home_screen/events_tab.dart';
import 'package:eventpass/views/home_screen/my_tickets_tab.dart';
import 'package:eventpass/views/home_screen/profile_tab.dart';
import 'package:eventpass/views/scanner/staff_events_tab.dart';
import 'package:eventpass/widgets/loading_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Decides whether the Scan tab is shown; failures just keep it hidden.
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(apiScannerNotifierProvider.notifier).apiGetStaffEvents(silent: true));
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final user = ref.watch(currentUserProvider);
    final staffEvents = ref.watch(staffEventsProvider);
    // Organizers always get the scanner; attendees only once added as gate staff.
    final canScan = user?.role == 'organizer' || (staffEvents?.isNotEmpty ?? false);

    final tabs = <({String title, IconData icon, IconData selected, Widget body})>[
      (title: loc.text_events, icon: Icons.explore_outlined, selected: Icons.explore, body: const EventsTab()),
      (title: loc.text_my_tickets, icon: Icons.confirmation_number_outlined, selected: Icons.confirmation_number, body: const MyTicketsTab()),
      if (canScan) (title: loc.text_scan, icon: Icons.qr_code_scanner_outlined, selected: Icons.qr_code_scanner, body: const StaffEventsTab()),
      (title: loc.text_profile, icon: Icons.person_outline, selected: Icons.person, body: const ProfileTab()),
    ];
    final index = ref.watch(navigationIndexProvider).clamp(0, tabs.length - 1);

    return Stack(
      children: [
        Scaffold(
          appBar: index == 0 ? null : AppBar(title: Text(tabs[index].title)),
          // IndexedStack keeps each tab's scroll position and listeners alive.
          body: SafeArea(
            bottom: false,
            top: index == 0,
            child: IndexedStack(index: index, children: [for (final t in tabs) KeyedSubtree(key: ValueKey(t.title), child: t.body)]),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => ref.read(navigationIndexProvider.notifier).state = i,
            destinations: [
              for (final t in tabs) NavigationDestination(icon: Icon(t.icon), selectedIcon: Icon(t.selected), label: t.title),
            ],
          ),
        ),
        const LoadingWidget(),
      ],
    );
  }
}
