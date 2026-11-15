import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 추가·수정 페이지 공통 뼈대.
///
/// 아래에서 올라오는 전체 화면 페이지로 띄우고, 왼쪽 위 X로 닫는다.
/// [isDirty]가 true면 닫을 때 "작성 중인 내용이 사라져요" 확인을 묻는다.
class FormPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget bottom;
  final bool isDirty;
  final List<Widget>? actions;

  const FormPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    required this.bottom,
    this.isDirty = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await confirmDiscard(context);
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: '닫기',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: actions,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    Text(title, style: AppTheme.display(30)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ...children,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: bottom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 작성 중인 내용을 버리고 나갈지 묻는다. 나가면 true.
Future<bool> confirmDiscard(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('그만 쓸까요?'),
      content: const Text('작성 중인 내용이 사라져요.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('계속 쓰기'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(
            '나가기',
            style: TextStyle(color: AppColors.coralDeep),
          ),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// 입력칸 위의 작은 이름표
class FieldLabel extends StatelessWidget {
  final String text;
  final String? hint;

  const FieldLabel(this.text, {super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6, top: 14),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (hint != null)
              TextSpan(
                text: ' $hint',
                style: const TextStyle(color: AppColors.inkSoft),
              ),
          ],
        ),
        style: const TextStyle(fontSize: 13, color: AppColors.ink),
      ),
    );
  }
}

/// 눌러서 고르는 값(날짜, 시간)을 입력칸 모양으로 보여준다
class PickerField extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  const PickerField({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? Colors.white : AppColors.creamDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: enabled ? AppColors.ink : AppColors.inkSoft,
                  ),
                ),
              ),
              Icon(icon, size: 20, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

/// 연한 배경 위에 제목·설명과 스위치를 둔 줄
class SwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.creamDeep,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkSoft,
                    ),
                  ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// 알약 모양 둘 중 하나 고르기 (개인 일정 / 커플 일정)
class PillToggle<T> extends StatelessWidget {
  final List<(T value, String label, Color dot)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  /// 고를 수 없는 값 (예: 커플 연결 전의 커플 일정)
  final Set<T> disabled;

  const PillToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.disabled = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.creamDeep,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (final (value, label, dot) in options)
            Expanded(
              child: _Pill(
                label: label,
                dot: dot,
                selected: value == selected,
                onTap: disabled.contains(value) ? null : () => onChanged(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color dot;
  final bool selected;
  final VoidCallback? onTap;

  const _Pill({
    required this.label,
    required this.dot,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.line : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: enabled ? dot : dot.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: enabled ? AppColors.ink : AppColors.inkSoft,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 분홍 바탕 안내 상자
class NoticeBox extends StatelessWidget {
  final String text;
  final IconData icon;

  const NoticeBox(
    this.text, {
    super.key,
    this.icon = Icons.notifications_none_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pinkBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pink.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.pink),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.ink,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 취소 / 저장 버튼 한 줄
class FormButtons extends StatelessWidget {
  final String saveLabel;
  final VoidCallback? onSave;
  final VoidCallback onCancel;

  const FormButtons({
    super.key,
    required this.saveLabel,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.line, width: 1.5),
              ),
              child: const Text('취소'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onSave,
              child: Text(
                saveLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
