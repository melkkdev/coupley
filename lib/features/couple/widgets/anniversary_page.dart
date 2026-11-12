import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../models/anniversary.dart';
import '../models/couple.dart';
import '../providers/couple_provider.dart';
import 'dday_card.dart';

/// 기념일 화면: 사귄 날 설정 + 다가오는 기념일 목록 + 직접 추가한 기념일 관리
class AnniversaryPage extends ConsumerWidget {
  const AnniversaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider).valueOrNull;
    final isConnected = couple != null && couple.isConnected;

    return Scaffold(
      appBar: AppBar(title: const Text('기념일')),
      floatingActionButton: isConnected
          ? FloatingActionButton(
              onPressed: () => _openEditor(context, ref, couple),
              child: const Icon(Icons.add),
            )
          : null,
      body: CozyBackground(
        child: isConnected
            ? _AnniversaryBody(couple: couple)
            : _NotConnected(onConnect: () => context.push('/couple-connect')),
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

    return ListView(
      // 맨 아래 항목이 + 버튼에 가리지 않도록 여유를 둔다
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        _StartDateCard(couple: couple),
        AppSpacing.gapLg,
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('다가오는 기념일', style: AppTheme.display(22)),
        ),
        if (upcoming.isEmpty)
          CozyCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: const Center(
              child: Text(
                '사귄 날을 정하거나 + 버튼으로\n기념일을 추가해 보세요',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkSoft, height: 1.5),
              ),
            ),
          )
        else
          CozyCard(
            child: Column(
              children: [
                for (var i = 0; i < upcoming.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 64),
                  _AnniversaryTile(
                    item: upcoming[i],
                    daysLeft: daysUntil(now, upcoming[i].date),
                    onTap: upcoming[i].source == null
                        ? null
                        : () => _openEditor(
                            context,
                            ref,
                            couple,
                            editing: upcoming[i].source,
                          ),
                  ),
                ],
              ],
            ),
          ),
        AppSpacing.gapSm,
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
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

/// 사귄 날과 함께한 날수
class _StartDateCard extends ConsumerWidget {
  final Couple couple;
  const _StartDateCard({required this.couple});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = couple.startDate;
    final since = couple.togetherSince;

    return CozyCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _pickStartDate(context, ref),
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
                    const SizedBox(height: 4),
                    Text(
                      start != null
                          ? '오늘이 ${daysTogether(since, DateTime.now())}일째'
                          : '지금은 커플 연결한 날부터 세고 있어요',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_outlined, color: AppColors.inkSoft),
            const SizedBox(width: 8),
          ],
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
      await ref
          .read(coupleServiceProvider)
          .updateStartDate(couple.id, picked);
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }
}

class _AnniversaryTile extends StatelessWidget {
  final AnniversaryOccurrence item;
  final int daysLeft;
  final VoidCallback? onTap;

  const _AnniversaryTile({
    required this.item,
    required this.daysLeft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = daysLeft == 0;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: AnniversaryBadge(icon: item.icon),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      subtitle: Text(
        DateFormat('yyyy.M.d (E)', 'ko_KR').format(item.date) +
            (item.isAuto ? ' · 자동' : ''),
        style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isToday ? AppColors.coral : AppColors.roseBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dDayLabel(daysLeft),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isToday ? Colors.white : AppColors.coral,
          ),
        ),
      ),
    );
  }
}

/// 기념일 종류 아이콘을 담은 동그란 배지
class AnniversaryBadge extends StatelessWidget {
  final AnniversaryIcon icon;
  final double size;
  final Color background;

  const AnniversaryBadge({
    super.key,
    required this.icon,
    this.size = 40,
    this.background = AppColors.roseBg,
  });

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.5;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: switch (icon) {
        AnniversaryIcon.heart => DoodleHeart(size: inner),
        AnniversaryIcon.cake => Icon(
          Icons.cake_outlined,
          size: inner,
          color: AppColors.coral,
        ),
        AnniversaryIcon.star => Icon(
          Icons.star_rounded,
          size: inner,
          color: const Color(0xFFE8B84A),
        ),
      },
    );
  }
}

class _NotConnected extends StatelessWidget {
  final VoidCallback onConnect;
  const _NotConnected({required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CoupleDoodle(width: 160, together: false),
            AppSpacing.gapMd,
            Text('짝꿍과 연결하면\n기념일을 함께 챙길 수 있어요',
                textAlign: TextAlign.center, style: AppTheme.display(22)),
            AppSpacing.gapLg,
            ElevatedButton(onPressed: onConnect, child: const Text('커플 연결하기')),
          ],
        ),
      ),
    );
  }
}

Future<void> _openEditor(
  BuildContext context,
  WidgetRef ref,
  Couple couple, {
  Anniversary? editing,
}) {
  return showDialog(
    context: context,
    builder: (_) => _AnniversaryEditor(couple: couple, editing: editing),
  );
}

void _showError(BuildContext context, Object e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '저장하지 못했어요. 인터넷 연결을 확인해 주세요. '
        '(${e.toString().replaceFirst('Exception: ', '')})',
      ),
    ),
  );
}

/// 기념일 추가/수정 다이얼로그
class _AnniversaryEditor extends ConsumerStatefulWidget {
  final Couple couple;
  final Anniversary? editing;

  const _AnniversaryEditor({required this.couple, this.editing});

  @override
  ConsumerState<_AnniversaryEditor> createState() => _AnniversaryEditorState();
}

class _AnniversaryEditorState extends ConsumerState<_AnniversaryEditor> {
  late final TextEditingController _title;
  late DateTime _date;
  late bool _yearly;
  late AnniversaryIcon _icon;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _title = TextEditingController(text: e?.title ?? '');
    _date = e?.date ?? DateTime.now();
    _yearly = e?.yearly ?? true;
    _icon = e?.icon ?? AnniversaryIcon.heart;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editing != null;

    return AlertDialog(
      title: Text(isEdit ? '기념일 수정' : '기념일 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              maxLength: 20,
              autofocus: !isEdit,
              decoration: const InputDecoration(
                hintText: '예: 준호 생일, 첫 여행',
                counterText: '',
              ),
            ),
            AppSpacing.gapMd,
            Row(
              children: [
                for (final icon in AnniversaryIcon.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _icon = icon),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _icon == icon
                                ? AppColors.coral
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: AnniversaryBadge(icon: icon, size: 40),
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.gapMd,
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined, size: 20),
              label: Text(
                DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(_date),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.line, width: 1.5),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            AppSpacing.gapSm,
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('매년 반복'),
              value: _yearly,
              onChanged: (v) => setState(() => _yearly = v),
            ),
          ],
        ),
      ),
      actions: [
        if (isEdit)
          TextButton(
            onPressed: _saving ? null : _confirmDelete,
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('삭제'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: Text(isEdit ? '저장' : '추가'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('기념일 이름을 입력해 주세요')));
      return;
    }

    final service = ref.read(coupleServiceProvider);
    final anniversary = Anniversary(
      id: widget.editing?.id ?? service.newAnniversaryId(),
      title: title,
      date: _date,
      yearly: _yearly,
      icon: _icon,
    );

    setState(() => _saving = true);
    try {
      await service.saveAnniversary(widget.couple.id, anniversary);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _showError(context, e);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기념일 삭제'),
        content: Text('"${widget.editing!.title}"을(를) 지울까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(coupleServiceProvider)
          .deleteAnniversary(widget.couple.id, widget.editing!.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _showError(context, e);
      }
    }
  }
}
