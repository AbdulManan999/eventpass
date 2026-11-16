import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/repository/auth_repository.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/widgets/dialog_widget/dialog_widget.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = context.loc;
    final user = ref.watch(currentUserProvider);

    Future<void> logout() async {
      final navigator = Navigator.of(context);
      await ref.read(authRepository).removeAllData();
      navigator.pushNamedAndRemoveUntil(Routes.LOGIN, (_) => false);
    }

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Card(
          elevation: 0,
          color: whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r), side: const BorderSide(color: greyColor)),
          child: ListTile(
            contentPadding: EdgeInsets.all(12.w),
            leading: CircleAvatar(
              radius: 24.r,
              backgroundColor: primaryLightColor,
              child: Text(
                (user?.name?.isNotEmpty ?? false) ? user!.name![0].toUpperCase() : '?',
                style: TextStyle(color: primaryColor, fontSize: 20.sp, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${loc.text_signed_in_as} ${user?.email ?? ''}'),
          ),
        ),
        SizedBox(height: 16.h),
        Text(loc.text_language, style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 8.h),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'en', label: Text('English')),
            ButtonSegment(value: 'ur', label: Text('اردو')),
          ],
          selected: {Localizations.localeOf(context).languageCode == 'ur' ? 'ur' : 'en'},
          onSelectionChanged: (s) => ref.read(localeProvider.notifier).state = Locale(s.first),
        ),
        SizedBox(height: 32.h),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: redColor, side: const BorderSide(color: redColor)),
          icon: const Icon(Icons.logout),
          label: Text(loc.text_logout),
          onPressed: () => DialogBuilder.showLogoutDialog(
            context: context,
            title: loc.text_logout,
            content: loc.text_dialog_logout,
            callback: logout,
          ),
        ),
      ],
    );
  }
}
