import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/database/my_database.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/repository/auth_repository.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/dialog_widget/dialog_widget.dart';
import 'package:eventpass/widgets/theme_picker.dart';

/// Account card, device settings (appearance, language) and logout.
/// Settings are saved on the phone and survive logging out.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = context.loc;
    final p = context.palette;
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);

    Future<void> logout() async {
      final navigator = Navigator.of(context);
      await ref.read(authRepository).removeAllData();
      navigator.pushNamedAndRemoveUntil(Routes.LOGIN, (_) => false);
    }

    void setTheme(ThemeMode mode) {
      if (mode == themeMode) return;
      HapticFeedback.selectionClick();
      ref.read(themeModeProvider.notifier).state = mode;
      Utils.setThemeMode(mode);
    }

    void setLanguage(String code) {
      ref.read(localeProvider.notifier).state = Locale(code);
      Utils.setLanguage(code);
    }

    final sections = <Widget>[
      _card(
        context,
        child: ListTile(
          contentPadding: EdgeInsets.all(12.w),
          leading: CircleAvatar(
            radius: 24.r,
            backgroundColor: p.primarySoft,
            child: Text(
              (user?.name?.isNotEmpty ?? false) ? user!.name![0].toUpperCase() : '?',
              style: TextStyle(color: p.onPrimarySoft, fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
          ),
          title: Text(user?.name ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: p.heading)),
          subtitle: Text('${loc.text_signed_in_as} ${user?.email ?? ''}', style: TextStyle(color: p.label)),
          trailing: user?.role == 'organizer'
              ? Chip(
                  label: Text(loc.text_role_organizer),
                  labelStyle: TextStyle(color: p.onPrimarySoft, fontSize: 12.sp, fontWeight: FontWeight.w600),
                  backgroundColor: p.primarySoft,
                  side: BorderSide.none,
                )
              : null,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: 24.h, bottom: 10.h),
        child: Text(
          loc.text_settings.toUpperCase(),
          style: TextStyle(color: p.hint, fontSize: 12.sp, fontWeight: FontWeight.w700, letterSpacing: 1.2),
        ),
      ),
      _card(
        context,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingHeader(
                icon: _SunMoon(dark: context.isDark),
                title: loc.text_appearance,
                subtitle: switch (themeMode) {
                  ThemeMode.system => loc.text_theme_system_hint,
                  ThemeMode.light => loc.text_theme_light,
                  ThemeMode.dark => loc.text_theme_dark,
                },
              ),
              SizedBox(height: 14.h),
              ThemePicker(value: themeMode, onChanged: setTheme),
            ],
          ),
        ),
      ),
      SizedBox(height: 12.h),
      _card(
        context,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingHeader(
                icon: Icon(Icons.translate_rounded, color: p.onPrimarySoft, size: 20.sp),
                title: loc.text_language,
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'en', label: Text('English')),
                    ButtonSegment(value: 'ur', label: Text('اردو')),
                  ],
                  selected: {Localizations.localeOf(context).languageCode == 'ur' ? 'ur' : 'en'},
                  onSelectionChanged: (s) => setLanguage(s.first),
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 28.h),
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: context.accent(redColor),
          side: BorderSide(color: context.accent(redColor).withValues(alpha: 0.6)),
          minimumSize: Size.fromHeight(48.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        icon: const Icon(Icons.logout),
        label: Text(loc.text_logout),
        onPressed: () async {
          // Logging out deletes this phone's scan queue, so warn about unsynced scans.
          final pending = await ref.read(databaseProvider).scansDao.pendingCount();
          if (!context.mounted) return;
          DialogBuilder.showLogoutDialog(
            context: context,
            title: loc.text_logout,
            content: pending > 0 ? loc.text_logout_pending(pending) : loc.text_dialog_logout,
            callback: logout,
          );
        },
      ),
    ];

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        for (final (i, section) in sections.indexed)
          section.animate().fadeIn(delay: (i * 60).ms, duration: 350.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: p.border),
      ),
      child: child,
    );
  }
}

class _SettingHeader extends StatelessWidget {
  const _SettingHeader({required this.icon, required this.title, this.subtitle});

  final Widget icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.primarySoft, borderRadius: BorderRadius.circular(12.r)),
          child: icon,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: p.heading, fontSize: 15.sp, fontWeight: FontWeight.w700)),
              if (subtitle != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(subtitle!, key: ValueKey(subtitle), style: TextStyle(color: p.label, fontSize: 12.5.sp)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The sun spins away and the moon rises (and back) as the theme changes.
class _SunMoon extends StatelessWidget {
  const _SunMoon({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutBack,
        transitionBuilder: (child, a) => RotationTransition(
          turns: Tween(begin: 0.5, end: 1.0).animate(a),
          child: ScaleTransition(scale: a, child: child),
        ),
        child: Icon(
          dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          key: ValueKey(dark),
          color: dark ? const Color(0xFFC7D2FE) : const Color(0xFFF59E0B),
          size: 20.sp,
        ),
      );
}
