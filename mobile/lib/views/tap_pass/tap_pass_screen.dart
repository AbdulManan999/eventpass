import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Ticket.dart';
import 'package:eventpass/providers/api_tickets_notifier.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/nfc/nfc_service.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/animated_check.dart';
import 'package:eventpass/widgets/aurora_background.dart';
import 'package:eventpass/widgets/category_style.dart';
import 'package:eventpass/widgets/confetti_burst.dart';
import 'package:eventpass/widgets/nfc/nfc_waves.dart';

enum _Stage { starting, waiting, sent, confirmed, failed }

const _mint = Color(0xFF34D399);

/// "Tap to check in": while this screen is open the phone answers NFC readers
/// as a tag holding the signed ticket (see TicketHceService.kt). The gate
/// verifies it offline; once the gate syncs, this screen sees the check-in
/// and celebrates.
class TapPassScreen extends ConsumerStatefulWidget {
  const TapPassScreen({super.key, required this.ticket});

  final Ticket ticket;

  @override
  ConsumerState<TapPassScreen> createState() => _TapPassScreenState();
}

class _TapPassScreenState extends ConsumerState<TapPassScreen> {
  final _waves = GlobalKey<NfcWavesState>();
  _Stage _stage = _Stage.starting;
  StreamSubscription<void>? _reads;
  Timer? _poll;
  Timer? _giveUp;
  bool _gaveUp = false;
  String? _checkedInAt;

  late final NfcService _nfc = ref.read(nfcServiceProvider);

  @override
  void initState() {
    super.initState();
    _nfc; // read the service now; ref can't be used in dispose()
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _reads?.cancel();
    _poll?.cancel();
    _giveUp?.cancel();
    unawaited(_nfc.stopEmulation());
    super.dispose();
  }

  Future<void> _start() async {
    try {
      _reads = _nfc.emulationReads.listen((_) => _onRead());
      await _nfc.startEmulation(widget.ticket.token!);
      if (mounted) setState(() => _stage = _Stage.waiting);
    } catch (_) {
      if (mounted) setState(() => _stage = _Stage.failed);
    }
  }

  /// A gate reader just read the whole ticket.
  void _onRead() {
    if (!mounted || _stage == _Stage.confirmed) return;
    HapticFeedback.heavyImpact();
    _waves.currentState?.burst();
    setState(() {
      _stage = _Stage.sent;
      _gaveUp = false;
    });
    // Ask the server until the gate's sync arrives. Gates sync right after
    // each scan, so this usually takes a few seconds; offline gates take longer.
    _poll?.cancel();
    _giveUp?.cancel();
    _poll = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      ref.read(apiTicketsNotifierProvider.notifier).apiGetMyTickets(silent: true);
    });
    _giveUp = Timer(const Duration(seconds: 30), () {
      _poll?.cancel();
      if (mounted) setState(() => _gaveUp = true);
    });
  }

  void _onConfirmed(Ticket t) {
    _poll?.cancel();
    _giveUp?.cancel();
    unawaited(_nfc.stopEmulation());
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 150), HapticFeedback.mediumImpact);
    setState(() {
      _stage = _Stage.confirmed;
      _checkedInAt = t.checkedInAt;
    });
  }

  String get _holderName {
    try {
      final payload = widget.ticket.token!.split('.')[1];
      return (jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(payload)))) as Map)['name']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<Ticket>?>(myTicketsProvider, (_, tickets) {
      if (_stage == _Stage.confirmed) return;
      for (final t in tickets ?? const <Ticket>[]) {
        if (t.id == widget.ticket.id && t.isCheckedIn) _onConfirmed(t);
      }
    });

    final loc = context.loc;
    final style = CategoryStyle.of(widget.ticket.event?.category ?? 'tech');
    final confirmed = _stage == _Stage.confirmed;
    final success = _stage == _Stage.sent || confirmed;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1E),
      body: AuroraBackground(
        colors: confirmed
            ? const [Color(0xFF10B981), Color(0xFF14B8A6), Color(0xFF22C55E)]
            : [...style.gradient, const Color(0xFFD946EF)],
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: whiteColor),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        Icon(Icons.lock_outline_rounded, color: whiteColor.withValues(alpha: 0.6), size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          widget.ticket.event?.title ?? '',
                          style: TextStyle(color: whiteColor.withValues(alpha: 0.75), fontSize: 13.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 16.w),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: NfcWaves(
                        key: _waves,
                        color: success ? _mint : whiteColor,
                        size: 330.w,
                        rings: 4,
                        active: _stage == _Stage.waiting || _stage == _Stage.sent,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 550),
                          switchInCurve: Curves.easeOutBack,
                          transitionBuilder: (child, a) => FadeTransition(
                            opacity: a,
                            child: ScaleTransition(scale: Tween(begin: 0.6, end: 1.0).animate(a), child: child),
                          ),
                          child: switch (_stage) {
                            _Stage.sent || _Stage.confirmed => _successCore(big: confirmed),
                            _Stage.failed => _failedCore(),
                            _ => _passCard(style),
                          },
                        ),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(a), child: child),
                    ),
                    child: KeyedSubtree(key: ValueKey('$_stage$_gaveUp'), child: _message()),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: switch (_stage) {
                        _Stage.waiting => _steps(),
                        _Stage.confirmed || _Stage.failed => _bottomButton(
                            confirmed ? loc.text_done : loc.text_close,
                            () => Navigator.of(context).pop(),
                          ),
                        _ => SizedBox(height: 56.h),
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (confirmed) const Positioned.fill(child: ConfettiBurst()),
          ],
        ),
      ),
    );
  }

  /// The ticket, floating gently: "this is what the gate will read".
  Widget _passCard(CategoryStyle style) {
    final event = widget.ticket.event;
    return Container(
      key: const ValueKey('card'),
      width: 168.w,
      height: 108.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [whiteColor.withValues(alpha: 0.32), whiteColor.withValues(alpha: 0.12)],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: whiteColor.withValues(alpha: 0.45)),
        boxShadow: [BoxShadow(color: style.gradient.first.withValues(alpha: 0.55), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(style.icon, color: whiteColor, size: 16.sp),
              const Spacer(),
              Icon(Icons.contactless_rounded, color: whiteColor, size: 22.sp)
                  .animate(onPlay: (c) => c.repeat())
                  .fadeOut(begin: 1, duration: 900.ms, delay: 300.ms, curve: Curves.easeInOut)
                  .then()
                  .fadeIn(duration: 900.ms),
            ],
          ),
          const Spacer(),
          Text(
            event?.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: whiteColor, fontSize: 13.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 2.h),
          Text(
            [_holderName, '#${(widget.ticket.id ?? '').split('-').first.toUpperCase()}'].where((s) => s.isNotEmpty).join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: whiteColor.withValues(alpha: 0.8), fontSize: 10.5.sp, letterSpacing: 0.4),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -7, end: 7, duration: 1800.ms, curve: Curves.easeInOut)
        .animate()
        .shimmer(delay: 600.ms, duration: 1500.ms, color: whiteColor.withValues(alpha: 0.5));
  }

  Widget _successCore({required bool big}) => Container(
        key: ValueKey('success$big'),
        width: big ? 150.w : 118.w,
        height: big ? 150.w : 118.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_mint, Color(0xFF059669)]),
          boxShadow: [BoxShadow(color: _mint.withValues(alpha: 0.6), blurRadius: big ? 60 : 36, spreadRadius: big ? 8 : 2)],
        ),
        padding: EdgeInsets.all(big ? 30.w : 26.w),
        child: AnimatedCheck(color: whiteColor, strokeWidth: big ? 9 : 7, delay: const Duration(milliseconds: 200)),
      );

  Widget _failedCore() => Container(
        key: const ValueKey('failed'),
        width: 118.w,
        height: 118.w,
        decoration: BoxDecoration(shape: BoxShape.circle, color: whiteColor.withValues(alpha: 0.1), border: Border.all(color: whiteColor.withValues(alpha: 0.3))),
        child: Icon(Icons.nfc_rounded, color: whiteColor.withValues(alpha: 0.7), size: 54.sp),
      ).animate().shake(hz: 4, offset: const Offset(8, 0), duration: 500.ms);

  Widget _message() {
    final loc = context.loc;
    final (String title, String? subtitle, bool shimmer) = switch (_stage) {
      _Stage.starting || _Stage.waiting => (loc.text_tap_to_check_in, loc.text_tap_waiting, false),
      _Stage.sent => (loc.text_tap_sent, _gaveUp ? loc.text_tap_sent_offline : loc.text_tap_waiting_confirm, !_gaveUp),
      _Stage.confirmed => (
          loc.text_youre_in,
          _checkedInAt == null ? null : loc.text_checked_in_at(Utils.formatDate(_checkedInAt, pattern: 'h:mm a')),
          false,
        ),
      _Stage.failed => (loc.text_tap_failed, null, false),
    };
    final confirmed = _stage == _Stage.confirmed;

    Widget heading = Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: whiteColor,
        fontSize: confirmed ? 40.sp : (_stage == _Stage.failed ? 17.sp : 28.sp),
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
    if (confirmed) {
      // A bright gradient sweeps through the headline.
      heading = ShaderMask(
        shaderCallback: (r) => const LinearGradient(colors: [whiteColor, Color(0xFFA7F3D0), whiteColor]).createShader(r),
        child: heading,
      ).animate().scale(begin: const Offset(0.5, 0.5), duration: 700.ms, curve: Curves.elasticOut);
    }

    Widget? sub = subtitle == null
        ? null
        : Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: whiteColor.withValues(alpha: 0.8), fontSize: 14.5.sp, height: 1.4));
    if (sub != null && shimmer) {
      sub = sub.animate(onPlay: (c) => c.repeat()).shimmer(duration: 1600.ms, color: _mint);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        children: [
          heading,
          if (sub != null) ...[SizedBox(height: 8.h), sub],
        ],
      ),
    );
  }

  Widget _steps() {
    final loc = context.loc;
    final steps = [
      (Icons.visibility_rounded, loc.text_tap_step_open),
      (Icons.swap_horiz_rounded, loc.text_tap_step_hold),
      (Icons.vibration_rounded, loc.text_tap_step_buzz),
    ];
    return Container(
      key: const ValueKey('steps'),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: whiteColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: whiteColor.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          for (final (i, (icon, text)) in steps.indexed)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: Row(
                children: [
                  Container(
                    width: 30.w,
                    height: 30.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: whiteColor.withValues(alpha: 0.14)),
                    child: Icon(icon, color: whiteColor, size: 16.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: Text(text, style: TextStyle(color: whiteColor, fontSize: 14.sp, fontWeight: FontWeight.w600))),
                  Text('${i + 1}', style: TextStyle(color: whiteColor.withValues(alpha: 0.4), fontSize: 13.sp, fontWeight: FontWeight.w700)),
                ],
              ),
            ).animate().fadeIn(delay: (250 + i * 140).ms, duration: 350.ms).slideX(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _bottomButton(String label, VoidCallback onTap) => SizedBox(
        key: ValueKey(label),
        width: double.infinity,
        height: 54.h,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: whiteColor,
            foregroundColor: _stage == _Stage.confirmed ? const Color(0xFF047857) : blackColor,
            elevation: 0,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          ),
          onPressed: onTap,
          child: Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack);
}
