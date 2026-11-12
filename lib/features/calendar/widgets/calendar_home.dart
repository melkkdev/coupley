import 'package:coupley/features/calendar/widgets/calendar_view.dart';
import 'package:coupley/features/calendar/widgets/greeting_header.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../couple/widgets/dday_card.dart';
import '../../couple/widgets/anniversary_page.dart';
import '../../couple/models/anniversary.dart';
import '../../couple/providers/couple_provider.dart';
import '../../../core/debug/debug_panel.dart';
import '../../../core/services/realtime_sync_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'add_event_dialog.dart';
import '../providers/calendar_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/user_provider.dart';

import 'event_card.dart';

/// 캘린더 홈 화면
class CalendarHome extends ConsumerWidget {
  const CalendarHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 실시간 동기화 리스너 활성화 (커플 + 개인)
    ref.watch(realtimeCoupleSyncProvider);
    ref.watch(realtimePersonalSyncProvider);

    final selectedDate = ref.watch(selectedDateProvider);
    final selectedDayEventsAsync = ref.watch(selectedDayEventsProvider);

    return Scaffold(
      body: Stack(
        children: [
          CozyBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // 상단 앱바
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GreetingHeader(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.settings_outlined, color: AppColors.ink),
                              onPressed: () {
                                _showSettingsDialog(context, ref);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const DdayCard(),

                          // 캘린더
                          const CalendarView(),

                          // 선택된 날짜의 이벤트 목록
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat(
                                    'yyyy년 M월 d일',
                                  ).format(selectedDate),
                                  style: AppTheme.display(24),
                                ),
                                AppSpacing.gapMd,
                                _DayAnniversaries(date: selectedDate),
                                selectedDayEventsAsync.when(
                                  data: (events) {
                                    if (events.isEmpty) {
                                      return CozyCard(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.lg,
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              const CoupleDoodle(width: 110),
                                              AppSpacing.gapSm,
                                              Text(
                                                '아직 일정이 없어요',
                                                style: AppTheme.display(20),
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                '+ 버튼으로 오늘을 채워 보세요',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.inkSoft,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    return Column(
                                      children: events.map((event) {
                                        return EventCard(event: event);
                                      }).toList(),
                                    );
                                  },
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (error, stack) => Text('에러: $error'),
                                ),
                              ],
                            ),
                          ),

                          // + 버튼과 디버그 배지에 마지막 카드가 가리지 않도록 여백을 둔다
                          const SizedBox(height: 96),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (kDebugMode) const DebugFloatingButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context, ref, selectedDate);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, WidgetRef ref, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(initialDate: date),
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const DoodleHeart(size: 22),
              title: const Text('커플 연결'),
              onTap: () {
                Navigator.pop(context);
                context.push('/couple-connect');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.inkSoft),
              title: const Text('로그아웃'),
              onTap: () {
                ref.read(authProvider.notifier).signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: controller,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: '새 닉네임',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(
                  dialogContext,
                ).showSnackBar(const SnackBar(content: Text('닉네임을 입력해주세요')));
                return;
              }

              final authState = ref.read(authProvider);
              if (authState.userId == null) return;

              try {
                // 1. Firebase Auth displayName 업데이트
                await ref
                    .read(authProvider.notifier)
                    .updateDisplayName(newName);

                // 2. users 컬렉션 업데이트
                await ref
                    .read(userServiceProvider)
                    .updateUserName(authState.userId!, newName);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('닉네임이 변경되었습니다')));
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text('변경 실패: $e')));
                }
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }
}

/// 선택한 날짜에 돌아오는 기념일 (사귄 날 기준 자동 기념일 + 직접 추가한 기념일)
class _DayAnniversaries extends ConsumerWidget {
  final DateTime date;
  const _DayAnniversaries({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider).valueOrNull;
    if (couple == null || !couple.isConnected) return const SizedBox.shrink();

    final items = anniversariesBetween(
      startDate: couple.startDate,
      custom: couple.anniversaries,
      from: date,
      to: date,
    );
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: CozyCard(
        color: AppColors.roseBg,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/anniversaries'),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smMd,
            ),
            child: Column(
              children: [
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        AnniversaryBadge(
                          icon: item.icon,
                          size: 34,
                          background: Colors.white,
                        ),
                        AppSpacing.gapSm,
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTheme.display(22),
                          ),
                        ),
                        const Text(
                          '기념일',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
