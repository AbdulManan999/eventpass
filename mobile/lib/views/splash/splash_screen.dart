import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/strings.dart';
import 'package:eventpass/utils/utils.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      final loggedIn = await Utils.getIsLoggedIn();
      if (loggedIn) ref.read(currentUserProvider.notifier).state = await Utils.getUserData();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(loggedIn ? Routes.HOME : Routes.LOGIN, (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? nightBackgroundColor : primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number_outlined, color: whiteColor, size: 64.sp),
            SizedBox(height: 12.h),
            Text(
              appName,
              style: TextStyle(color: whiteColor, fontSize: 28.sp, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
