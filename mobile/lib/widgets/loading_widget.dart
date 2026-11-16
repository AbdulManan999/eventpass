import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/providers/api_auth_notifier.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/strings.dart';
import 'package:eventpass/providers/api_events_notifier.dart';
import 'package:eventpass/providers/api_tickets_notifier.dart';
import 'package:eventpass/providers/api_scanner_notifier.dart';
// [LOADING_PROVIDER_IMPORTS]

/// Full-screen blocking loader. Place it as the LAST child of a Stack in every
/// screen that calls an API:  Stack(children: [_mainLayout(), const LoadingWidget()])
///
/// It is visible whenever ANY registered API notifier is in States.LOADING,
/// so every new module notifier must be added to [_isLoading].
class LoadingWidget extends ConsumerStatefulWidget {
  const LoadingWidget({super.key});

  @override
  LoadingWidgetState createState() => LoadingWidgetState();
}

class LoadingWidgetState extends ConsumerState<LoadingWidget> with TickerProviderStateMixin {
  late final AnimationController _spinCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  late final AnimationController _fadeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  late final Animation<double> _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

  @override
  void dispose() {
    _spinCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool get _isLoading {
    final states = <States>[
      ref.watch(apiAuthNotifierProvider).states,
      ref.watch(apiEventsNotifierProvider).states,
      ref.watch(apiTicketsNotifierProvider).states,
      ref.watch(apiScannerNotifierProvider).states,
      // [LOADING_PROVIDERS]
    ];
    return states.contains(States.LOADING);
  }

  @override
  Widget build(BuildContext context) {
    final show = _isLoading;
    show ? _fadeCtrl.forward() : _fadeCtrl.reverse();

    return FadeTransition(
      opacity: _fadeAnim,
      child: !show
          ? const SizedBox.shrink()
          : SizedBox.expand(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                  alignment: Alignment.center,
                  child: Container(
                    width: 160.w,
                    padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpinKitRipple(color: primaryColor, size: 56.sp, controller: _spinCtrl),
                        SizedBox(height: 16.h),
                        Text(
                          loadingText,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: labelColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
