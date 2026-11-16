import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/providers/api_events_notifier.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/widgets/event_card.dart';
import 'package:eventpass/widgets/status_view.dart';

class EventsTab extends ConsumerStatefulWidget {
  const EventsTab({super.key});

  @override
  EventsTabState createState() => EventsTabState();
}

class EventsTabState extends ConsumerState<EventsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(eventsListProvider) == null) _load();
    });
  }

  Future<void> _load() => ref.read(apiEventsNotifierProvider.notifier).apiGetEvents();

  @override
  Widget build(BuildContext context) {
    ref.listen<ApiStatesModel>(apiEventsNotifierProvider, (_, s) {
      // A failed refresh keeps the old list on screen; say why in a snackbar.
      if (s.states == States.ERROR && ref.read(eventsListProvider) != null && (ModalRoute.of(context)?.isCurrent ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.message)));
      }
    });

    final loc = context.loc;
    final events = ref.watch(eventsListProvider);
    final state = ref.watch(apiEventsNotifierProvider);

    if (events == null) {
      return state.states == States.ERROR
          ? StatusView(icon: Icons.cloud_off, message: state.message, actionText: loc.text_retry, onAction: _load)
          : const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: events.isEmpty
          ? ListView(children: [SizedBox(height: 120.h), StatusView(icon: Icons.event_busy, message: loc.text_no_events)])
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: events.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, i) => EventCard(
                event: events[i],
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(Routes.EVENT_DETAIL, arguments: events[i]),
              ),
            ),
    );
  }
}
