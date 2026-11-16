import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/router.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../calendar/widgets/day_anniversaries.dart';
import '../models/anniversary.dart';
import '../models/couple.dart';
import '../providers/couple_provider.dart';

/// 기념일 탭: 사귄 날 설정 + 다가오는 기념일(자동 + 직접 등록) + 지난 기념일
class AnniversaryPage extends ConsumerWidget {
  const AnniversaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider).valueOrNull;
    final isConnected = couple != null && couple.isConnected;

    return Scaffold(
      floatingActionButton: isConnected
          ? FloatingActionButton(
              tooltip: '기념일 추가',
              onPressed: () => context.push(AppRoutes.anniversaryNew),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: CozyBackground(
        child: SafeArea(
          bottom: false,
          child: isConnected
              ? _AnniversaryBody(couple: couple)
              : const _NotConnected(),
        ),
      ),
    );
  }
}

class _AnniversaryBody extends ConsumerWidget {
  final Couple couple;
  const _AnniversaryBody({required this.couple});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final upcoming = upcomingAnniversaries(
      startDate: couple.startDate,
      custom: couple.anniversaries,
      today: now,
    );
    final past = pastOneTimeAnniversaries(
      custom: couple.anniversaries,
      today: now,
    );

    return ListView(
      // 맨 아래 항목이 + 버튼에 가리지 않도록 여유를 둔다
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
          child: Text('기념일', style: AppTheme.display(28)),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text(
            '날짜만 넣으면 남은 날은 Coupley가 알아서 세어 줘요.',
            style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
          ),
        ),
        _StartDateCard(couple: couple),
        const SizedBox(height: 20),
        SectionTitle(
          '다가오는 기념일',
          trailing: Text(
            '${upcoming.length}개',
            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
        ),
        if (upcoming.isEmpty)
          CozyCard(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: const Center(
              child: Text(
                '사귄 날을 정하거나 + 버튼으로\n기념일을 추가해 보세요',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkSoft, height: 1.5),
              ),
            ),
          )
        else
          for (final item in upcoming)
            AnniversaryTile(item: item, daysLeft: daysUntil(now, item.date)),
        if (past.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionTitle('지난 기념일'),
          for (final item in past)
            AnniversaryTile(item: item, daysLeft: daysUntil(now, item.date)),
        ],
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(
            '100일 단위 기념일과 주년은 사귄 날 기준으로 자동 계산돼요. '
            '직접 추가한 기념일은 눌러서 고치거나 지울 수 있어요.',
            style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
        ),
      ],
    );
  }
}

/// 사귄 날과 함께한 날수. 누르면 사귄 날을 고른다.
class _StartDateCard extends ConsumerWidget {
  final Couple couple;
  const _StartDateCard({required this.couple});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = couple.startDate;
    final since = couple.togetherSince;

    return CozyCard(
      color: AppColors.pinkBg,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _pickStartDate(context, ref),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '우리가 사귄 날',
                      style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      start != null
                          ? DateFormat('yyyy년 M월 d일', 'ko_KR').format(start)
                          : '아직 정하지 않았어요',
                      style: AppTheme.display(start != null ? 26 : 22),
                    ),
                    if (since != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        start != null
                            ? '오늘이 ${daysTogether(since, DateTime.now())}일째'
                            : '지금은 커플 연결한 날부터 세고 있어요',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.coralDeep,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.edit_calendar_outlined,
                color: AppColors.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: couple.togetherSince ?? now,
      firstDate: DateTime(1970),
      lastDate: now,
      helpText: '사귄 날 선택',
    );
    if (picked == null) return;

    try {
      await ref.read(coupleServiceProvider).updateStartDate(couple.id, picked);
    } catch (e) {
      if (context.mounted) showSaveError(context, e);
    }
  }
}

/// 기념일 한 줄: D-N 동그라미, 이름, 날짜·반복, 남은 날, (직접 등록이면) 삭제
class AnniversaryTile extends ConsumerWidget {
  final AnniversaryOccurrence item;
  final int daysLeft;

  const AnniversaryTile({
    super.key,
    required this.item,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = item.source;
    final repeat = item.isAuto
        ? '자동'
        : source!.yearly
        ? '매년 반복'
        : '한 번만';

    return CozyCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: source == null
            ? null
            : () => context.push(AppRoutes.anniversaryEdit, extra: source),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              DdayBadge(daysLeft: daysLeft, color: item.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${DateFormat('yy.M.d', 'ko_KR').format(item.date)}'
                      ' · $repeat',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                daysLeftLabel(daysLeft),
                style: TextStyle(
                  fontSize: 12,
                  color: daysLeft == 0
                      ? AppColors.coralDeep
                      : AppColors.inkSoft,
                  fontWeight: daysLeft == 0 ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              if (source != null)
                IconButton(
                  tooltip: '${source.title} 삭제',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.inkSoft,
                  ),
                  onPressed: () =>
                      confirmDeleteAnniversary(context, ref, source),
                )
              else
                const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// D-18, D+813 같은 글자를 담은 동그라미
class DdayBadge extends StatelessWidget {
  final int daysLeft;
  final AnniversaryColor color;
  final double size;

  const DdayBadge({
    super.key,
    required this.daysLeft,
    required this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final label = dDayLabel(daysLeft);
    final isToday = daysLeft == 0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isToday ? anniversaryColor(color) : anniversaryBgColor(color),
        shape: BoxShape.circle,
        border: Border.all(
          color: anniversaryColor(color).withValues(alpha: 0.3),
        ),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            label,
            style: AppTheme.display(
              16,
              color: isToday ? Colors.white : anniversaryColor(color),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotConnected extends StatelessWidget {
  const _NotConnected();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CharacterSlot(
              height: 120,
              width: 180,
              asset: 'assets/images/character_anniversary_empty.png',
            ),
            const SizedBox(height: 16),
            Text(
              '짝꿍과 연결하면\n기념일을 함께 챙길 수 있어요',
              textAlign: TextAlign.center,
              style: AppTheme.display(22),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.coupleConnect),
              child: const Text('커플 연결하기'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 기념일 삭제 확인 후 삭제. 지웠으면 true.
Future<bool> confirmDeleteAnniversary(
  BuildContext context,
  WidgetRef ref,
  Anniversary anniversary,
) async {
  final couple = ref.read(coupleProvider).valueOrNull;
  if (couple == null) return false;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('기념일 삭제'),
      content: Text('"${anniversary.title}"을(를) 지울까요?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('삭제', style: TextStyle(color: AppColors.coralDeep)),
        ),
      ],
    ),
  );
  if (ok != true) return false;

  try {
    await ref
        .read(coupleServiceProvider)
        .deleteAnniversary(couple.id, anniversary.id);
    return true;
  } catch (e) {
    if (context.mounted) showSaveError(context, e);
    return false;
  }
}

void showSaveError(BuildContext context, Object e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '저장하지 못했어요. 인터넷 연결을 확인해 주세요. '
        '(${e.toString().replaceFirst('Exception: ', '')})',
      ),
    ),
  );
}
