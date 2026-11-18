import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eventpass/l10n/app_localizations.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/models/response/tickets/CheckInResponse.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/providers/api_tickets_notifier.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/location_service.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/category_style.dart';
import 'package:eventpass/widgets/loading_widget.dart';
import 'package:eventpass/widgets/nfc/nfc_check_in_actions.dart';
import 'package:eventpass/widgets/session_expired_handler.dart';

/// Full-screen ticket. The QR code needs no network: the token is already
/// signed and the gate scanner checks the signature offline. The same token
/// works over NFC: the phone can act as a tag, or be saved to a wristband.
/// During the event the attendee can also check in with their location (geofence).
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticket});

  final Ticket ticket;

  @override
  TicketDetailScreenState createState() => TicketDetailScreenState();
}

class TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  Timer? _tick;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Keeps the countdown and "self check-in open" state current.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
    // The user may come back from Settings with NFC switched on.
    _lifecycle = AppLifecycleListener(onResume: () => ref.invalidate(nfcCapabilitiesProvider));
  }

  @override
  void dispose() {
    _tick?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  /// The latest copy of this ticket (it changes after a self check-in).
  Ticket get _ticket {
    for (final t in ref.watch(myTicketsProvider) ?? const <Ticket>[]) {
      if (t.id == widget.ticket.id) return t;
    }
    return widget.ticket;
  }

  static String localizeError(AppLocalizations loc, String message) => switch (message) {
        'location_disabled' => loc.text_location_disabled,
        'location_denied' => loc.text_location_denied,
        'location_denied_forever' => loc.text_location_denied_forever,
        _ => message,
      };

  @override
  Widget build(BuildContext context) {
    ref.listen<ApiStatesModel>(apiTicketsNotifierProvider, (_, s) {
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final loc = context.loc;
      switch (s.states) {
        case States.SESSIONEXPIRED:
          handleSessionExpired(context, ref);
          break;
        case States.ERROR:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizeError(loc, s.message)),
              backgroundColor: redColor,
              action: s.message == 'location_denied_forever'
                  ? SnackBarAction(label: loc.text_open_settings, textColor: whiteColor, onPressed: ref.read(locationServiceProvider).openSettings)
                  : null,
            ),
          );
          break;
        case States.DATA:
          if (s.data is CheckInResponse) {
            final r = s.data as CheckInResponse;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(r.alreadyCheckedIn ? loc.text_already_checked_in : loc.text_welcome_in),
                backgroundColor: greenColor,
              ),
            );
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
    final ticket = _ticket;
    final event = ticket.event!;
    final style = CategoryStyle.of(event.category);
    final canSelfCheckIn = !ticket.isRevoked && !ticket.isCheckedIn && event.isSelfCheckInOpen();
    final canTap = !ticket.isRevoked && !ticket.isCheckedIn && !event.isEnded() && ticket.token != null;
    final upcoming = !event.isLive() && !event.isEnded();

    return Scaffold(
      backgroundColor: style.gradient.last,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: Text(loc.text_my_tickets)),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: style.linearGradient),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 12.h),
                      child: Column(
                        children: [
                          Text(
                            CategoryStyle.label(loc, event.category).toUpperCase(),
                            style: TextStyle(color: style.color, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                          ),
                          SizedBox(height: 4.h),
                          Text(event.title ?? '', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                          SizedBox(height: 6.h),
                          Text(
                            '${Utils.formatDate(event.startsAt, pattern: 'EEE, d MMM · h:mm a')}\n${event.venue?.name ?? ''}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: labelColor, fontSize: 13.sp, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    _perforation(style.gradient.last),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              QrImageView(
                                data: ticket.token ?? '',
                                size: 230.w,
                                // Medium error correction: still scans on a scratched or dim screen.
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                                semanticsLabel: 'Ticket QR code',
                              ),
                              if (ticket.isRevoked || ticket.isCheckedIn)
                                Container(
                                  width: 230.w,
                                  height: 230.w,
                                  color: whiteColor.withValues(alpha: 0.88),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    ticket.isRevoked ? Icons.block : Icons.verified_rounded,
                                    color: ticket.isRevoked ? redColor : greenColor,
                                    size: 96.sp,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _statusLine(ticket),
                          SizedBox(height: 6.h),
                          Text(
                            '#${(ticket.id ?? '').split('-').first.toUpperCase()}',
                            style: TextStyle(color: hintColor, fontSize: 12.sp, letterSpacing: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .scale(begin: const Offset(0.94, 0.94), duration: 450.ms, curve: Curves.easeOutBack),
              SizedBox(height: 16.h),
              if (canTap) ...[
                NfcCheckInActions(ticket: ticket),
                SizedBox(height: 14.h),
              ],
              if (upcoming && !ticket.isRevoked)
                _glassCard(
                  icon: Icons.hourglass_top_rounded,
                  title: loc.text_starts_in(Utils.formatCountdown(event.startsAtDate!.difference(DateTime.now()))),
                  subtitle: event.isSelfCheckInOpen() ? loc.text_self_checkin_hint : loc.text_self_checkin_opens,
                ),
              if (canSelfCheckIn) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  height: 52.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteColor,
                      foregroundColor: style.color,
                      elevation: 0,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    icon: const Icon(Icons.my_location_rounded),
                    label: Text(loc.text_check_in_with_location, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    onPressed: () => ref.read(apiTicketsNotifierProvider.notifier).apiSelfCheckIn(ticket),
                  ),
                ),
                if (event.isLive()) ...[
                  SizedBox(height: 8.h),
                  Text(
                    loc.text_self_checkin_hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: whiteColor.withValues(alpha: 0.9), fontSize: 12.5.sp),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusLine(Ticket ticket) {
    final loc = context.loc;
    if (ticket.isRevoked) {
      return Text(loc.text_ticket_revoked, textAlign: TextAlign.center, style: TextStyle(color: redColor, fontSize: 14.sp, fontWeight: FontWeight.w600));
    }
    if (ticket.isCheckedIn) {
      return Column(
        children: [
          Text(
            loc.text_checked_in_at(Utils.formatDate(ticket.checkedInAt, pattern: 'h:mm a')),
            style: TextStyle(color: greenColor, fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
          Text(
            switch (ticket.checkInMethod) {
              'geofence' => loc.text_checked_in_via_geofence,
              'nfc' => loc.text_checked_in_via_nfc,
              _ => loc.text_checked_in_via_qr,
            },
            style: TextStyle(color: labelColor, fontSize: 12.5.sp),
          ),
        ],
      );
    }
    return Text(loc.text_show_at_gate, style: TextStyle(color: textColor, fontSize: 14.sp, fontWeight: FontWeight.w500));
  }

  /// Dashed tear line with notches cut into both sides.
  Widget _perforation(Color notchColor) => SizedBox(
        height: 24.h,
        child: Row(
          children: [
            _notch(notchColor, left: true),
            Expanded(
              child: LayoutBuilder(
                builder: (_, c) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate((c.maxWidth / 10).floor(), (_) => Container(width: 5, height: 1.5, color: greyColor)),
                ),
              ),
            ),
            _notch(notchColor, left: false),
          ],
        ),
      );

  Widget _notch(Color color, {required bool left}) => Container(
        width: 12.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: left
              ? BorderRadius.horizontal(right: Radius.circular(12.r))
              : BorderRadius.horizontal(left: Radius.circular(12.r)),
        ),
      );

  Widget _glassCard({required IconData icon, required String title, required String subtitle}) => Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: whiteColor.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: whiteColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: whiteColor, size: 26.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: whiteColor, fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: TextStyle(color: whiteColor.withValues(alpha: 0.85), fontSize: 12.5.sp)),
                ],
              ),
            ),
          ],
        ),
      );
}
