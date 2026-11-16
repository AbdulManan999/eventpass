import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/views/home_screen/events_tab.dart';
import 'package:eventpass/views/home_screen/my_tickets_tab.dart';
import 'package:eventpass/views/home_screen/profile_tab.dart';
import 'package:eventpass/widgets/loading_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = context.loc;
    final index = ref.watch(navigationIndexProvider);
    final titles = [loc.text_events, loc.text_my_tickets, loc.text_profile];

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text(titles[index])),
          // IndexedStack keeps each tab's scroll position and listeners alive.
          body: IndexedStack(index: index, children: const [EventsTab(), MyTicketsTab(), ProfileTab()]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => ref.read(navigationIndexProvider.notifier).state = i,
            destinations: [
              NavigationDestination(icon: const Icon(Icons.event_outlined), selectedIcon: const Icon(Icons.event), label: titles[0]),
              NavigationDestination(
                icon: const Icon(Icons.confirmation_number_outlined),
                selectedIcon: const Icon(Icons.confirmation_number),
                label: titles[1],
              ),
              NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: titles[2]),
            ],
          ),
        ),
        const LoadingWidget(),
      ],
    );
  }
}
