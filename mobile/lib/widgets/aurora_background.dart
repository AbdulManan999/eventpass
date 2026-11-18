import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Slowly drifting blurred colour blobs over a dark base: a living backdrop
/// for full-screen moments (tap to check in, success screens).
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.colors, this.base = const Color(0xFF0B0B1E), this.child});

  /// Two to four colours for the blobs.
  final List<Color> colors;
  final Color base;
  final Widget? child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: widget.base),
          RepaintBoundary(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60, tileMode: TileMode.decal),
              child: CustomPaint(painter: _BlobPainter(_c, widget.colors)),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      );
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.anim, this.colors) : super(repaint: anim);

  final Animation<double> anim;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value * 2 * pi;
    for (var i = 0; i < colors.length; i++) {
      // Each blob follows its own slow Lissajous path.
      final phase = i * 2.1;
      final center = Offset(
        size.width * (0.5 + 0.38 * sin(t + phase)),
        size.height * (0.42 + 0.3 * cos(t * (i.isEven ? 1 : -1) + phase * 1.3)),
      );
      final radius = size.shortestSide * (0.42 + 0.08 * sin(t * 2 + phase));
      canvas.drawCircle(center, radius, Paint()..color = colors[i].withValues(alpha: 0.55));
    }
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.colors != colors;
}
