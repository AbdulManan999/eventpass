import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/nfc/nfc_service.dart';
import 'package:eventpass/widgets/nfc/write_tag_sheet.dart';

/// What this phone can do with NFC: read/write tags, and act as a tag.
final nfcCapabilitiesProvider = FutureProvider.autoDispose<({NfcStatus status, bool canEmulate})>((ref) async {
  final nfc = ref.read(nfcServiceProvider);
  return (status: await nfc.status(), canEmulate: await nfc.canEmulate());
}, name: 'nfcCapabilitiesProvider');

/// "Check in with NFC" on the ticket screen: tap the phone itself (Android),
/// or save the ticket to a wristband. Hidden on phones without NFC.
class NfcCheckInActions extends ConsumerWidget {
  const NfcCheckInActions({super.key, required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caps = ref.watch(nfcCapabilitiesProvider).valueOrNull;
    if (caps == null || caps.status == NfcStatus.unsupported) return const SizedBox.shrink();
    final loc = context.loc;

    void requireNfc(VoidCallback action) {
      if (caps.status == NfcStatus.ready) return action();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.text_nfc_off_hint),
          action: SnackBarAction(label: loc.text_turn_on_nfc, onPressed: () => ref.read(nfcServiceProvider).openSettings()),
        ),
      );
    }

    final tiles = [
      if (caps.canEmulate)
        _Tile(
          icon: Icons.contactless_rounded,
          title: loc.text_tap_phone,
          subtitle: loc.text_tap_phone_hint,
          highlighted: true,
          onTap: () => requireNfc(() => Navigator.pushNamed(context, Routes.TAP_PASS, arguments: ticket)),
        ),
      _Tile(
        icon: Icons.nfc_rounded,
        title: loc.text_save_to_wristband,
        subtitle: loc.text_save_to_wristband_hint,
        onTap: () => requireNfc(() => showWriteTagSheet(context, ticket.token!)),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.contactless_outlined, color: whiteColor, size: 18.sp),
            SizedBox(width: 6.w),
            Text(loc.text_nfc_check_in, style: TextStyle(color: whiteColor, fontSize: 15.sp, fontWeight: FontWeight.w700)),
          ],
        ).animate().fadeIn(duration: 300.ms),
        SizedBox(height: 10.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, tile) in tiles.indexed) ...[
                if (i > 0) SizedBox(width: 10.w),
                Expanded(
                  child: tile
                      .animate()
                      .fadeIn(delay: (120 + i * 120).ms, duration: 400.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap, this.highlighted = false});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: highlighted ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFD946EF)]) : null,
        color: highlighted ? null : whiteColor.withValues(alpha: 0.2),
        boxShadow: highlighted ? [BoxShadow(color: const Color(0xFFD946EF).withValues(alpha: 0.5), blurRadius: 14)] : null,
      ),
      child: Icon(icon, color: whiteColor, size: 22.sp),
    );
    if (highlighted) {
      // A soft heartbeat on the main action.
      badge = badge
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1, end: 1.08, duration: 1100.ms, curve: Curves.easeInOut);
    }

    Widget card = Material(
      color: whiteColor.withValues(alpha: highlighted ? 0.22 : 0.14),
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: whiteColor.withValues(alpha: highlighted ? 0.45 : 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              badge,
              SizedBox(height: 10.h),
              Text(title, style: TextStyle(color: whiteColor, fontSize: 14.5.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Text(subtitle, style: TextStyle(color: whiteColor.withValues(alpha: 0.8), fontSize: 12.sp, height: 1.3)),
            ],
          ),
        ),
      ),
    );
    if (highlighted) {
      card = card.animate(onPlay: (c) => c.repeat()).shimmer(delay: 2500.ms, duration: 1400.ms, color: whiteColor.withValues(alpha: 0.35));
    }
    return card;
  }
}
