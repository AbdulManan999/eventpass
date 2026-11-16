import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eventpass/l10n/app_localizations.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/models/QueuedScan.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/providers/api_scanner_notifier.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/loading_widget.dart';
import 'package:eventpass/widgets/session_expired_handler.dart';
import 'package:eventpass/widgets/status_view.dart';

/// Gate scanner. Verifies each QR code on the phone in milliseconds, saves the
/// scan locally, and syncs in the background, so the line keeps moving with
/// no connection at all.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, required this.event});

  final Event event;

  @override
  ScannerScreenState createState() => ScannerScreenState();
}

class ScannerScreenState extends ConsumerState<ScannerScreen> {
  final _camera = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  Timer? _syncTimer;
  Timer? _hideResult;
  bool _showResult = false;
  String? _lastValue;
  DateTime _lastValueAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// How long a result stays on screen, and how long the same code is ignored.
  static const _resultDuration = Duration(milliseconds: 1800);
  static const _sameCodeCooldown = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(apiScannerNotifierProvider.notifier).apiOpenScanner(widget.event.id!));
    _syncTimer = Timer.periodic(const Duration(seconds: 20), (_) => ref.read(apiScannerNotifierProvider.notifier).apiSync());
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _hideResult?.cancel();
    _camera.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || _showResult) return;
    final now = DateTime.now();
    if (value == _lastValue && now.difference(_lastValueAt) < _sameCodeCooldown) return;
    _lastValue = value;
    _lastValueAt = now;

    setState(() => _showResult = true);
    final scan = await ref.read(apiScannerNotifierProvider.notifier).scan(value);
    if (scan == null) return;
    scan.admitted ? HapticFeedback.lightImpact() : HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
    _hideResult?.cancel();
    _hideResult = Timer(_resultDuration, () {
      if (mounted) setState(() => _showResult = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ApiStatesModel>(apiScannerNotifierProvider, (_, s) {
      if (s.states == States.SESSIONEXPIRED) handleSessionExpired(context, ref);
    });
    return Stack(children: [_mainLayout(), const LoadingWidget()]);
  }

  Widget _mainLayout() {
    final loc = context.loc;
    final state = ref.watch(apiScannerNotifierProvider);
    final bundle = ref.watch(scannerBundleProvider);
    final history = ref.watch(scanHistoryProvider);
    final pending = history.where((s) => !s.isSynced).length;

    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: blackColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.title ?? '', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            Text(loc.text_gate_scanner, style: TextStyle(fontSize: 12.sp, color: whiteColor.withValues(alpha: 0.7))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: _camera.toggleTorch,
          ),
          IconButton(
            tooltip: loc.text_scan_history,
            icon: Badge(isLabelVisible: pending > 0, label: Text('$pending'), child: const Icon(Icons.history_rounded)),
            onPressed: () => _showHistory(history),
          ),
        ],
      ),
      body: bundle == null
          ? (state.states == States.ERROR
              ? Theme(
                  data: ThemeData.dark(),
                  child: StatusView(
                    icon: Icons.cloud_off,
                    message: state.message,
                    actionText: loc.text_retry,
                    onAction: () => ref.read(apiScannerNotifierProvider.notifier).apiOpenScanner(widget.event.id!),
                  ),
                )
              : const SizedBox.shrink())
          : Column(
              children: [
                _statusStrip(),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _camera,
                        onDetect: _onDetect,
                        errorBuilder: (context, error) => Theme(
                          data: ThemeData.dark(),
                          child: StatusView(icon: Icons.no_photography_outlined, message: loc.text_camera_error),
                        ),
                      ),
                      const _ScanFrame(),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 24.h,
                        child: Text(
                          loc.text_point_camera,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: whiteColor, fontSize: 14.sp, shadows: const [Shadow(blurRadius: 6)]),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _showResult ? _ResultOverlay(scan: ref.watch(lastScanProvider)) : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                _statsBar(history),
              ],
            ),
    );
  }

  Widget _statusStrip() {
    final loc = context.loc;
    final bundle = ref.watch(scannerBundleProvider)!;
    final sync = ref.watch(syncStatusProvider);
    final lastSynced = ref.watch(lastSyncedAtProvider);
    final overruled = ref.watch(overruledCountProvider);

    final (IconData icon, Color color, String text) = switch (sync) {
      SyncStatus.syncing => (Icons.sync_rounded, whiteColor, loc.text_syncing),
      SyncStatus.offline => (Icons.cloud_off_rounded, amberColor, loc.text_offline_mode),
      SyncStatus.failed => (Icons.sync_problem_rounded, redColor, loc.text_sync_failed),
      SyncStatus.idle => (
          Icons.cloud_done_rounded,
          greenColor,
          lastSynced == null ? loc.text_ready_to_scan : loc.text_synced(Utils.formatDate(lastSynced.toIso8601String(), pattern: 'h:mm a')),
        ),
    };

    return Container(
      width: double.infinity,
      color: darkSurfaceColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_rounded, size: 16.sp, color: greenColor),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  loc.text_verified_offline(bundle.revokedTicketIds.length),
                  style: TextStyle(color: darkModeTextColor, fontSize: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.w600))),
              if (sync != SyncStatus.syncing)
                GestureDetector(
                  onTap: () => ref.read(apiScannerNotifierProvider.notifier).apiSync(),
                  child: Text(loc.text_sync_now, style: TextStyle(color: primaryLightColor, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          if (overruled > 0) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16.sp, color: amberColor),
                SizedBox(width: 6.w),
                Expanded(child: Text(loc.text_overruled(overruled), style: TextStyle(color: amberColor, fontSize: 12.sp))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statsBar(List<QueuedScan> history) {
    final loc = context.loc;
    final admitted = history.where((s) => s.admitted).length;
    final pending = history.where((s) => !s.isSynced).length;
    return Container(
      color: darkSurfaceColor,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: [
          _stat('$admitted', loc.text_admitted, greenColor),
          _stat('${history.length - admitted}', loc.text_rejected, redColor),
          _stat('$pending', loc.text_pending_sync, pending > 0 ? amberColor : darkModeTextColor),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) => Expanded(
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 22.sp, fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(color: darkModeTextColor, fontSize: 11.sp)),
          ],
        ),
      );

  void _showHistory(List<QueuedScan> history) {
    final loc = context.loc;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (context, controller) => Column(
          children: [
            Text(loc.text_scan_history, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Expanded(
              child: history.isEmpty
                  ? StatusView(icon: Icons.qr_code_2, message: loc.text_no_scans)
                  : ListView.separated(
                      controller: controller,
                      itemCount: history.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final s = history[i];
                        final look = ResultLook.of(loc, s.effectiveResult);
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: look.color.withValues(alpha: 0.12), child: Icon(look.icon, color: look.color)),
                          title: Text(s.holderName?.isNotEmpty == true ? s.holderName! : look.label),
                          subtitle: Text(
                            [
                              Utils.formatDate(s.scannedAt, pattern: 'h:mm:ss a'),
                              look.label,
                              if (s.overruled) loc.text_scanned_by_server(ResultLook.of(loc, s.serverResult!).label),
                            ].join(' · '),
                          ),
                          trailing: s.isSynced
                              ? const Icon(Icons.cloud_done_outlined, color: greenColor)
                              : Tooltip(message: loc.text_pending, child: const Icon(Icons.cloud_upload_outlined, color: amberColor)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

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
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({required this.scan});

  final QueuedScan? scan;

  @override
  Widget build(BuildContext context) {
    if (scan == null) return const SizedBox.shrink();
    final look = ResultLook.of(context.loc, scan!.localResult);
    return Container(
      key: ValueKey(scan!.id),
      color: look.color.withValues(alpha: 0.92),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(look.icon, color: whiteColor, size: 110.sp),
          SizedBox(height: 12.h),
          Text(look.label, style: TextStyle(color: whiteColor, fontSize: 30.sp, fontWeight: FontWeight.w800)),
          if (scan!.holderName?.isNotEmpty == true) ...[
            SizedBox(height: 6.h),
            Text(scan!.holderName!, style: TextStyle(color: whiteColor, fontSize: 20.sp, fontWeight: FontWeight.w500)),
          ],
          SizedBox(height: 4.h),
          Text(
            '#${(scan!.ticketId ?? '').split('-').first.toUpperCase()}',
            style: TextStyle(color: whiteColor.withValues(alpha: 0.8), fontSize: 13.sp, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }
}

/// Darkened camera view with a clear square and bright corners to aim at.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(painter: _FramePainter(side: 250.w)));
}

class _FramePainter extends CustomPainter {
  _FramePainter({required this.side});

  final double side;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: side, height: side);
    final hole = RRect.fromRectAndRadius(rect, const Radius.circular(20));
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(hole)),
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    final corner = Paint()
      ..color = whiteColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 36.0;
    for (final (dx, dy, x, y) in [
      (1.0, 1.0, rect.left, rect.top),
      (-1.0, 1.0, rect.right, rect.top),
      (1.0, -1.0, rect.left, rect.bottom),
      (-1.0, -1.0, rect.right, rect.bottom),
    ]) {
      canvas.drawLine(Offset(x, y + dy * 12), Offset(x, y + dy * len), corner);
      canvas.drawLine(Offset(x + dx * 12, y), Offset(x + dx * len, y), corner);
    }
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.side != side;
}
