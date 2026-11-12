import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../models/anniversary.dart';
import '../providers/couple_provider.dart';

/// 함께한 날수. 연결한 날을 1일째로 센다. 시각은 무시하고 날짜만 비교한다.
int daysTogether(DateTime connectedAt, DateTime now) {
  final start = DateTime.utc(
    connectedAt.year,
    connectedAt.month,
    connectedAt.day,
  );
  final today = DateTime.utc(now.year, now.month, now.day);
  return today.difference(start).inDays + 1;
}

/// 홈 상단 카드. 연결되어 있으면 함께한 날수와 다음 기념일, 아니면 커플 연결 안내를 보여준다.
class DdayCard extends ConsumerWidget {
  const DdayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider).valueOrNull;
    final since = couple?.togetherSince;
    final isTogether = couple != null && couple.isConnected && since != null;

    final now = DateTime.now();
    final next = isTogether
        ? upcomingAnniversaries(
            startDate: couple.startDate,
            custom: couple.anniversaries,
            today: now,
          ).firstOrNull
        : null;

    return CozyCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push(
          isTogether ? '/anniversaries' : '/couple-connect',
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTogether ? '우리가 함께한 지' : '아직 혼자예요',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isTogether
                        ? 'D+${daysTogether(since, now)}'
                        : '짝꿍 초대하기',
                    style: AppTheme.display(isTogether ? 38 : 28),
                  ),
                  if (isTogether) ...[
                    const SizedBox(height: 4),
                    Text(
                      couple.startDate == null
                          ? '사귄 날을 알려 주세요 ›'
                          : next != null
                          ? '${next.title} · ${dDayLabel(daysUntil(now, next.date))}'
                          : '기념일 보기 ›',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.coral,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
            CoupleDoodle(width: 128, together: isTogether),
          ],
        ),
      ),
    );
  }
}
