import 'dart:math';

import 'package:flutter/material.dart';

/// Rings that keep rippling out from [child], like a contactless signal.
/// Call [NfcWavesState.burst] (via a GlobalKey) to flash one strong ring,
/// e.g. the moment a tag is read.
class NfcWaves extends StatefulWidget {
  const NfcWaves({
    super.key,
    required this.child,
    required this.color,
    this.size = 280,
    this.rings = 3,
    this.active = true,
    this.period = const Duration(milliseconds: 2600),
  });

  final Widget child;
  final Color color;
  final double size;
  final int rings;

  /// When false the rings fade out and stop (e.g. NFC is off).
  final bool active;
  final Duration period;

  @override
  NfcWavesState createState() => NfcWavesState();
}

class NfcWavesState extends State<NfcWaves> with TickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(vsync: this, duration: widget.period);
  late final AnimationController _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  @override
  void initState() {
    super.initState();
    if (widget.active) _ripple.repeat();
  }

  @override
  void didUpdateWidget(NfcWaves oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_ripple.isAnimating) _ripple.repeat();
    if (!widget.active && _ripple.isAnimating) _ripple.stop();
  }

  void burst() => _burst.forward(from: 0);

  @override
  void dispose() {
    _ripple.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          painter: _WavesPainter(
            ripple: _ripple,
            burst: _burst,
            color: widget.color,
            rings: widget.rings,
            active: widget.active,
          ),
          child: Center(child: widget.child),
        ),
      );
}

class _WavesPainter extends CustomPainter {
  _WavesPainter({required this.ripple, required this.burst, required this.color, required this.rings, required this.active})
      : super(repaint: Listenable.merge([ripple, burst]));

  final Animation<double> ripple;
  final Animation<double> burst;
  final Color color;
  final int rings;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    final minR = maxR * 0.34;

    if (active) {
      for (var i = 0; i < rings; i++) {
        final t = (ripple.value + i / rings) % 1.0;
        final eased = Curves.easeOutCubic.transform(t);
        final r = minR + (maxR - minR) * eased;
        final fade = pow(1 - t, 1.6).toDouble();
        // A soft glow under a crisp ring.
        canvas.drawCircle(
          center,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..color = color.withValues(alpha: 0.18 * fade)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        canvas.drawCircle(
          center,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2 * (1 - t) + 0.6
            ..color = color.withValues(alpha: 0.75 * fade),
        );
      }
    }

    if (burst.value > 0 && burst.value < 1) {
      final t = Curves.easeOutExpo.transform(burst.value);
      canvas.drawCircle(
        center,
        minR + (maxR * 1.1 - minR) * t,
        Paint()..color = color.withValues(alpha: 0.35 * (1 - burst.value)),
      );
    }
  }

  @override
  bool shouldRepaint(_WavesPainter old) => old.color != color || old.active != active || old.rings != rings;
}
