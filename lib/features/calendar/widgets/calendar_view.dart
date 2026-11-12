import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/common/spacing.dart';
import '../../../core/common/korea_holidays.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/calendar_provider.dart';
import '../../../core/database/drift_database.dart';
import '../../couple/models/anniversary.dart';
import '../../couple/providers/couple_provider.dart';

/// 캘린더(달력) 위젯
class CalendarView extends ConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // monthEvents만 watch (달력 데이터)
    final monthEventsAsync = ref.watch(monthEventsProvider);

    return monthEventsAsync.when(
      skipLoadingOnReload: true,
      data: (events) {
        final eventsMap = getEventsMap(events);

        return CozyCard(
          margin: const EdgeInsets.all(AppSpacing.md),
          // 선택 날짜 표시는 Consumer로 분리 (이 부분만 selectedDate watch)
          child: Consumer(
            builder: (context, ref, _) {
              final selectedDate = ref.watch(selectedDateProvider);
              final focusedDate = ref.watch(focusedDateProvider);
              final anniversaryDays = _anniversaryDays(ref, focusedDate);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.smMd),
                child: TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focusedDate,
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                holidayPredicate: KoreaHolidays.isHoliday,
                onDaySelected: (selectedDay, focusedDay) {
                  ref.read(selectedDateProvider.notifier).state = selectedDay;
                  ref.read(focusedDateProvider.notifier).state = focusedDay;
                },
                onPageChanged: (focusedDay) {
                  ref.read(focusedDateProvider.notifier).state = focusedDay;
                },
                calendarFormat: CalendarFormat.month,
                daysOfWeekHeight: 32,
                rowHeight: 58,

                eventLoader: (day) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  return eventsMap[normalizedDay] ?? [];
                },
                calendarStyle: CalendarStyle(
                  // 행 높이 고정 (마커 유무와 무관하게 일정)
                  cellMargin: const EdgeInsets.all(6),
                  defaultTextStyle: const TextStyle(color: AppColors.ink),
                  outsideTextStyle: TextStyle(
                    color: AppColors.inkSoft.withValues(alpha: 0.45),
                  ),
                  weekendTextStyle: const TextStyle(color: AppColors.coral),
                  holidayTextStyle: const TextStyle(color: AppColors.coral),
                  todayTextStyle: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: AppColors.roseBg,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: AppTheme.display(24),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.ink,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.ink,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: AppColors.inkSoft,
                    fontSize: 13,
                  ),
                  weekendStyle: TextStyle(
                    color: AppColors.coral,
                    fontSize: 13,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  // 선택한 날짜는 하트 위에 표시한다
                  selectedBuilder: (context, day, focusedDay) {
                    return Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const DoodleHeart(size: 44),
                          Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  markerBuilder: (context, day, eventList) {
                    final isAnniversary = anniversaryDays.contains(
                      DateTime(day.year, day.month, day.day),
                    );
                    if (eventList.isEmpty && !isAnniversary) return null;
                    final events = eventList.cast<Event>();
                    final hasCouple = events.any((e) => e.coupleId != null);
                    final hasPersonal = events.any((e) => e.coupleId == null);

                    return Positioned(
                      bottom: 3,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isAnniversary)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1),
                              child: DoodleHeart(
                                size: 9,
                                color: Color(0xFFE8B84A),
                              ),
                            ),
                          if (hasPersonal)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: const BoxDecoration(
                                color: AppColors.sky,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (hasCouple)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: const BoxDecoration(
                                color: AppColors.coral,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('에러: $error')),
    );
  }

  /// 보이는 달(앞뒤 주 포함)에 있는 기념일 날짜들
  Set<DateTime> _anniversaryDays(WidgetRef ref, DateTime focused) {
    final couple = ref.watch(coupleProvider).valueOrNull;
    if (couple == null || !couple.isConnected) return const {};
    return anniversariesBetween(
      startDate: couple.startDate,
      custom: couple.anniversaries,
      from: DateTime(focused.year, focused.month, 1 - 7),
      to: DateTime(focused.year, focused.month + 1, 7),
    ).map((a) => a.date).toSet();
  }
}
