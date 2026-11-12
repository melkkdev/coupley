import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/drift_database.dart';
import '../providers/calendar_provider.dart';
import 'add_event_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../../couple/providers/couple_provider.dart';

/// 이벤트 카드 (개별 이벤트 표시)
/// 탭하면 수정, 삭제 버튼으로 삭제
class EventCard extends ConsumerWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCouple = event.coupleId != null;

    return CozyCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.smMd),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        // 탭 → 수정 다이얼로그
        onTap: () {
          showDialog(
            context: context,
            builder: (context) =>
                AddEventDialog(initialDate: event.date, editEvent: event),
          );
        },
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isCouple ? AppColors.roseBg : AppColors.skyBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isCouple
              ? const DoodleHeart(size: 20)
              : const Icon(
                  Icons.face_outlined,
                  size: 22,
                  color: AppColors.sky,
                ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: _buildSubtitle(context, ref, isCouple),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!event.isAllDay && event.startTime != null)
              Text(
                DateFormat('HH:mm').format(event.startTime!),
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
              ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.inkSoft,
              ),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.coral),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(calendarNotifierProvider.notifier).deleteEvent(event.id);
    }
  }

  /// 설명 + 작성자 표시
  Widget? _buildSubtitle(BuildContext context, WidgetRef ref, bool isCouple) {
    final description = event.description;

    // 커플 일정이면 작성자 표시
    Widget? authorWidget;
    if (isCouple && event.createdBy != null) {
      final myUserId = ref.watch(authProvider.select((s) => s.userId));
      final namesAsync = ref.watch(coupleMemberNamesProvider);

      // 🔍 디버그 로그
      // print('=== 작성자 디버그 ===');
      // print('createdBy: ${event.createdBy}');
      // print('myUserId: $myUserId');
      // print('names data: ${namesAsync.valueOrNull}');
      // print('names isLoading: ${namesAsync.isLoading}');
      // print('names hasError: ${namesAsync.hasError}');
      if (namesAsync.hasError) print('error: ${namesAsync.error}');

      final authorName = namesAsync.maybeWhen(
        data: (names) {
          if (event.createdBy == myUserId) return '나';
          return names[event.createdBy] ?? '상대방';
        },
        orElse: () => '',
      );
      if (authorName.isNotEmpty) {
        authorWidget = Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              const Icon(Icons.person, size: 12, color: AppColors.inkSoft),
              const SizedBox(width: 2),
              Text(
                '$authorName 추가',
                style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
              ),
            ],
          ),
        );
      }
    }

    // 설명도 없고 작성자도 없으면 null
    if (description == null && authorWidget == null) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description != null)
          Text(
            description,
            style: const TextStyle(color: AppColors.inkSoft),
          ),
        if (authorWidget != null) authorWidget,
      ],
    );
  }
}
