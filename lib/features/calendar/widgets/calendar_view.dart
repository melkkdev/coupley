import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/common/spacing.dart';
import '../providers/calendar_provider.dart';
import '../../../core/database/drift_database.dart';

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

        return Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // 선택 날짜 표시는 Consumer로 분리 (이 부분만 selectedDate watch)
          child: Consumer(
            builder: (context, ref, _) {
              final selectedDate = ref.watch(selectedDateProvider);
              final focusedDate = ref.watch(focusedDateProvider);

              return TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focusedDate,
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  ref.read(selectedDateProvider.notifier).state = selectedDay;
                  ref.read(focusedDateProvider.notifier).state = focusedDay;
                },
                onPageChanged: (focusedDay) {
                  ref.read(focusedDateProvider.notifier).state = focusedDay;
                },
                calendarFormat: CalendarFormat.month,
                rowHeight: 52, // 행 높이 고정 (마커 공간 포함)

                eventLoader: (day) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  return eventsMap[normalizedDay] ?? [];
                },
                calendarStyle: CalendarStyle(
                  // 행 높이 고정 (마커 유무와 무관하게 일정)
                  cellMargin: const EdgeInsets.all(6),
                  todayDecoration: BoxDecoration(
                    color: Colors.purple.shade200,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, eventList) {
                    if (eventList.isEmpty) return null;
                    final events = eventList.cast<Event>();
                    final hasCouple = events.any((e) => e.coupleId != null);
                    final hasPersonal = events.any((e) => e.coupleId == null);

                    return Positioned(
                      bottom: 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasPersonal)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (hasCouple)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: const BoxDecoration(
                                color: Colors.pink,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
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
}
