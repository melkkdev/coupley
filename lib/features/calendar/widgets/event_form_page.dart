import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/drift_database.dart';
import '../../../core/design/cozy/form_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../couple/providers/couple_provider.dart';
import '../providers/calendar_provider.dart';

/// 일정 추가·수정 페이지 (아래에서 올라오는 전체 화면)
/// [editEvent]가 null이면 추가, 있으면 수정
class EventFormPage extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final Event? editEvent;

  const EventFormPage({super.key, required this.initialDate, this.editEvent});

  @override
  ConsumerState<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends ConsumerState<EventFormPage> {
  static const _maxDescription = 120;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _date;
  bool _isAllDay = false;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isCoupleEvent = false;
  bool _dirty = false;
  bool _saving = false;

  bool get _isEditMode => widget.editEvent != null;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;

    // 새 일정은 다음 정각부터 한 시간으로 시작한다
    final nextHour = (TimeOfDay.now().hour + 1) % 24;
    _startTime = TimeOfDay(hour: nextHour, minute: 0);
    _endTime = TimeOfDay(hour: (nextHour + 1) % 24, minute: 0);

    final e = widget.editEvent;
    if (e != null) {
      _titleController.text = e.title;
      _descriptionController.text = e.description ?? '';
      _date = e.date;
      _isAllDay = e.isAllDay;
      _isCoupleEvent = e.coupleId != null;
      if (e.startTime != null)
        _startTime = TimeOfDay.fromDateTime(e.startTime!);
      if (e.endTime != null) _endTime = TimeOfDay.fromDateTime(e.endTime!);
    }

    for (final c in [_titleController, _descriptionController]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _update(VoidCallback change) {
    setState(() {
      change();
      _dirty = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime _at(TimeOfDay t) =>
      DateTime(_date.year, _date.month, _date.day, t.hour, t.minute);

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _snack('제목을 입력해 주세요');
      return;
    }
    if (!_isAllDay && !_at(_endTime).isAfter(_at(_startTime))) {
      _snack('끝나는 시간이 시작 시간보다 늦어야 해요');
      return;
    }

    final description = _descriptionController.text.trim();
    final notifier = ref.read(calendarNotifierProvider.notifier);
    final color = eventColor(isCouple: _isCoupleEvent);
    final start = _isAllDay ? null : _at(_startTime);
    final end = _isAllDay ? null : _at(_endTime);

    setState(() => _saving = true);
    try {
      if (_isEditMode) {
        await notifier.updateEvent(
          id: widget.editEvent!.id,
          title: title,
          date: _date,
          description: description.isEmpty ? null : description,
          color: color,
          isAllDay: _isAllDay,
          startTime: start,
          endTime: end,
          isCoupleEvent: _isCoupleEvent,
        );
      } else {
        await notifier.addEvent(
          title: title,
          date: _date,
          description: description.isEmpty ? null : description,
          color: color,
          isAllDay: _isAllDay,
          startTime: start,
          endTime: end,
          isCoupleEvent: _isCoupleEvent,
        );
      }
      if (mounted) {
        _dirty = false;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _snack(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.coralDeep),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    await ref
        .read(calendarNotifierProvider.notifier)
        .deleteEvent(widget.editEvent!.id);
    if (mounted) {
      _dirty = false;
      Navigator.of(context).pop();
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) _update(() => _date = picked);
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (picked == null) return;
    _update(() {
      if (start) {
        // 시작을 옮기면 끝 시간도 같은 길이만큼 따라간다
        final length = _at(
          _endTime,
        ).difference(_at(_startTime)).inMinutes.clamp(30, 1440);
        _startTime = picked;
        _endTime = TimeOfDay.fromDateTime(
          _at(picked).add(Duration(minutes: length)),
        );
      } else {
        _endTime = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final couple = ref.watch(coupleProvider).valueOrNull;
    final canShare = couple != null && couple.isConnected;
    final timeFormat = DateFormat('a h:mm', 'ko_KR');

    return FormPageScaffold(
      title: _isEditMode ? '일정 수정' : '일정 추가',
      subtitle: '개인 일정과 커플 일정을 한 화면에서 골라요.',
      isDirty: _dirty,
      actions: [
        if (_isEditMode)
          IconButton(
            tooltip: '삭제',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _saving ? null : _delete,
          ),
      ],
      bottom: FormButtons(
        saveLabel: _isEditMode ? '수정 저장하기' : '일정 저장하기',
        onSave: _saving ? null : _save,
        onCancel: () => Navigator.of(context).maybePop(),
      ),
      children: [
        PillToggle<bool>(
          options: const [
            (false, '개인 일정', AppColors.mint),
            (true, '커플 일정', AppColors.pink),
          ],
          selected: _isCoupleEvent,
          disabled: canShare ? const {} : const {true},
          onChanged: (v) => _update(() => _isCoupleEvent = v),
        ),
        if (!canShare)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text(
              '커플 일정은 짝꿍과 연결한 뒤에 쓸 수 있어요',
              style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
          ),
        const FieldLabel('제목'),
        TextField(
          controller: _titleController,
          maxLength: 30,
          autofocus: !_isEditMode,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: '예) 저녁 데이트',
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
          title: '종일 일정',
          value: _isAllDay,
          onChanged: (v) => _update(() => _isAllDay = v),
        ),
        if (!_isAllDay)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('시작 시간'),
                    PickerField(
                      text: timeFormat.format(_at(_startTime)),
                      icon: Icons.schedule_rounded,
                      onTap: () => _pickTime(start: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('종료 시간'),
                    PickerField(
                      text: timeFormat.format(_at(_endTime)),
                      icon: Icons.schedule_rounded,
                      onTap: () => _pickTime(start: false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        const FieldLabel('설명', hint: '(선택)'),
        TextField(
          controller: _descriptionController,
          maxLength: _maxDescription,
          maxLines: 3,
          minLines: 3,
          decoration: const InputDecoration(hintText: '장소나 준비물을 적어 두세요.'),
        ),
        if (_isCoupleEvent)
          const NoticeBox('커플 일정으로 저장하면 상대방 캘린더에도 바로 보이고 푸시 알림이 함께 가요.'),
      ],
    );
  }
}
