import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/l10n/app_localizations.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/QueuedScan.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/widgets/animated_check.dart';

/// Colour, icon and label for a scan result.
class ResultLook {
  const ResultLook(this.color, this.icon, this.label);

  final Color color;
  final IconData icon;
  final String label;

  static ResultLook of(AppLocalizations loc, String result) => switch (result) {
        ScanResults.accepted => ResultLook(greenColor, Icons.check_circle_rounded, loc.text_admitted),
        ScanResults.duplicate => ResultLook(amberColor, Icons.content_copy_rounded, loc.text_already_used),
        ScanResults.revoked => ResultLook(redColor, Icons.block_rounded, loc.text_revoked),
        ScanResults.wrongEvent => ResultLook(redColor, Icons.event_busy_rounded, loc.text_wrong_event),
        _ => ResultLook(redColor, Icons.gpp_bad_rounded, loc.text_invalid_ticket),
      };

  static IconData methodIcon(String method) => method == ScanMethods.nfc ? Icons.contactless_rounded : Icons.qr_code_2_rounded;

  static String methodLabel(AppLocalizations loc, String method) =>
      method == ScanMethods.nfc ? loc.text_scan_mode_nfc : loc.text_scan_mode_qr;
}

/// Full-screen verdict: the colour floods out from the centre in a circle,
/// then the check mark draws itself (admitted) or the icon pops and shakes
/// (rejected), and the attendee's name slides in.
class ScanResultOverlay extends StatelessWidget {
  const ScanResultOverlay({super.key, required this.scan});

  final QueuedScan scan;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final look = ResultLook.of(loc, scan.localResult);
    final admitted = scan.localResult == ScanResults.accepted;

    return TweenAnimationBuilder<double>(
      key: ValueKey(scan.id),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => ClipPath(clipper: _CircleReveal(t), child: child),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.1,
            colors: [Color.lerp(look.color, whiteColor, 0.12)!, look.color, Color.lerp(look.color, blackColor, 0.45)!],
            stops: const [0, 0.5, 1],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (admitted)
              AnimatedCheck(color: whiteColor, size: 128.w, strokeWidth: 8, delay: const Duration(milliseconds: 120))
            else
              Icon(look.icon, color: whiteColor, size: 112.sp)
                  .animate()
                  .scale(begin: const Offset(0.3, 0.3), duration: 650.ms, curve: Curves.elasticOut)
                  .then(delay: 50.ms)
                  .shake(hz: 5, offset: const Offset(10, 0), duration: 450.ms),
            SizedBox(height: 16.h),
            Text(look.label, style: TextStyle(color: whiteColor, fontSize: 32.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5))
                .animate()
                .fadeIn(delay: 150.ms, duration: 300.ms)
                .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic),
            if (scan.holderName?.isNotEmpty == true) ...[
              SizedBox(height: 6.h),
              Text(scan.holderName!, style: TextStyle(color: whiteColor, fontSize: 21.sp, fontWeight: FontWeight.w500))
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 300.ms)
                  .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic),
            ],
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: whiteColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: whiteColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(ResultLook.methodIcon(scan.method), color: whiteColor, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    '${ResultLook.methodLabel(loc, scan.method)}  ·  #${(scan.ticketId ?? '').split('-').first.toUpperCase()}',
                    style: TextStyle(color: whiteColor, fontSize: 12.5.sp, fontWeight: FontWeight.w600, letterSpacing: 0.6),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}

class _CircleReveal extends CustomClipper<Path> {
  _CircleReveal(this.t);

  final double t;

  @override
  Path getClip(Size size) {
    final center = size.center(Offset.zero);
    final radius = sqrt(size.width * size.width + size.height * size.height) / 2 * t;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircleReveal old) => old.t != t;
}
