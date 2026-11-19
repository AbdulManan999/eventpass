import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/Event.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/providers/api_events_notifier.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/widgets/category_style.dart';
import 'package:eventpass/widgets/event_card.dart';
import 'package:eventpass/widgets/status_view.dart';

/// Search text and category filter for the events list ('all' = no filter).
final eventSearchProvider = StateProvider.autoDispose<String>((ref) => '', name: 'eventSearchProvider');
final eventCategoryProvider = StateProvider.autoDispose<String>((ref) => 'all', name: 'eventCategoryProvider');

class EventsTab extends ConsumerStatefulWidget {
  const EventsTab({super.key});

  @override
  EventsTabState createState() => EventsTabState();
}

class EventsTabState extends ConsumerState<EventsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(eventsListProvider) == null) _load();
    });
  }

  Future<void> _load() => ref.read(apiEventsNotifierProvider.notifier).apiGetEvents();

  void _open(Event e) => Navigator.of(context).pushNamed(Routes.EVENT_DETAIL, arguments: e);

  @override
  Widget build(BuildContext context) {
    ref.listen<ApiStatesModel>(apiEventsNotifierProvider, (_, s) {
      // A failed refresh keeps the old list on screen; say why in a snackbar.
      if (s.states == States.ERROR && ref.read(eventsListProvider) != null && (ModalRoute.of(context)?.isCurrent ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.message)));
      }
    });

    final loc = context.loc;
    final events = ref.watch(eventsListProvider);
    final state = ref.watch(apiEventsNotifierProvider);
    final query = ref.watch(eventSearchProvider).trim().toLowerCase();
    final category = ref.watch(eventCategoryProvider);
    final user = ref.watch(currentUserProvider);

    if (events == null) {
      return state.states == States.ERROR
          ? StatusView(icon: Icons.cloud_off, message: state.message, actionText: loc.text_retry, onAction: _load)
          : const SizedBox.shrink();
    }

    bool matches(Event e) =>
        (category == 'all' || e.category == category) &&
        (query.isEmpty ||
            (e.title ?? '').toLowerCase().contains(query) ||
            (e.venue?.name ?? '').toLowerCase().contains(query));
    final filtered = events.where(matches).toList();
    final live = filtered.where((e) => e.isLive()).toList();
    final upcoming = filtered.where((e) => !e.isLive()).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.text_hello_user((user?.name ?? '').split(' ').first),
                    style: TextStyle(fontSize: 14.sp, color: context.palette.hint),
                  ),
                  Text(loc.text_discover, style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 14.h),
                  TextField(
                    onChanged: (v) => ref.read(eventSearchProvider.notifier).state = v,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: loc.text_search_events,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: context.palette.surface,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: context.palette.border)),
                      enabledBorder:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: context.palette.border)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _categoryChips(category)),
          if (live.isNotEmpty) ...[
            _sectionTitle(loc.text_happening_now),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 170.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                  itemCount: live.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (_, i) => EventHeroCard(event: live[i], onTap: () => _open(live[i])),
                ),
              ),
            ),
          ],
          if (upcoming.isNotEmpty) _sectionTitle(loc.text_upcoming),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 60.h),
                child: StatusView(
                  icon: Icons.event_busy,
                  message: events.isEmpty ? loc.text_no_events : loc.text_no_matching_events,
                ),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
            sliver: SliverList.separated(
              itemCount: upcoming.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (_, i) => EventCard(event: upcoming[i], onTap: () => _open(upcoming[i])),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          child: Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: context.palette.heading)),
        ),
      );

  Widget _categoryChips(String selected) {
    final loc = context.loc;
    return SizedBox(
      height: 44.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          for (final c in ['all', ...CategoryStyle.categories])
            Padding(
              padding: EdgeInsetsDirectional.only(end: 8.w),
              child: ChoiceChip(
                label: Text(CategoryStyle.label(loc, c)),
                avatar: c == 'all' ? null : Icon(CategoryStyle.of(c).icon, size: 16.sp),
                selected: selected == c,
                showCheckmark: false,
                selectedColor: primaryColor,
                labelStyle: TextStyle(color: selected == c ? whiteColor : context.palette.body, fontWeight: FontWeight.w500),
                iconTheme: IconThemeData(color: selected == c ? whiteColor : CategoryStyle.of(c).color),
                backgroundColor: context.palette.surface,
                side: BorderSide(color: selected == c ? primaryColor : context.palette.border),
                onSelected: (_) => ref.read(eventCategoryProvider.notifier).state = c,
              ),
            ),
        ],
      ),
    );
  }
}
