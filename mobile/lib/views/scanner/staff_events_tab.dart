import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/providers/api_scanner_notifier.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/event_card.dart';
import 'package:eventpass/widgets/pill.dart';
import 'package:eventpass/widgets/session_expired_handler.dart';
import 'package:eventpass/widgets/status_view.dart';

/// Gate staff home: the events this user may scan, and the gate name this phone reports.
class StaffEventsTab extends ConsumerStatefulWidget {
  const StaffEventsTab({super.key});

  @override
  StaffEventsTabState createState() => StaffEventsTabState();
}

class StaffEventsTabState extends ConsumerState<StaffEventsTab> {
  String _gate = '';

  @override
  void initState() {
    super.initState();
    Utils.getGateName().then((g) => mounted ? setState(() => _gate = g) : null);
  }

  Future<void> _load() => ref.read(apiScannerNotifierProvider.notifier).apiGetStaffEvents();

  Future<void> _editGate() async {
    final loc = context.loc;
    final controller = TextEditingController(text: _gate);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.text_gate_name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 40,
              decoration: InputDecoration(hintText: loc.text_gate_name_hint),
            ),
            Text(loc.text_gate_name_help, style: TextStyle(fontSize: 12.sp, color: hintColor)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.text_close)),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(loc.text_save)),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await Utils.setGateName(name);
      setState(() => _gate = name);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ApiStatesModel>(apiScannerNotifierProvider, (_, s) {
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      if (s.states == States.SESSIONEXPIRED) handleSessionExpired(context, ref);
      if (s.states == States.ERROR && ref.read(scannerBundleProvider) == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.message)));
      }
    });

    final loc = context.loc;
    final events = ref.watch(staffEventsProvider);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primaryDarkColor, primaryColor]),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(color: whiteColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(Icons.qr_code_scanner_rounded, color: whiteColor, size: 28.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.text_gate_name, style: TextStyle(color: whiteColor.withValues(alpha: 0.8), fontSize: 12.sp)),
                      Text(_gate, style: TextStyle(color: whiteColor, fontSize: 17.sp, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                IconButton(onPressed: _editGate, icon: const Icon(Icons.edit_rounded, color: whiteColor)),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          Text(loc.text_staff_events_hint, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: headingColor)),
          SizedBox(height: 10.h),
          if (events != null && events.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 40.h),
              child: StatusView(icon: Icons.badge_outlined, message: loc.text_no_staff_events, actionText: loc.text_retry, onAction: _load),
            ),
          for (final e in events ?? const <Event>[])
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: EventCard(
                event: e,
                badges: [
                  Pill(
                    text: e.role == 'organizer' ? loc.text_role_organizer : loc.text_role_staff,
                    color: e.role == 'organizer' ? primaryColor : secondaryColor,
                    icon: Icons.badge_outlined,
                  ),
                  if (e.isLive()) Pill(text: loc.text_live_now, color: greenColor, pulse: true),
                ],
                trailing: Icon(Icons.qr_code_scanner_rounded, color: primaryColor, size: 26.sp),
                onTap: () => Navigator.of(context).pushNamed(Routes.SCANNER, arguments: e),
              ),
            ),
        ],
      ),
    );
  }
}
