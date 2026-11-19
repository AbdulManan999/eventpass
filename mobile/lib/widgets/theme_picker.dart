import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/utils/colors.dart';

/// Three cards (System, Light, Dark), each showing a tiny preview of the app
/// in that theme. The selected card lifts, gets a brand border and a check.
class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key, required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final options = [
      (ThemeMode.system, loc.text_theme_system),
      (ThemeMode.light, loc.text_theme_light),
      (ThemeMode.dark, loc.text_theme_dark),
    ];
    return Row(
      children: [
        for (final (i, (mode, label)) in options.indexed) ...[
          if (i > 0) SizedBox(width: 10.w),
          Expanded(
            child: _Option(key: ValueKey(mode), mode: mode, label: label, selected: mode == value, onTap: () => onChanged(mode)),
          ),
        ],
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({super.key, required this.mode, required this.label, required this.selected, required this.onTap});

  final ThemeMode mode;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1 : 0.95,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: selected ? accent : p.border, width: selected ? 2 : 1),
              boxShadow: selected
                  ? [BoxShadow(color: accent.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 6))]
                  : const [],
            ),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 0.78,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: switch (mode) {
                      ThemeMode.light => const _MiniApp(dark: false),
                      ThemeMode.dark => const _MiniApp(dark: true),
                      ThemeMode.system => const Stack(
                        fit: StackFit.expand,
                        children: [
                          _MiniApp(dark: false),
                          ClipPath(clipper: _DiagonalClipper(), child: _MiniApp(dark: true)),
                        ],
                      ),
                    },
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                      child: Icon(
                        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        key: ValueKey(selected),
                        size: 16.sp,
                        color: selected ? accent : p.hint,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? p.heading : p.label,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A tiny sketch of the events screen: header, a featured card, two list rows
/// and the navigation bar, in the given theme's colours.
class _MiniApp extends StatelessWidget {
  const _MiniApp({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final p = dark ? AppPalette.dark : AppPalette.light;
    Widget line(double widthFactor, Color color, {double height = 4}) => FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        height: height,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      ),
    );
    Widget row() => Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: p.border, width: 0.6),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: p.primarySoft, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              children: [
                line(0.9, p.heading.withValues(alpha: 0.75)),
                const SizedBox(height: 3),
                line(0.55, p.hint.withValues(alpha: 0.6), height: 3),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      color: p.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
              // On very narrow screens the sketch is cropped rather than overflowing.
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxHeight: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      line(0.5, p.heading, height: 5),
                      const SizedBox(height: 6),
                      Container(
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFD946EF)]),
                        ),
                      ),
                      row(),
                      row(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 12,
            color: p.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < 4; i++)
                  Container(
                    width: 7,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i == 0 ? p.onPrimarySoft : p.hint.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The lower-right triangle: "light by day, dark by night".
class _DiagonalClipper extends CustomClipper<Path> {
  const _DiagonalClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}
