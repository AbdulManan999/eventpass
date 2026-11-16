import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/utils.dart';

/// Date block + title + venue. Used in the events list and on tickets.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.onTap, this.trailing});

  final Event event;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: greyColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 56.w,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(color: primaryLightColor, borderRadius: BorderRadius.circular(12.r)),
                child: Column(
                  children: [
                    Text(
                      Utils.formatDate(event.startsAt, pattern: 'MMM').toUpperCase(),
                      style: TextStyle(color: primaryColor, fontSize: 12.sp, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      Utils.formatDate(event.startsAt, pattern: 'd'),
                      style: TextStyle(color: primaryDarkColor, fontSize: 22.sp, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: headingColor),
                    ),
                    SizedBox(height: 4.h),
                    _iconLine(Icons.schedule, Utils.formatDate(event.startsAt, pattern: 'EEE, h:mm a')),
                    _iconLine(Icons.place_outlined, event.venue?.name ?? ''),
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

  Widget _iconLine(IconData icon, String text) => Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Row(
          children: [
            Icon(icon, size: 14.sp, color: hintColor),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: labelColor),
              ),
            ),
          ],
        ),
      );
}
