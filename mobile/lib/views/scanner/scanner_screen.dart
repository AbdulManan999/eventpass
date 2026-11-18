import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/models/QueuedScan.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/providers/api_scanner_notifier.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/views/scanner/nfc_reader_view.dart';
import 'package:eventpass/views/scanner/scan_result_overlay.dart';
import 'package:eventpass/widgets/loading_widget.dart';
import 'package:eventpass/widgets/segmented_pill.dart';
import 'package:eventpass/widgets/session_expired_handler.dart';
import 'package:eventpass/widgets/status_view.dart';

/// Gate scanner. Reads a ticket from a QR code (camera) or an NFC tap
/// (wristband, sticker or phone), verifies it on the phone in milliseconds,
/// saves the scan locally, and syncs in the background, so the line keeps
/// moving with no connection at all.
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
  String _mode = ScanMethods.qr;
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

  void _onDetect(BarcodeCapture capture) {
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value != null) _handle(value, ScanMethods.qr);
  }

  /// Verifies a ticket read by either method and shows the verdict.
  Future<void> _handle(String value, String method) async {
    if (_showResult) return;
    final now = DateTime.now();
    if (value == _lastValue && now.difference(_lastValueAt) < _sameCodeCooldown) return;
    _lastValue = value;
    _lastValueAt = now;

    setState(() => _showResult = true);
    final scan = await ref.read(apiScannerNotifierProvider.notifier).scan(value, method: method);
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
    final lastScan = ref.watch(lastScanProvider);

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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
            child: _mode == ScanMethods.qr
                ? IconButton(key: const ValueKey('torch'), icon: const Icon(Icons.flashlight_on_outlined), onPressed: _camera.toggleTorch)
                : const SizedBox.shrink(),
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
                Container(
                  color: darkSurfaceColor,
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                  child: SegmentedPill<String>(
                    value: _mode,
                    onChanged: (m) {
                      if (m == _mode) return;
                      HapticFeedback.selectionClick();
                      setState(() => _mode = m);
                    },
                    options: [
                      PillOption(ScanMethods.qr, Icons.qr_code_scanner_rounded, loc.text_scan_mode_qr),
                      PillOption(ScanMethods.nfc, Icons.contactless_rounded, loc.text_scan_mode_nfc),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, a) => FadeTransition(
                          opacity: a,
                          child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(a), child: child),
                        ),
                        // Leaving QR mode removes the camera view, which also stops the camera.
                        child: _mode == ScanMethods.qr
                            ? KeyedSubtree(key: const ValueKey('qr'), child: _cameraView())
                            : NfcReaderView(key: const ValueKey('nfc'), onTicket: (token) => _handle(token, ScanMethods.nfc)),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _showResult && lastScan != null
                            ? ScanResultOverlay(key: ValueKey(lastScan.id), scan: lastScan)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                _statsBar(history),
              ],
            ),
    );
  }

  Widget _cameraView() {
    final loc = context.loc;
    return Stack(
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
      ],
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

  /// The number rolls to its new value and pops briefly when it changes.
  Widget _stat(String value, String label, Color color) => Expanded(
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: double.parse(value)),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => Text(
                '${v.round()}',
                style: TextStyle(color: color, fontSize: 22.sp, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            )
                .animate(key: ValueKey(value))
                .scale(begin: const Offset(1.25, 1.25), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOutBack),
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
                              ResultLook.methodLabel(loc, s.method),
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
