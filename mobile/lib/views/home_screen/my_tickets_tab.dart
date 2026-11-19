import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/providers/api_tickets_notifier.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/widgets/session_expired_handler.dart';
import 'package:eventpass/widgets/status_view.dart';
import 'package:eventpass/widgets/ticket_card.dart';

class MyTicketsTab extends ConsumerStatefulWidget {
  const MyTicketsTab({super.key});

  @override
  MyTicketsTabState createState() => MyTicketsTabState();
}

class MyTicketsTabState extends ConsumerState<MyTicketsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() => ref.read(apiTicketsNotifierProvider.notifier).apiGetMyTickets();

  @override
  Widget build(BuildContext context) {
    ref.listen<ApiStatesModel>(apiTicketsNotifierProvider, (_, s) {
      // The event detail screen shares this notifier; only the visible route reacts.
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      switch (s.states) {
        case States.SESSIONEXPIRED:
          handleSessionExpired(context, ref);
          break;
        case States.ERROR:
          if (ref.read(myTicketsProvider) != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.message)));
          }
          break;
        default:
          break;
      }
    });

    final loc = context.loc;
    final tickets = ref.watch(myTicketsProvider);
    final fromCache = ref.watch(ticketsFromCacheProvider);
    final state = ref.watch(apiTicketsNotifierProvider);

    if (tickets == null) {
      return state.states == States.ERROR
          ? StatusView(icon: Icons.cloud_off, message: state.message, actionText: loc.text_retry, onAction: _load)
          : const SizedBox.shrink();
    }

    final active = tickets.where((t) => !(t.event?.isEnded() ?? false)).toList()
      ..sort((a, b) => (a.event?.startsAt ?? '').compareTo(b.event?.startsAt ?? ''));
    final past = tickets.where((t) => t.event?.isEnded() ?? false).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          if (fromCache) _offlineBanner(loc.text_offline_tickets),
          if (tickets.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 100.h),
              child: StatusView(
                icon: Icons.confirmation_number_outlined,
                message: loc.text_no_tickets,
                actionText: loc.text_browse_events,
                onAction: () => ref.read(navigationIndexProvider.notifier).state = 0,
              ),
            ),
          if (active.isNotEmpty) _section(loc.text_upcoming, active),
          if (past.isNotEmpty) _section(loc.text_past, past),
        ],
      ),
    );
  }

  Widget _section(String title, List<Ticket> tickets) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.h, top: 4.h),
            child: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: context.palette.heading)),
          ),
          for (final ticket in tickets)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: TicketCard(
                ticket: ticket,
                onTap: () => Navigator.of(context).pushNamed(Routes.TICKET_DETAIL, arguments: ticket),
              ),
            ),
        ],
      );

  Widget _offlineBanner(String text) => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: amberColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: amberColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: amberColor, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(child: Text(text, style: TextStyle(fontSize: 13.sp, color: context.palette.body))),
          ],
        ),
      );
}
