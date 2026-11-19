import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/utils/colors.dart';

class PillOption<T> {
  const PillOption(this.value, this.icon, this.label);

  final T value;
  final IconData icon;
  final String label;
}

/// A dark glass toggle whose bright thumb slides between options.
class SegmentedPill<T> extends StatelessWidget {
  const SegmentedPill({super.key, required this.options, required this.value, required this.onChanged});

  final List<PillOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final index = options.indexWhere((o) => o.value == value);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      height: 44.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: whiteColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: whiteColor.withValues(alpha: 0.12)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutBack,
            alignment: Alignment(
              (options.length == 1 ? 0 : -1 + 2 * index / (options.length - 1)) * (rtl ? -1 : 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / options.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFD946EF)]),
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [BoxShadow(color: const Color(0xFFA855F7).withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(0, 4))],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final o in options)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(o.value),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        color: o.value == value ? whiteColor : whiteColor.withValues(alpha: 0.6),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: o.value == value ? 1.15 : 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            child: Icon(o.icon, size: 18.sp, color: o.value == value ? whiteColor : whiteColor.withValues(alpha: 0.6)),
                          ),
                          SizedBox(width: 6.w),
                          Text(o.label),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
