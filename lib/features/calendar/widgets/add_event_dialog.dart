import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/spacing.dart';
import '../../../core/database/drift_database.dart';
import '../../couple/providers/couple_provider.dart';
import '../providers/calendar_provider.dart';

/// 이벤트 추가/수정 다이얼로그
/// [editEvent]가 null이면 추가, 있으면 수정 모드
class AddEventDialog extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final Event? editEvent;

  const AddEventDialog({super.key, required this.initialDate, this.editEvent});

  @override
  ConsumerState<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends ConsumerState<AddEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  Color _selectedColor = Colors.blue;
  bool _isAllDay = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isCoupleEvent = false;

  bool get _isEditMode => widget.editEvent != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;

    if (widget.editEvent != null) {
      final e = widget.editEvent!;
      _titleController.text = e.title;
      _descriptionController.text = e.description ?? '';
      _selectedDate = e.date;
      _selectedColor = Color(int.parse(e.color.substring(1), radix: 16));
      _isAllDay = e.isAllDay;
      _isCoupleEvent = e.coupleId != null;
      if (e.startTime != null) {
        _startTime = TimeOfDay.fromDateTime(e.startTime!);
      }
      if (e.endTime != null) {
        _endTime = TimeOfDay.fromDateTime(e.endTime!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    DateTime? startTime;
    DateTime? endTime;

    if (!_isAllDay && _startTime != null) {
      startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    }
    if (!_isAllDay && _endTime != null) {
      endTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    final notifier = ref.read(calendarNotifierProvider.notifier);

    try {
      if (_isEditMode) {
        await notifier.updateEvent(
          id: widget.editEvent!.id,
          title: _titleController.text,
          date: _selectedDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          color: _selectedColor,
          isAllDay: _isAllDay,
          startTime: startTime,
          endTime: endTime,
          isCoupleEvent: _isCoupleEvent,
        );
      } else {
        await notifier.addEvent(
          title: _titleController.text,
          date: _selectedDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          color: _selectedColor,
          isAllDay: _isAllDay,
          startTime: startTime,
          endTime: endTime,
          isCoupleEvent: _isCoupleEvent,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditMode ? '이벤트 수정' : '이벤트 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 커플 연결된 경우만 개인/커플 선택 표시
            Consumer(
              builder: (context, ref, _) {
                final couple = ref.watch(coupleProvider).valueOrNull;
                if (couple == null || !couple.isConnected) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('개인'),
                        icon: Icon(Icons.person, size: 18),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('커플'),
                        icon: Icon(Icons.favorite, size: 18),
                      ),
                    ],
                    selected: {_isCoupleEvent},
                    onSelectionChanged: (selected) {
                      setState(() {
                        _isCoupleEvent = selected.first;
                        _selectedColor = _isCoupleEvent
                            ? Colors.pink
                            : Colors.blue;
                      });
                    },
                  ),
                );
              },
            ),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            AppSpacing.gapMd,
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명 (선택)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            AppSpacing.gapMd,
            SwitchListTile(
              title: const Text('종일'),
              value: _isAllDay,
              onChanged: (value) {
                setState(() {
                  _isAllDay = value;
                });
              },
            ),
            if (!_isAllDay) ...[
              ListTile(
                title: const Text('시작 시간'),
                trailing: Text(_startTime?.format(context) ?? '선택'),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _startTime = time;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('종료 시간'),
                trailing: Text(_endTime?.format(context) ?? '선택'),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _endTime = time;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(_isEditMode ? '수정' : '추가'),
        ),
      ],
    );
  }
}
