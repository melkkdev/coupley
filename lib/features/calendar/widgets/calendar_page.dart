import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/router.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/calendar_provider.dart';
import 'calendar_view.dart';
import 'day_anniversaries.dart';
import 'event_card.dart';

/// 달력 탭: 한 달 달력 + 고른 날의 일정
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dayEvents = ref.watch(selectedDayEventsProvider);

    return Scaffold(
      body: CozyBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
                child: Text('달력', style: AppTheme.display(28)),
              ),
              const CalendarView(),
              const SizedBox(height: 20),
              SectionTitle(
                '${DateFormat('M월 d일 (E)', 'ko_KR').format(selectedDate)} 일정',
              ),
              DayAnniversaries(date: selectedDate),
              ...dayEvents.when(
                skipLoadingOnReload: true,
                data: (events) {
                  if (events.isEmpty) {
                    return [
                      CozyCard(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: const Center(
                          child: Text(
                            '이날은 일정이 없어요',
                            style: TextStyle(color: AppColors.inkSoft),
                          ),
                        ),
                      ),
                    ];
                  }
                  final sorted = [...events]..sort(compareEvents);
                  return [for (final e in sorted) EventCard(event: e)];
                },
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
      floatingActionButton: FloatingActionButton(
        tooltip: '일정 추가',
        onPressed: () => context.push(AppRoutes.eventNew, extra: selectedDate),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
