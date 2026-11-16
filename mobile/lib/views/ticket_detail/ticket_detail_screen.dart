import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/utils.dart';

/// Full-screen QR code. Needs no network: the token is already signed and
/// the gate scanner checks the signature offline.
class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key, required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final event = ticket.event;

    return Scaffold(
      backgroundColor: primaryDarkColor,
      appBar: AppBar(backgroundColor: primaryDarkColor, elevation: 0, title: Text(loc.text_my_tickets)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(color: whiteColor, borderRadius: BorderRadius.circular(24.r)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event?.title ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${Utils.formatDate(event?.startsAt, pattern: 'EEE, d MMM · h:mm a')}\n${event?.venue?.name ?? ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: labelColor, fontSize: 14.sp, height: 1.4),
                  ),
                  SizedBox(height: 20.h),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      QrImageView(
                        data: ticket.token ?? '',
                        size: 260.w,
                        // Medium error correction: still scans on a scratched or dim screen.
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        semanticsLabel: 'Ticket QR code',
                      ),
                      if (ticket.isRevoked)
                        Container(
                          width: 260.w,
                          height: 260.w,
                          color: whiteColor.withValues(alpha: 0.9),
                          alignment: Alignment.center,
                          child: Icon(Icons.block, color: redColor, size: 96.sp),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    ticket.isRevoked ? loc.text_ticket_revoked : loc.text_show_at_gate,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ticket.isRevoked ? redColor : textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '#${(ticket.id ?? '').split('-').first.toUpperCase()}',
                    style: TextStyle(color: hintColor, fontSize: 12.sp, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
