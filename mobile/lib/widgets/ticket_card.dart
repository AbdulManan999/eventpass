import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/category_style.dart';
import 'package:eventpass/widgets/pill.dart';

/// A ticket-shaped card: event on the left, a perforated edge, and a QR stub.
class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket, this.onTap});

  final Ticket ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final event = ticket.event!;
    final style = CategoryStyle.of(event.category);
    final ended = event.isEnded();
    final muted = ended || ticket.isRevoked;

    final Widget status;
    if (ticket.isRevoked) {
      status = Pill(text: loc.text_revoked, color: redColor, icon: Icons.block);
    } else if (ticket.isCheckedIn) {
      status = Pill(text: loc.text_checked_in, color: greenColor, icon: Icons.check_circle);
    } else if (event.isLive()) {
      status = Pill(text: loc.text_live_now, color: greenColor, pulse: true);
    } else if (ended) {
      status = Pill(text: loc.text_ended, color: context.palette.hint);
    } else {
      final starts = event.startsAtDate!;
      status = Pill(
        text: loc.text_starts_in(Utils.formatCountdown(starts.difference(DateTime.now()))),
        color: primaryColor,
        icon: Icons.schedule,
      );
    }

    return Opacity(
      opacity: muted ? 0.6 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: ClipPath(
          clipper: _TicketClipper(notchX: 0.72, radius: 10.r),
          child: Container(
            height: 118.h,
            decoration: BoxDecoration(color: context.palette.surface, border: Border.all(color: context.palette.border)),
            child: Row(
              children: [
                Container(width: 6.w, decoration: BoxDecoration(gradient: style.linearGradient)),
                Expanded(
                  flex: 72,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: context.palette.heading, height: 1.2),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          Utils.formatDate(event.startsAt, pattern: 'EEE d MMM · h:mm a'),
                          style: TextStyle(fontSize: 12.sp, color: context.palette.label),
                        ),
                        Text(
                          event.venue?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp, color: context.palette.hint),
                        ),
                        const Spacer(),
                        status,
                      ],
                    ),
                  ),
                ),
                const _DashedDivider(),
                Expanded(
                  flex: 28,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        ticket.isRevoked ? Icons.block : (ticket.isCheckedIn ? Icons.verified : Icons.qr_code_2_rounded),
                        size: 40.sp,
                        color: context.accent(ticket.isRevoked ? redColor : (ticket.isCheckedIn ? greenColor : style.color)),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '#${(ticket.id ?? '').split('-').first.toUpperCase()}',
                        style: TextStyle(fontSize: 10.sp, color: context.palette.hint, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cuts a semicircle notch into the top and bottom edges at [notchX] (0–1).
class _TicketClipper extends CustomClipper<Path> {
  _TicketClipper({required this.notchX, required this.radius});

  final double notchX;
  final double radius;

  @override
  Path getClip(Size size) {
    final x = size.width * notchX;
    final card = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(16)));
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(x, 0), radius: radius))
      ..addOval(Rect.fromCircle(center: Offset(x, size.height), radius: radius));
    return Path.combine(PathOperation.difference, card, notches);
  }

  @override
  bool shouldReclip(_TicketClipper old) => old.notchX != notchX || old.radius != radius;
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) {
          final count = (c.maxHeight / 8).floor();
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(count, (_) => Container(width: 1.2, height: 4, color: context.palette.border)),
          );
        },
      );
}
