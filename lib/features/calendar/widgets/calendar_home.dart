import 'package:coupley/features/calendar/widgets/calendar_view.dart';
import 'package:coupley/features/calendar/widgets/greeting_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/common/spacing.dart';
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple.shade50, Colors.blue.shade50],
              ),
            ),
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
                              icon: const Icon(Icons.settings),
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
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                AppSpacing.gapMd,
                                selectedDayEventsAsync.when(
                                  data: (events) {
                                    if (events.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.xl,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.event_busy,
                                                size: 48,
                                                color: Colors.grey.shade400,
                                              ),
                                              AppSpacing.gapSm,
                                              Text(
                                                '이벤트가 없습니다',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
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

                          AppSpacing.gapXl,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const DebugFloatingButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context, ref, selectedDate);
        },
        backgroundColor: Colors.purple,
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
              leading: const Icon(Icons.favorite, color: Colors.pink),
              title: const Text('커플 연결'),
              onTap: () {
                Navigator.pop(context);
                context.push('/couple-connect');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
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
