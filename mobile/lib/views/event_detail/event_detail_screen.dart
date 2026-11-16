import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/providers/api_tickets_notifier.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/button_widget/elevated_button_widget.dart';
import 'package:eventpass/widgets/loading_widget.dart';
import 'package:eventpass/widgets/session_expired_handler.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.event});

  final Event event;

  @override
  EventDetailScreenState createState() => EventDetailScreenState();
}

class EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  Ticket? get _heldTicket {
    final tickets = ref.watch(myTicketsProvider) ?? const [];
    for (final t in tickets) {
      if (t.event?.id == widget.event.id) return t;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ApiStatesModel>(apiTicketsNotifierProvider, (_, s) {
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      switch (s.states) {
        case States.SESSIONEXPIRED:
          handleSessionExpired(context, ref);
          break;
        case States.ERROR:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.message)));
          break;
        case States.DATA:
          if (s.data is Ticket) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.loc.text_ticket_ready)));
            Navigator.of(context).pushNamed(Routes.TICKET_DETAIL, arguments: s.data);
          }
          break;
        default:
          break;
      }
    });

    return Stack(children: [_mainLayout(), const LoadingWidget()]);
  }

  Widget _mainLayout() {
    final loc = context.loc;
    final event = widget.event;
    final held = _heldTicket;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(event.title ?? '')),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Text(event.title ?? '', style: textTheme.headlineSmall),
          SizedBox(height: 20.h),
          _infoRow(Icons.calendar_today_outlined, Utils.formatDate(event.startsAt, pattern: 'EEEE, d MMMM yyyy')),
          _infoRow(
            Icons.schedule,
            '${Utils.formatDate(event.startsAt, pattern: 'h:mm a')} – ${Utils.formatDate(event.endsAt, pattern: 'h:mm a')}',
          ),
          _infoRow(Icons.place_outlined, event.venue?.name ?? ''),
          _infoRow(Icons.event_seat_outlined, loc.text_capacity(event.capacity ?? 0)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          child: held != null
              ? ElevatedButtonWithoutIcon(
                  text: loc.text_view_ticket,
                  backgroundColor: secondaryColor,
                  onPressed: () => Navigator.of(context).pushNamed(Routes.TICKET_DETAIL, arguments: held),
                )
              : ElevatedButtonWithoutIcon(
                  text: loc.text_get_ticket,
                  onPressed: () => ref.read(apiTicketsNotifierProvider.notifier).apiClaimTicket(event.id!),
                ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
          ],
        ),
      );
}
