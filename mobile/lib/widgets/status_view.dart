import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/utils/colors.dart';

/// Centered icon + message + optional action, for empty and error states.
class StatusView extends StatelessWidget {
  const StatusView({super.key, required this.icon, required this.message, this.actionText, this.onAction});

  final IconData icon;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56.sp, color: context.palette.hint),
            SizedBox(height: 16.h),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            if (actionText != null) ...[
              SizedBox(height: 16.h),
              OutlinedButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}
