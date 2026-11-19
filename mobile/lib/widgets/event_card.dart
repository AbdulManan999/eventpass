import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/category_style.dart';
import 'package:eventpass/widgets/pill.dart';

/// Gradient date tile + title + time + venue + availability. Used in the
/// events list and the staff event list.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onTap, this.trailing, this.badges});

  final Event event;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Replaces the default availability badges.
  final List<Widget>? badges;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final style = CategoryStyle.of(event.category);
    final spotsLeft = event.spotsLeft;
    final defaultBadges = <Widget>[
      if (event.isLive()) Pill(text: loc.text_live_now, color: greenColor, pulse: true),
      if (spotsLeft == 0)
        Pill(text: loc.text_sold_out, color: redColor)
      else if (spotsLeft != null && spotsLeft <= 20)
        Pill(text: loc.text_spots_left(spotsLeft), color: amberColor),
    ];
    final shownBadges = badges ?? defaultBadges;

    return Material(
      color: context.palette.surface,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: context.palette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 64.w,
                height: 72.w,
                decoration: BoxDecoration(gradient: style.linearGradient, borderRadius: BorderRadius.circular(14.r)),
                child: Stack(
                  children: [
                    Positioned(
                      right: -6.w,
                      bottom: -6.w,
                      child: Icon(style.icon, size: 40.sp, color: whiteColor.withValues(alpha: 0.18)),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Utils.formatDate(event.startsAt, pattern: 'MMM').toUpperCase(),
                            style: TextStyle(color: whiteColor.withValues(alpha: 0.85), fontSize: 11.sp, fontWeight: FontWeight.w600, letterSpacing: 1),
                          ),
                          Text(
                            Utils.formatDate(event.startsAt, pattern: 'd'),
                            style: TextStyle(color: whiteColor, fontSize: 24.sp, fontWeight: FontWeight.w700, height: 1.1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CategoryStyle.label(loc, event.category).toUpperCase(),
                      style: TextStyle(color: context.accent(style.color), fontSize: 10.sp, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      event.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: context.palette.heading, height: 1.25),
                    ),
                    SizedBox(height: 4.h),
                    _iconLine(context, Icons.schedule_rounded, Utils.formatDate(event.startsAt, pattern: 'EEE, h:mm a')),
                    _iconLine(context, Icons.place_outlined, event.venue?.name ?? ''),
                    if (shownBadges.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Wrap(spacing: 6.w, runSpacing: 4.h, children: shownBadges),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconLine(BuildContext context, IconData icon, String text) => Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Row(
          children: [
            Icon(icon, size: 13.sp, color: context.palette.hint),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5.sp, color: context.palette.label)),
            ),
          ],
        ),
      );
}

/// Large gradient card for the "Happening now" carousel.
class EventHeroCard extends StatelessWidget {
  const EventHeroCard({super.key, required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final style = CategoryStyle.of(event.category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: style.linearGradient,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [BoxShadow(color: style.color.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(right: -18.w, top: -10.h, child: Icon(style.icon, size: 110.sp, color: whiteColor.withValues(alpha: 0.12))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pill(text: loc.text_live_now, color: whiteColor.withValues(alpha: 0.22), filled: true, pulse: true),
                const Spacer(),
                Text(
                  event.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: whiteColor, fontSize: 19.sp, fontWeight: FontWeight.w700, height: 1.2),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 14.sp, color: whiteColor.withValues(alpha: 0.85)),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        event.venue?.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: whiteColor.withValues(alpha: 0.9), fontSize: 12.5.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  '${Utils.formatDate(event.startsAt, pattern: 'h:mm a')} – ${Utils.formatDate(event.endsAt, pattern: 'h:mm a')}',
                  // Times stay left-to-right in Urdu too.
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: whiteColor.withValues(alpha: 0.85), fontSize: 12.5.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
