import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/router.dart';
import '../../../core/common/korea_holidays.dart';
import '../../../core/database/drift_database.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../couple/widgets/dday_card.dart';
import '../providers/calendar_provider.dart';
import 'day_anniversaries.dart';
import 'event_card.dart';

/// 오늘 일정 탭 (앱의 첫 화면)
///
/// '우리 일정' 머리글, 캐릭터, 함께한 날 D+N 카드, 주간 달력,
/// 고른 날의 일정과 이번 주 남은 일정을 차례로 보여준다.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(weekSelectedDateProvider);
    final weekEvents = ref.watch(weekEventsProvider);
    // 선택한 날 일정이 없으면 빈 카드에 '일정 추가' 버튼이 있으니 FAB는 숨긴다
    final hasDayEvents = (weekEvents.valueOrNull ?? const <Event>[]).any(
      (e) =>
          e.date.year == selected.year &&
          e.date.month == selected.month &&
          e.date.day == selected.day,
    );

    return Scaffold(
      body: CozyBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              const _Header(),
              const CharacterSlot(
                height: 120,
                asset: 'assets/images/banner_today.png',
              ),
              const SizedBox(height: 12),
              const DdayCard(),
              const SizedBox(height: 12),
              _WeekStrip(events: weekEvents.valueOrNull ?? const []),
              const SizedBox(height: 20),
              ...weekEvents.when(
                skipLoadingOnReload: true,
                data: (events) => _lists(context, selected, events),
                loading: () => const [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (e, _) => [Text('일정을 불러오지 못했어요: $e')],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: hasDayEvents
          ? FloatingActionButton(
              tooltip: '일정 추가',
              onPressed: () =>
                  context.push(AppRoutes.eventNew, extra: selected),
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  List<Widget> _lists(
    BuildContext context,
    DateTime selected,
    List<Event> events,
  ) {
    final sorted = [...events]..sort(compareEvents);
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final dayEvents = sorted.where((e) => sameDay(e.date, selected)).toList();
    final laterEvents = sorted.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return d.isAfter(selected);
    }).toList();

    final isToday = sameDay(selected, DateTime.now());
    final dayTitle = isToday
        ? '오늘 일정'
        : '${DateFormat('M월 d일 (E)', 'ko_KR').format(selected)} 일정';

    return [
      SectionTitle(dayTitle),
      DayAnniversaries(date: selected),
      if (dayEvents.isEmpty)
        _EmptyDay(date: selected)
      else
        for (final e in dayEvents) EventCard(event: e),
      if (laterEvents.isNotEmpty) ...[
        const SizedBox(height: 16),
        const SectionTitle('이번 주 남은 일정'),
        for (final e in laterEvents) EventCard(event: e, showDate: true),
      ],
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.event_note_rounded, color: AppColors.coral),
          const SizedBox(width: 6),
          Expanded(child: Text('우리 일정', style: AppTheme.display(28))),
          IconButton(
            tooltip: '설정',
            icon: const Icon(Icons.settings_outlined, color: AppColors.ink),
            onPressed: () => context.go(AppTabs.settings),
          ),
        ],
      ),
    );
  }
}

/// 일~토 한 주를 보여주는 달력. 날짜를 누르면 그날 일정을 아래에 보여준다.
class _WeekStrip extends ConsumerWidget {
  final List<Event> events;

  const _WeekStrip({required this.events});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(weekSelectedDateProvider);
    final start = weekStartOf(selected);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = [for (var i = 0; i < 7; i++) start.add(Duration(days: i))];

    void moveWeek(int delta) {
      ref.read(weekSelectedDateProvider.notifier).state = selected.add(
        Duration(days: 7 * delta),
      );
    }

    return CozyCard(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: '지난주',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => moveWeek(-1),
              ),
              Expanded(
                child: GestureDetector(
                  // 가운데 제목을 누르면 오늘로 돌아온다
                  onTap: () =>
                      ref.read(weekSelectedDateProvider.notifier).state = today,
                  child: Text(
                    DateFormat('yyyy년 M월', 'ko_KR').format(selected),
                    textAlign: TextAlign.center,
                    style: AppTheme.display(22),
                  ),
                ),
              ),
              IconButton(
                tooltip: '다음 주',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => moveWeek(1),
              ),
            ],
          ),
          Row(
            children: [
              for (final d in days)
                Expanded(
                  child: _DayCell(
                    day: d,
                    selected: d == selected,
                    isToday: d == today,
                    events: events
                        .where(
                          (e) =>
                              e.date.year == d.year &&
                              e.date.month == d.month &&
                              e.date.day == d.day,
                        )
                        .toList(),
                    onTap: () =>
                        ref.read(weekSelectedDateProvider.notifier).state = d,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final bool isToday;
  final List<Event> events;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.events,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRed =
        day.weekday == DateTime.sunday ||
        day.weekday == DateTime.saturday ||
        KoreaHolidays.isHoliday(day);
    final hasPersonal = events.any((e) => e.coupleId == null);
    final hasCouple = events.any((e) => e.coupleId != null);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Text(
            DateFormat('E', 'ko_KR').format(day),
            style: TextStyle(
              fontSize: 12,
              color: isRed ? AppColors.coralDeep : AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 40,
            height: 38,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (selected) const DoodleHeart(size: 40),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected || isToday
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: selected
                        ? Colors.white
                        : isRed
                        ? AppColors.coralDeep
                        : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 14,
            child: isToday && !selected
                ? const Text(
                    '오늘',
                    style: TextStyle(fontSize: 10, color: AppColors.coralDeep),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasPersonal) const _Dot(AppColors.mint),
                      if (hasCouple) const _Dot(AppColors.coral),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// 고른 날에 일정이 없을 때
class _EmptyDay extends StatelessWidget {
  final DateTime date;
  const _EmptyDay({required this.date});

  @override
  Widget build(BuildContext context) {
    return CozyCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          const CharacterSlot(
            height: 90,
            width: 140,
            asset: 'assets/images/character_sleeping.png',
          ),
          const SizedBox(height: 10),
          Text('아직 등록된 일정이 없어요', style: AppTheme.display(20)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.eventNew, extra: date),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('일정 추가'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.line, width: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
