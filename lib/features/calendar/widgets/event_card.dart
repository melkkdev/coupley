import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/common/spacing.dart';
import '../../../core/database/drift_database.dart';
import '../providers/calendar_provider.dart';
import 'add_event_dialog.dart';

/// 이벤트 카드 (개별 이벤트 표시)
/// 탭하면 수정, 삭제 버튼으로 삭제
class EventCard extends ConsumerWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(int.parse(event.color.substring(1), radix: 16));
    final isCouple = event.coupleId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        // 탭 → 수정 다이얼로그
        onTap: () {
          showDialog(
            context: context,
            builder: (context) =>
                AddEventDialog(initialDate: event.date, editEvent: event),
          );
        },
        leading: Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            color: isCouple ? Colors.pink : Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Row(
          children: [
            // 개인/커플 구분 뱃지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isCouple ? Colors.pink.shade100 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isCouple ? '커플' : '개인',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isCouple ? Colors.pink.shade700 : Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                event.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        subtitle: event.description != null ? Text(event.description!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!event.isAllDay && event.startTime != null)
              Text(
                DateFormat('HH:mm').format(event.startTime!),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
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
        title: const Text('이벤트 삭제'),
        content: const Text('이 이벤트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(calendarNotifierProvider.notifier).deleteEvent(event.id);
    }
  }
}
