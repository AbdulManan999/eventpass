import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/nfc/nfc_service.dart';
import 'package:eventpass/widgets/nfc/nfc_waves.dart';

const _violet = Color(0xFFA78BFA);
const _indigo = Color(0xFF6366F1);
const _fuchsia = Color(0xFFD946EF);

/// The gate's NFC mode. Reads tickets from wristbands, stickers and phones
/// (which emulate a tag) and hands each token to [onTicket], which verifies it
/// offline exactly like a QR code.
class NfcReaderView extends ConsumerStatefulWidget {
  const NfcReaderView({super.key, required this.onTicket});

  final void Function(String token) onTicket;

  @override
  ConsumerState<NfcReaderView> createState() => _NfcReaderViewState();
}

class _NfcReaderViewState extends ConsumerState<NfcReaderView> with WidgetsBindingObserver {
  final _waves = GlobalKey<NfcWavesState>();
  NfcStatus? _status;
  bool _reading = false;
  int _noTicket = 0;
  Timer? _hideNoTicket;

  late final NfcService _nfc = ref.read(nfcServiceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _nfc; // read the service now; ref can't be used in dispose()
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideNoTicket?.cancel();
    unawaited(_nfc.stopReading());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Android drops reader mode when the app leaves the foreground, and the
    // user may come back from Settings with NFC switched on.
    if (state == AppLifecycleState.paused) _stop();
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final status = await _nfc.status();
    if (!mounted) return;
    setState(() => _status = status);
    if (status == NfcStatus.ready && !_nfc.needsReadButton) await _start();
  }

  Future<void> _start() async {
    if (_reading) return;
    setState(() => _reading = true);
    try {
      await _nfc.startReading(
        onTag: _onTag,
        onEnded: () {
          if (mounted) setState(() => _reading = false);
        },
      );
    } catch (_) {
      if (mounted) setState(() => _reading = false);
    }
  }

  void _stop() {
    _reading = false;
    unawaited(_nfc.stopReading());
  }

  void _onTag(String? token) {
    if (!mounted) return;
    _waves.currentState?.burst();
    if (token != null) {
      widget.onTicket(token);
      return;
    }
    HapticFeedback.mediumImpact();
    _hideNoTicket?.cancel();
    setState(() => _noTicket = _noTicket.abs() + 1);
    _hideNoTicket = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _noTicket = -_noTicket.abs());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.0,
              colors: [Color(0xFF2E1F6B), Color(0xFF14102E), Color(0xFF07060F)],
              stops: [0, 0.55, 1],
            ),
          ),
        ),
        switch (_status) {
          null => const SizedBox.shrink(),
          NfcStatus.ready => _ready(),
          NfcStatus.disabled => _unavailable(off: true),
          NfcStatus.unsupported => _unavailable(off: false),
        },
        Positioned(left: 24.w, right: 24.w, bottom: 28.h, child: _noTicketPill()),
      ],
    );
  }

  Widget _ready() {
    final loc = context.loc;
    final waitingForButton = _nfc.needsReadButton && !_reading;
    return LayoutBuilder(
      builder: (context, c) {
        final size = min(300.w, c.maxHeight * 0.58);
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.square(dimension: size * 0.92, child: const CustomPaint(painter: _RadarPainter()))
                        .animate(onPlay: (c) => c.repeat())
                        .rotate(duration: 5.seconds),
                    NfcWaves(key: _waves, color: _violet, size: size, active: !waitingForButton, child: _core(size * 0.42)),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  loc.text_nfc_ready,
                  style: TextStyle(color: whiteColor, fontSize: 24.sp, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 2400.ms, delay: 800.ms, color: const Color(0xFFE9D5FF)),
                SizedBox(height: 6.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    loc.text_nfc_hold_hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: whiteColor.withValues(alpha: 0.7), fontSize: 14.sp, height: 1.4),
                  ),
                ),
                SizedBox(height: 18.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final (i, (icon, label)) in [
                      (Icons.watch_rounded, loc.text_nfc_wristbands),
                      (Icons.smartphone_rounded, loc.text_nfc_phones),
                      (Icons.credit_card_rounded, loc.text_nfc_cards),
                    ].indexed)
                      _chip(icon, label)
                          .animate()
                          .fadeIn(delay: (200 + i * 120).ms, duration: 350.ms)
                          .slideY(begin: 0.6, end: 0, curve: Curves.easeOutBack),
                  ],
                ),
                if (waitingForButton) ...[
                  SizedBox(height: 22.h),
                  _gradientButton(Icons.contactless_rounded, loc.text_nfc_start_reading, _start),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// The glowing "touch here" core that breathes while waiting.
  Widget _core(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_indigo, _fuchsia]),
          boxShadow: [
            BoxShadow(color: _fuchsia.withValues(alpha: 0.55), blurRadius: 40, spreadRadius: 4),
            BoxShadow(color: _indigo.withValues(alpha: 0.5), blurRadius: 70, spreadRadius: 10),
          ],
          border: Border.all(color: whiteColor.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Icon(Icons.contactless_rounded, color: whiteColor, size: size * 0.5),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.07, 1.07), duration: 1300.ms, curve: Curves.easeInOut);

  Widget _chip(IconData icon, String label) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: whiteColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _violet.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15.sp, color: _violet),
            SizedBox(width: 6.w),
            Text(label, style: TextStyle(color: whiteColor.withValues(alpha: 0.85), fontSize: 12.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _unavailable({required bool off}) {
    final loc = context.loc;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor.withValues(alpha: 0.06),
                border: Border.all(color: whiteColor.withValues(alpha: 0.15)),
              ),
              child: Icon(off ? Icons.nfc_rounded : Icons.phonelink_erase_rounded, color: whiteColor.withValues(alpha: 0.6), size: 52.sp),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1600.ms, curve: Curves.easeInOut),
            SizedBox(height: 20.h),
            Text(
              off ? loc.text_nfc_off : loc.text_nfc_unsupported,
              textAlign: TextAlign.center,
              style: TextStyle(color: whiteColor, fontSize: off ? 20.sp : 16.sp, fontWeight: FontWeight.w700),
            ),
            if (off) ...[
              SizedBox(height: 6.h),
              Text(
                loc.text_nfc_off_hint,
                textAlign: TextAlign.center,
                style: TextStyle(color: whiteColor.withValues(alpha: 0.7), fontSize: 14.sp),
              ),
              SizedBox(height: 20.h),
              _gradientButton(Icons.toggle_on_rounded, loc.text_turn_on_nfc, _nfc.openSettings),
            ],
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _gradientButton(IconData icon, String label, VoidCallback onTap) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_indigo, _fuchsia]),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [BoxShadow(color: _fuchsia.withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28.r),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 13.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: whiteColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(label, style: TextStyle(color: whiteColor, fontSize: 15.sp, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      );

  /// "No ticket on this tag": pops up, shakes, then slides away.
  Widget _noTicketPill() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(a), child: child),
        ),
        child: _noTicket > 0
            ? Container(
                key: ValueKey(_noTicket),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B1530),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: redColor.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline_rounded, color: const Color(0xFFFCA5A5), size: 20.sp),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        context.loc.text_nfc_no_ticket,
                        style: TextStyle(color: whiteColor, fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ).animate().shake(hz: 4, offset: const Offset(8, 0), duration: 400.ms)
            : const SizedBox.shrink(),
      );
}

/// A faint ring with a bright comet-tail arc; rotated to look like a radar sweep.
class _RadarPainter extends CustomPainter {
  const _RadarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _violet.withValues(alpha: 0.12),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      0,
      pi * 0.9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [Colors.transparent, _violet.withValues(alpha: 0.2), _fuchsia.withValues(alpha: 0.9)],
          stops: const [0, 0.6, 1],
          endAngle: pi * 0.9,
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) => false;
}
