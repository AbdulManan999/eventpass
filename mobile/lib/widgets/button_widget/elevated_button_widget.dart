import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/utils/colors.dart';

/// Primary full-width action button.
class ElevatedButtonWithoutIcon extends StatelessWidget {
  const ElevatedButtonWithoutIcon({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = primaryColor,
    this.textColor = whiteColor,
    this.height,
    this.borderRadius,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 52.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: greyColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 12.r)),
        ),
        child: Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
