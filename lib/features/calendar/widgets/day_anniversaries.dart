import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../couple/models/anniversary.dart';
import '../../couple/providers/couple_provider.dart';

/// 고른 날짜에 돌아오는 기념일 (사귄 날 기준 자동 기념일 + 직접 추가한 기념일).
/// 누르면 기념일 탭으로 간다.
class DayAnniversaries extends ConsumerWidget {
  final DateTime date;
  const DayAnniversaries({super.key, required this.date});

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
      padding: const EdgeInsets.only(bottom: 10),
      child: CozyCard(
        color: AppColors.pinkBg,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.go(AppTabs.anniversaries),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        DoodleHeart(
                          size: 16,
                          color: anniversaryColor(item.color),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.title, style: AppTheme.display(20)),
                        ),
                        const Text(
                          '기념일',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.coralDeep,
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

/// 기념일 카드 색 → 진한 색
Color anniversaryColor(AnniversaryColor c) => switch (c) {
  AnniversaryColor.coral => AppColors.coral,
  AnniversaryColor.pink => AppColors.pink,
  AnniversaryColor.mint => AppColors.mint,
};

/// 기념일 카드 색 → 연한 배경색
Color anniversaryBgColor(AnniversaryColor c) => switch (c) {
  AnniversaryColor.coral => AppColors.roseBg,
  AnniversaryColor.pink => AppColors.pinkBg,
  AnniversaryColor.mint => AppColors.mintBg,
};
