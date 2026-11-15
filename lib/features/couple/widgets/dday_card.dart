import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../models/anniversary.dart';
import '../providers/couple_provider.dart';

/// 오늘 일정 탭 위쪽의 '함께한 날 D+N' 카드.
/// 연결되어 있으면 함께한 날수와 다음 기념일, 아니면 커플 연결 안내를 보여준다.
/// 누르면 기념일 탭(연결 전이면 커플 연결 화면)으로 간다.
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

    final String caption;
    if (!isTogether) {
      caption = '짝꿍과 연결하면 함께한 날을 세어 줘요 ›';
    } else if (couple.startDate == null) {
      caption = '사귄 날을 알려 주세요 ›';
    } else if (next != null) {
      caption = '${next.title} · ${dDayLabel(daysUntil(now, next.date))}';
    } else {
      caption = '기념일 보기 ›';
    }

    return Material(
      color: AppColors.pinkBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: AppColors.pink.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => isTogether
            ? context.go(AppTabs.anniversaries)
            : context.push(AppRoutes.coupleConnect),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            children: [
              Text(
                isTogether ? '함께한 날' : '아직 혼자예요',
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const DoodleHeart(size: 14, color: AppColors.pink),
                  const SizedBox(width: 8),
                  Text(
                    isTogether ? 'D+${daysTogether(since, now)}' : '짝꿍 초대하기',
                    style: AppTheme.display(
                      isTogether ? 34 : 26,
                      color: AppColors.coralDeep,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const DoodleHeart(size: 14, color: AppColors.pink),
                ],
              ),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
