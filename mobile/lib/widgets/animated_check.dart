import 'dart:ui';

import 'package:flutter/material.dart';

/// A circle that draws itself, then a check mark stroke by stroke.
class AnimatedCheck extends StatelessWidget {
  const AnimatedCheck({
    super.key,
    required this.color,
    this.size = 120,
    this.strokeWidth = 7,
    this.duration = const Duration(milliseconds: 750),
    this.delay = Duration.zero,
  });

  final Color color;
  final double size;
  final double strokeWidth;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) => _Delayed(
        delay: delay,
        builder: (started) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: started ? 1 : 0),
          duration: duration,
          curve: Curves.easeInOutCubic,
          builder: (_, t, _) => CustomPaint(
            size: Size.square(size),
            painter: _CheckPainter(progress: t, color: color, strokeWidth: strokeWidth),
          ),
        ),
      );
}

class _Delayed extends StatefulWidget {
  const _Delayed({required this.delay, required this.builder});

  final Duration delay;
  final Widget Function(bool started) builder;

  @override
  State<_Delayed> createState() => _DelayedState();
}

class _DelayedState extends State<_Delayed> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _started = true);
      });
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _started = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(_started);
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color, required this.strokeWidth});

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);

    // First 55%: the circle. Remaining 45%: the check.
    final circleT = (progress / 0.55).clamp(0.0, 1.0);
    canvas.drawArc(rect, -1.5708, 6.2832 * circleT, false, paint);

    final checkT = ((progress - 0.55) / 0.45).clamp(0.0, 1.0);
    if (checkT == 0) return;
    final w = size.width, h = size.height;
    final check = Path()
      ..moveTo(w * 0.28, h * 0.53)
      ..lineTo(w * 0.44, h * 0.68)
      ..lineTo(w * 0.73, h * 0.37);
    for (final PathMetric m in check.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * checkT), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress || old.color != color;
}
