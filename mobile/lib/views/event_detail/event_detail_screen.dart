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
import 'package:eventpass/utils/geo.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/button_widget/elevated_button_widget.dart';
import 'package:eventpass/widgets/category_style.dart';
import 'package:eventpass/widgets/loading_widget.dart';
import 'package:eventpass/widgets/pill.dart';
import 'package:eventpass/widgets/session_expired_handler.dart';
import 'package:eventpass/widgets/venue_map.dart';

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
    final style = CategoryStyle.of(event.category);
    final issued = event.ticketsIssued;
    final capacity = event.capacity ?? 0;
    final soldOut = event.spotsLeft == 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210.h,
            pinned: true,
            backgroundColor: style.color,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsetsDirectional.only(start: 56.w, bottom: 14.h, end: 16.w),
              title: Text(
                event.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: whiteColor),
              ),
              background: Container(
                decoration: BoxDecoration(gradient: style.linearGradient),
                child: Stack(
                  children: [
                    Positioned(right: -30.w, top: 20.h, child: Icon(style.icon, size: 180.sp, color: whiteColor.withValues(alpha: 0.12))),
                    Positioned(
                      left: 20.w,
                      top: 96.h,
                      child: Row(
                        children: [
                          Pill(text: CategoryStyle.label(loc, event.category), color: whiteColor.withValues(alpha: 0.22), filled: true),
                          if (event.isLive()) ...[
                            SizedBox(width: 6.w),
                            Pill(text: loc.text_live_now, color: greenColor, filled: true, pulse: true),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.w),
            sliver: SliverList.list(
              children: [
                _infoTile(
                  Icons.calendar_month_rounded,
                  loc.text_date_time,
                  '${Utils.formatDate(event.startsAt, pattern: 'EEEE, d MMMM yyyy')}\n'
                      '${Utils.formatDate(event.startsAt, pattern: 'h:mm a')} – ${Utils.formatDate(event.endsAt, pattern: 'h:mm a')}',
                ),
                SizedBox(height: 10.h),
                _infoTile(Icons.place_rounded, loc.text_venue, event.venue?.name ?? ''),
                if (issued != null && capacity > 0) ...[
                  SizedBox(height: 10.h),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                loc.text_tickets_claimed(issued, capacity),
                                style: TextStyle(fontSize: 13.sp, color: labelColor),
                              ),
                            ),
                            soldOut
                                ? Pill(text: loc.text_sold_out, color: redColor)
                                : Pill(text: loc.text_spots_left(event.spotsLeft ?? 0), color: greenColor),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: LinearProgressIndicator(
                            value: issued / capacity,
                            minHeight: 8.h,
                            backgroundColor: greyColor,
                            color: soldOut ? redColor : style.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (event.description.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Text(loc.text_about_event, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: headingColor)),
                  SizedBox(height: 6.h),
                  Text(event.description, style: TextStyle(fontSize: 14.sp, color: textColor, height: 1.5)),
                ],
                if (event.venue != null) ...[
                  SizedBox(height: 20.h),
                  VenueMap(venue: event.venue!),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.my_location, size: 16.sp, color: primaryColor),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          loc.text_self_checkin_zone(formatDistance(event.venue!.geofenceRadiusM ?? 200)),
                          style: TextStyle(fontSize: 12.5.sp, color: labelColor),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: held != null
              ? ElevatedButtonWithoutIcon(
                  text: loc.text_view_ticket,
                  backgroundColor: secondaryColor,
                  onPressed: () => Navigator.of(context).pushNamed(Routes.TICKET_DETAIL, arguments: held),
                )
              : ElevatedButtonWithoutIcon(
                  text: soldOut ? loc.text_sold_out : loc.text_get_ticket,
                  backgroundColor: style.color,
                  onPressed: soldOut ? null : () => ref.read(apiTicketsNotifierProvider.notifier).apiClaimTicket(event.id!),
                ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: greyColor),
        ),
        child: child,
      );

  Widget _infoTile(IconData icon, String label, String value) => _card(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: primaryLightColor, borderRadius: BorderRadius.circular(12.r)),
              child: Icon(icon, color: primaryColor, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12.sp, color: hintColor)),
                  SizedBox(height: 2.h),
                  Text(value, style: TextStyle(fontSize: 14.sp, color: headingColor, fontWeight: FontWeight.w500, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );
}
