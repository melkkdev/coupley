import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/router.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/drift_database.dart';
import '../../auth/providers/auth_provider.dart';
import '../../couple/providers/couple_provider.dart';

/// 일정 한 줄. 누르면 수정 페이지로 간다 (삭제도 수정 페이지에서).
class EventCard extends ConsumerWidget {
  final Event event;

  /// 날짜를 함께 보여줄지 (이번 주 목록처럼 여러 날이 섞일 때)
  final bool showDate;

  const EventCard({super.key, required this.event, this.showDate = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCouple = event.coupleId != null;
    final author = isCouple ? _authorName(ref) : null;

    final meta = [
      if (showDate) DateFormat('M/d (E)', 'ko_KR').format(event.date),
      timeRangeLabel(event),
      ?author,
    ].join(' · ');

    return CozyCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push(AppRoutes.eventEdit, extra: event),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
          child: Row(
            children: [
              EventBadge(isCouple: isCouple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    if (event.description case final d? when d.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          d,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }

  /// 커플 일정 작성자: '나 추가' 또는 '준호 추가'
  String? _authorName(WidgetRef ref) {
    final createdBy = event.createdBy;
    if (createdBy == null) return null;
    final myUserId = ref.watch(authProvider.select((s) => s.userId));
    if (createdBy == myUserId) return '나 추가';
    final names = ref.watch(coupleMemberNamesProvider).valueOrNull;
    if (names == null) return null;
    return '${names[createdBy] ?? '상대방'} 추가';
  }
}

/// '종일' 또는 '오후 7:00 - 오후 9:00'
String timeRangeLabel(Event event) {
  if (event.isAllDay || event.startTime == null) return '종일';
  final f = DateFormat('a h:mm', 'ko_KR');
  final start = f.format(event.startTime!);
  return event.endTime == null ? start : '$start - ${f.format(event.endTime!)}';
}

/// 개인(민트)·커플(코랄) 일정 동그라미 표시
class EventBadge extends StatelessWidget {
  final bool isCouple;
  final double size;

  const EventBadge({super.key, required this.isCouple, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isCouple ? AppColors.roseBg : AppColors.mintBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: isCouple
          ? DoodleHeart(size: size * 0.45)
          : Icon(
              Icons.person_outline_rounded,
              size: size * 0.5,
              color: AppColors.mint,
            ),
    );
  }
}
