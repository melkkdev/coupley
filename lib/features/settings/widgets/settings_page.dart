import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/services/user_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../couple/models/anniversary.dart';
import '../../couple/models/couple.dart';
import '../../couple/providers/couple_provider.dart';
import '../providers/notification_settings_provider.dart';

/// 설정 탭: 내 정보, 커플 연결(초대 코드), 알림, 로그아웃
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(authProvider.select((s) => s.userName));
    final email = ref.watch(authProvider.select((s) => s.email));

    return Scaffold(
      body: CozyBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                child: Text('설정', style: AppTheme.display(28)),
              ),
              const _GroupTitle('내 정보'),
              _Group(
                children: [
                  _Tile(
                    icon: Icons.face_outlined,
                    title: userName ?? '사용자',
                    subtitle: email,
                    trailing: const Text(
                      '닉네임 변경',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    ),
                    onTap: () => _editName(context, ref, userName ?? ''),
                  ),
                ],
              ),
              const _GroupTitle('커플 연결'),
              const _CoupleGroup(),
              const _GroupTitle('알림'),
              const _PushGroup(),
              const _GroupTitle('계정'),
              _Group(
                children: [
                  _Tile(
                    icon: Icons.logout_rounded,
                    title: '로그아웃',
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '로그아웃',
              style: TextStyle(color: AppColors.coralDeep),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(authProvider.notifier).signOut();
  }

  void _editName(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: controller,
          maxLength: 20,
          autofocus: true,
          decoration: const InputDecoration(hintText: '새 닉네임'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              final messenger = ScaffoldMessenger.of(context);
              if (newName.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('닉네임을 입력해 주세요')),
                );
                return;
              }

              final userId = ref.read(authProvider).userId;
              if (userId == null) return;

              try {
                await ref
                    .read(authProvider.notifier)
                    .updateDisplayName(newName);
                await ref
                    .read(userServiceProvider)
                    .updateUserName(userId, newName);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                messenger.showSnackBar(
                  const SnackBar(content: Text('닉네임을 바꿨어요')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('변경하지 못했어요: $e')),
                );
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }
}

/// 커플 연결 상태. 누르면 커플 연결 화면(초대 코드 만들기·입력·해제)으로 간다.
class _CoupleGroup extends ConsumerWidget {
  const _CoupleGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider).valueOrNull;
    final myId = ref.watch(authProvider.select((s) => s.userId));
    final names = ref.watch(coupleMemberNamesProvider).valueOrNull ?? const {};

    final String title;
    final String subtitle;
    if (couple != null && couple.isConnected) {
      final partnerId = couple.members.firstWhere(
        (id) => id != myId,
        orElse: () => '',
      );
      final partner = names[partnerId] ?? '짝꿍';
      final since = couple.togetherSince;
      title = '$partner님과 연결됨';
      subtitle = since == null
          ? '연결 관리'
          : '함께한 지 ${daysTogether(since, DateTime.now())}일째 · 연결 관리';
    } else if (couple != null && couple.status == CoupleStatus.pending) {
      title = '짝꿍을 기다리는 중';
      subtitle = '내 초대 코드 ${couple.inviteCode}';
    } else {
      title = '짝꿍과 연결하기';
      subtitle = '6자리 초대 코드를 만들거나 받은 코드를 입력해요';
    }

    return _Group(
      children: [
        _Tile(
          icon: Icons.favorite_border_rounded,
          iconColor: AppColors.pink,
          title: title,
          subtitle: subtitle,
          onTap: () => context.push(AppRoutes.coupleConnect),
        ),
      ],
    );
  }
}

class _PushGroup extends ConsumerWidget {
  const _PushGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(pushEnabledProvider);

    return _Group(
      children: [
        _Tile(
          icon: Icons.notifications_none_rounded,
          title: '커플 일정 알림',
          subtitle: '짝꿍이 커플 일정을 추가·수정·삭제하면 알려 줘요',
          trailing: Switch(
            value: enabled.valueOrNull ?? true,
            onChanged: enabled.isLoading
                ? null
                : (v) async {
                    try {
                      await ref.read(pushEnabledProvider.notifier).set(v);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('알림 설정을 바꾸지 못했어요. 인터넷 연결을 확인해 주세요.'),
                          ),
                        );
                      }
                    }
                  },
          ),
        ),
      ],
    );
  }
}

class _GroupTitle extends StatelessWidget {
  final String text;
  const _GroupTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return CozyCard(child: Column(children: children));
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    this.iconColor = AppColors.coral,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(14, 4, 10, 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.creamDeep,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
      trailing:
          trailing ??
          (onTap == null
              ? null
              : const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkSoft,
                )),
      onTap: onTap,
    );
  }
}
