import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/l10n/app_localizations.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/nfc/nfc_service.dart';
import 'package:eventpass/widgets/animated_check.dart';
import 'package:eventpass/widgets/confetti_burst.dart';
import 'package:eventpass/widgets/nfc/nfc_waves.dart';

const _violet = Color(0xFFA78BFA);
const _indigo = Color(0xFF6366F1);
const _fuchsia = Color(0xFFD946EF);
const _mint = Color(0xFF34D399);

/// Writes the ticket to a blank NFC wristband or sticker, which then works at
/// the gate like the QR code (it holds the same signed token).
Future<void> showWriteTagSheet(BuildContext context, String token) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WriteTagSheet(token: token),
    );

class WriteTagSheet extends ConsumerStatefulWidget {
  const WriteTagSheet({super.key, required this.token});

  final String token;

  @override
  ConsumerState<WriteTagSheet> createState() => _WriteTagSheetState();
}

class _WriteTagSheetState extends ConsumerState<WriteTagSheet> {
  /// Null while waiting for a tag.
  TagWriteResult? _result;
  late final NfcService _nfc = ref.read(nfcServiceProvider);

  @override
  void initState() {
    super.initState();
    _write();
  }

  @override
  void dispose() {
    unawaited(_nfc.cancelWrite());
    super.dispose();
  }

  Future<void> _write() async {
    setState(() => _result = null);
    final result = await _nfc.writeTicket(widget.token);
    if (!mounted) return;
    if (result == TagWriteResult.cancelled) {
      // iOS: the user closed the system sheet.
      Navigator.of(context).maybePop();
      return;
    }
    result == TagWriteResult.written ? HapticFeedback.heavyImpact() : HapticFeedback.vibrate();
    setState(() => _result = result);
  }

  static String _error(AppLocalizations loc, TagWriteResult r) => switch (r) {
        TagWriteResult.tooSmall => loc.text_write_too_small,
        TagWriteResult.readOnly => loc.text_write_read_only,
        TagWriteResult.notNdef => loc.text_write_not_ndef,
        _ => loc.text_write_failed,
      };

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final written = _result == TagWriteResult.written;
    final failed = _result != null && !written;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1E1650), Color(0xFF0B0B1E)]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border(top: BorderSide(color: _violet.withValues(alpha: 0.4))),
      ),
      child: Stack(
        children: [
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(color: whiteColor.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(2.r)),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 220.w,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOutBack,
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: ScaleTransition(scale: Tween(begin: 0.7, end: 1.0).animate(a), child: child),
                      ),
                      child: written
                          ? _successBadge()
                          : failed
                              ? _errorBadge()
                              : NfcWaves(key: const ValueKey('waiting'), color: _violet, size: 220.w, child: _tag()),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      written ? loc.text_write_success : (failed ? _error(loc, _result!) : loc.text_write_waiting),
                      key: ValueKey(_result),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: whiteColor, fontSize: 18.sp, fontWeight: FontWeight.w700, height: 1.35),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  if (_result == null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _violet.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: _violet.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline_rounded, color: _violet, size: 14.sp),
                          SizedBox(width: 6.w),
                          Text(loc.text_write_tag_size, style: TextStyle(color: _violet, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  SizedBox(height: 22.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(foregroundColor: whiteColor.withValues(alpha: 0.75), minimumSize: Size.fromHeight(50.h)),
                          child: Text(written ? loc.text_done : loc.text_close, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      if (failed) ...[
                        SizedBox(width: 12.w),
                        Expanded(child: _gradientButton(loc.text_retry, _write)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (written) const Positioned.fill(child: ConfettiBurst(count: 45, origin: Alignment(0, -0.2))),
        ],
      ),
    );
  }

  /// A blank tag that wobbles, inviting a tap.
  Widget _tag() => Container(
        width: 86.w,
        height: 86.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_indigo, _fuchsia]),
          boxShadow: [BoxShadow(color: _fuchsia.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 2)],
        ),
        child: Icon(Icons.nfc_rounded, color: whiteColor, size: 46.sp),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .rotate(begin: -0.025, end: 0.025, duration: 900.ms, curve: Curves.easeInOut)
          .scaleXY(begin: 1, end: 1.06, duration: 900.ms, curve: Curves.easeInOut);

  Widget _successBadge() => Container(
        key: const ValueKey('ok'),
        width: 130.w,
        height: 130.w,
        padding: EdgeInsets.all(26.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_mint, Color(0xFF059669)]),
          boxShadow: [BoxShadow(color: _mint.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 4)],
        ),
        child: const AnimatedCheck(color: whiteColor, strokeWidth: 8, delay: Duration(milliseconds: 150)),
      );

  Widget _errorBadge() => Container(
        key: ValueKey('err$_result'),
        width: 120.w,
        height: 120.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: redColor.withValues(alpha: 0.15),
          border: Border.all(color: redColor.withValues(alpha: 0.6), width: 2),
        ),
        child: Icon(
          _result == TagWriteResult.tooSmall ? Icons.straighten_rounded : Icons.error_outline_rounded,
          color: const Color(0xFFFCA5A5),
          size: 56.sp,
        ),
      ).animate().shake(hz: 5, offset: const Offset(10, 0), duration: 450.ms);

  Widget _gradientButton(String label, VoidCallback onTap) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_indigo, _fuchsia]),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: onTap,
            child: SizedBox(
              height: 50.h,
              child: Center(child: Text(label, style: TextStyle(color: whiteColor, fontSize: 15.sp, fontWeight: FontWeight.w700))),
            ),
          ),
        ),
      );
}
