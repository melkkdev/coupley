import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/user_provider.dart';
import '../../auth/providers/auth_provider.dart';

/// 상단 인사 + 닉네임 + 편집 버튼
/// 이 위젯만 authState를 구독해서, 닉네임 변경 시 이 부분만 리빌드됨
class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요 👋',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        Row(
          children: [
            Text(
              authState.userName ?? '사용자',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () =>
                  _showEditNameDialog(context, ref, authState.userName ?? ''),
              child: Icon(Icons.edit, size: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: controller,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: '새 닉네임',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(
                  dialogContext,
                ).showSnackBar(const SnackBar(content: Text('닉네임을 입력해주세요')));
                return;
              }

              final authState = ref.read(authProvider);
              if (authState.userId == null) return;

              try {
                await ref
                    .read(authProvider.notifier)
                    .updateDisplayName(newName);
                await ref
                    .read(userServiceProvider)
                    .updateUserName(authState.userId!, newName);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('닉네임이 변경되었습니다')));
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text('변경 실패: $e')));
                }
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }
}
