import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/utils/colors.dart';

/// Small rounded label: "Live now", "Checked in", "12 spots left"…
class Pill extends StatelessWidget {
  const Pill({super.key, required this.text, required this.color, this.icon, this.filled = false, this.pulse = false});

  final String text;
  final Color color;
  final IconData? icon;

  /// Solid background with white text, for use on gradients.
  final bool filled;

  /// Show a blinking dot (for "live").
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : context.accent(color);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: context.isDark ? 0.22 : 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse) ...[_PulseDot(color: fg), SizedBox(width: 5.w)],
          if (icon != null) ...[Icon(icon, size: 12.sp, color: fg), SizedBox(width: 4.w)],
          Text(text, style: TextStyle(color: fg, fontSize: 11.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});

  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.3, end: 1.0).animate(_c),
        child: Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      );
}
