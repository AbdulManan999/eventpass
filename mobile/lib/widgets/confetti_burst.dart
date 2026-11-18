import 'dart:math';

import 'package:flutter/material.dart';

/// A one-shot burst of confetti from the top centre. Plays once when built;
/// give it a new key to play again.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, this.colors = _defaultColors, this.count = 70, this.origin = const Alignment(0, -0.35)});

  static const _defaultColors = [Color(0xFF6366F1), Color(0xFFD946EF), Color(0xFF22C55E), Color(0xFFF59E0B), Color(0xFF06B6D4), Colors.white];

  final List<Color> colors;
  final int count;
  final Alignment origin;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _pieces = List.generate(widget.count, (i) {
      final angle = -pi / 2 + (rnd.nextDouble() - 0.5) * pi * 1.15;
      return _Piece(
        velocity: Offset(cos(angle), sin(angle)) * (380 + rnd.nextDouble() * 520),
        color: widget.colors[i % widget.colors.length],
        spin: (rnd.nextDouble() - 0.5) * 18,
        size: Size(6 + rnd.nextDouble() * 6, 10 + rnd.nextDouble() * 8),
        round: rnd.nextDouble() < 0.3,
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(size: Size.infinite, painter: _ConfettiPainter(_c, _pieces, widget.origin)),
      );
}

class _Piece {
  _Piece({required this.velocity, required this.color, required this.spin, required this.size, required this.round});

  final Offset velocity;
  final Color color;
  final double spin;
  final Size size;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.anim, this.pieces, this.origin) : super(repaint: anim);

  final Animation<double> anim;
  final List<_Piece> pieces;
  final Alignment origin;

  static const _gravity = 900.0;
  static const _seconds = 2.2;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value * _seconds;
    if (anim.value >= 1) return;
    final start = origin.alongSize(size);
    final fade = anim.value < 0.7 ? 1.0 : 1 - (anim.value - 0.7) / 0.3;
    for (final p in pieces) {
      // Air drag slows the burst; gravity pulls it down.
      final drag = (1 - exp(-2.2 * t)) / 2.2;
      final pos = start + Offset(p.velocity.dx * drag, p.velocity.dy * drag + 0.5 * _gravity * t * t * 0.55);
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size.width / 2, paint);
      } else {
        // Flutter of a paper strip: scale width with a cosine of its spin.
        canvas.scale(cos(p.spin * t * 0.7).abs().clamp(0.2, 1.0), 1);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: p.size.width, height: p.size.height), const Radius.circular(2)),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
