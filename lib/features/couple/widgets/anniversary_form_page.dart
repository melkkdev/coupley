import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/design/cozy/form_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../calendar/widgets/day_anniversaries.dart';
import '../models/anniversary.dart';
import '../providers/couple_provider.dart';
import 'anniversary_page.dart';

/// 기념일 추가·수정 페이지 (아래에서 올라오는 전체 화면)
class AnniversaryFormPage extends ConsumerStatefulWidget {
  final Anniversary? editing;

  const AnniversaryFormPage({super.key, this.editing});

  @override
  ConsumerState<AnniversaryFormPage> createState() =>
      _AnniversaryFormPageState();
}

class _AnniversaryFormPageState extends ConsumerState<AnniversaryFormPage> {
  static const _maxMemo = 80;

  late final TextEditingController _title;
  late final TextEditingController _memo;
  late DateTime _date;
  late bool _yearly;
  late AnniversaryColor _color;
  bool _dirty = false;
  bool _saving = false;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _title = TextEditingController(text: e?.title ?? '');
    _memo = TextEditingController(text: e?.memo ?? '');
    final now = DateTime.now();
    _date = e?.date ?? DateTime(now.year, now.month, now.day);
    _yearly = e?.yearly ?? true;
    _color = e?.color ?? AnniversaryColor.coral;
    for (final c in [_title, _memo]) {
      c.addListener(() {
        if (!_dirty) setState(() => _dirty = true);
        // 미리보기 카드 이름을 바로 바꾼다
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _memo.dispose();
    super.dispose();
  }

  void _update(VoidCallback change) {
    setState(() {
      change();
      _dirty = true;
    });
  }

  /// 오늘부터 이 기념일까지 남은 날 (매년 반복이면 다음 돌아오는 날 기준)
  (DateTime, int) _nextOccurrence() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!_yearly) return (_date, daysUntil(today, _date));
    final next = anniversariesBetween(
      custom: [Anniversary(id: '', title: '', date: _date, yearly: true)],
      from: today,
      to: DateTime(today.year + 1, today.month, today.day),
    ).firstOrNull;
    final d = next?.date ?? _date;
    return (d, daysUntil(today, d));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) _update(() => _date = picked);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('기념일 이름을 입력해 주세요')));
      return;
    }
    final couple = ref.read(coupleProvider).valueOrNull;
    if (couple == null) return;

    final service = ref.read(coupleServiceProvider);
    final memo = _memo.text.trim();
    final anniversary = Anniversary(
      id: widget.editing?.id ?? service.newAnniversaryId(),
      title: title,
      date: _date,
      yearly: _yearly,
      icon: widget.editing?.icon ?? AnniversaryIcon.heart,
      color: _color,
      memo: memo.isEmpty ? null : memo,
    );

    setState(() => _saving = true);
    try {
      await service.saveAnniversary(couple.id, anniversary);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showSaveError(context, e);
      }
    }
  }

  Future<void> _delete() async {
    final deleted = await confirmDeleteAnniversary(
      context,
      ref,
      widget.editing!,
    );
    if (deleted && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FormPageScaffold(
      title: _isEdit ? '기념일 수정' : '기념일 추가',
      subtitle: '처음 만난 날부터 생일까지, 우리만의 날을 등록해요.',
      isDirty: _dirty,
      actions: [
        if (_isEdit)
          IconButton(
            tooltip: '삭제',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _saving ? null : _delete,
          ),
      ],
      bottom: FormButtons(
        saveLabel: _isEdit ? '수정 저장하기' : '기념일 저장하기',
        onSave: _saving ? null : _save,
        onCancel: () => Navigator.of(context).maybePop(),
      ),
      children: [
        const FieldLabel('기념일 이름'),
        TextField(
          controller: _title,
          maxLength: 20,
          autofocus: !_isEdit,
          decoration: const InputDecoration(
            hintText: '예) 처음 만난 날, 1000일',
            counterText: '',
          ),
        ),
        const FieldLabel('날짜'),
        PickerField(
          text: DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(_date),
          icon: Icons.calendar_today_outlined,
          onTap: _pickDate,
        ),
        SwitchRow(
          title: '매년 반복',
          subtitle: '생일, 크리스마스처럼 해마다 오는 날',
          value: _yearly,
          onChanged: (v) => _update(() => _yearly = v),
        ),
        const FieldLabel('카드 색'),
        Row(
          children: [
            for (final c in AnniversaryColor.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c.label),
                  avatar: CircleAvatar(
                    radius: 5,
                    backgroundColor: anniversaryColor(c),
                  ),
                  selected: _color == c,
                  showCheckmark: false,
                  selectedColor: anniversaryBgColor(c),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: _color == c ? anniversaryColor(c) : AppColors.line,
                    width: 1.5,
                  ),
                  onSelected: (_) => _update(() => _color = c),
                ),
              ),
          ],
        ),
        const FieldLabel('메모', hint: '(선택)'),
        TextField(
          controller: _memo,
          maxLength: _maxMemo,
          maxLines: 3,
          minLines: 2,
          decoration: const InputDecoration(hintText: '어떻게 보낼지 미리 적어 두세요.'),
        ),
        const FieldLabel('미리보기'),
        _Preview(
          title: _title.text.trim().isEmpty ? '우리 기념일' : _title.text.trim(),
          next: _nextOccurrence(),
          yearly: _yearly,
          color: _color,
        ),
      ],
    );
  }
}

/// 저장 전에 미리 보는 D-day 카드
class _Preview extends StatelessWidget {
  final String title;
  final (DateTime, int) next;
  final bool yearly;
  final AnniversaryColor color;

  const _Preview({
    required this.title,
    required this.next,
    required this.yearly,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final (date, days) = next;
    return CozyCard(
      color: anniversaryBgColor(color),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTheme.display(22))),
              DoodleHeart(size: 16, color: anniversaryColor(color)),
            ],
          ),
          Text(
            DateFormat('M월 d일 (E)', 'ko_KR').format(date),
            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  dDayLabel(days),
                  style: AppTheme.display(34, color: anniversaryColor(color)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  yearly ? '매년 반복' : '한 번만',
                  style: TextStyle(
                    fontSize: 11,
                    color: anniversaryColor(color),
                  ),
                ),
              ),
            ],
          ),
          Text(
            daysLeftLabel(
              days,
            ).replaceAll('남음', '남았어요').replaceAll('지남', '지났어요'),
            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
