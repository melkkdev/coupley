import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/common/spacing.dart';
import '../models/couple.dart';
import '../providers/couple_provider.dart';

/// 커플 연결 화면
/// - 연결 안 됨: 선택 화면 (만들기 + 입력), 코드 만들었으면 하단에 코드 카드
/// - 연결 됨: 파트너 정보 표시
class CoupleConnectPage extends ConsumerWidget {
  const CoupleConnectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleAsync = ref.watch(coupleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('커플 연결')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.blue.shade50],
          ),
        ),
        child: coupleAsync.when(
          data: (couple) {
            if (couple != null && couple.isConnected) {
              // 연결 완료
              return _ConnectedView(couple: couple);
            } else {
              // 연결 안 됨 (couple이 null이거나 pending)
              // → 항상 선택 화면 유지, pending이면 코드 카드 추가 표시
              return _NotConnectedView(pendingCouple: couple);
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('에러: $e')),
        ),
      ),
    );
  }
}

/// 연결 안 됨: 선택 화면 (만들기 + 입력)
/// pendingCouple이 있으면 = 내가 만든 코드가 있는 상태 → 하단에 코드 카드 표시
class _NotConnectedView extends ConsumerWidget {
  final Couple? pendingCouple;

  const _NotConnectedView({this.pendingCouple});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSpacing.gapXxl,
          const Icon(Icons.favorite_border, size: 80, color: Colors.purple),
          AppSpacing.gapLg,
          const Text(
            '파트너와 연결하세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          AppSpacing.gapSm,
          Text(
            '초대 코드를 만들어 공유하거나\n받은 코드를 입력하세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          AppSpacing.gapXxl,

          // 초대 코드 만들기 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                final couple = await ref
                    .read(coupleNotifierProvider.notifier)
                    .createInvite();
                if (couple == null && context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('코드 생성 실패')));
                }
              },
              icon: const Icon(Icons.add),
              label: Text(
                pendingCouple != null ? '새 코드 만들기' : '초대 코드 만들기',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ),
          AppSpacing.gapMd,

          // 코드 입력하기 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _showJoinDialog(context, ref),
              icon: const Icon(Icons.login),
              label: const Text(
                '코드 입력하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: const BorderSide(color: Colors.purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ),

          // 내가 만든 코드가 있으면 하단에 코드 카드 표시
          if (pendingCouple != null) ...[
            AppSpacing.gapXl,
            const Divider(),
            AppSpacing.gapMd,
            _MyCodeCard(couple: pendingCouple!),
          ],
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('초대 코드 입력'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: '예: A7K2P9',
            border: OutlineInputBorder(),
          ),
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.isEmpty) return;

              // await 전에 messenger 미리 확보 (dialog context 기준)
              final messenger = ScaffoldMessenger.of(dialogContext);
              final navigator = Navigator.of(dialogContext);

              try {
                await ref
                    .read(coupleNotifierProvider.notifier)
                    .joinByCode(code);

                // 다이얼로그 먼저 닫기
                navigator.pop();

                // 미리 확보한 messenger로 스낵바 (전환된 화면 context 안 씀)
                messenger.showSnackBar(
                  const SnackBar(content: Text('커플 연결 완료! 💑')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                  ),
                );
              }
            },
            child: const Text('연결하기'),
          ),
        ],
      ),
    );
  }
}

/// 내가 만든 초대 코드 카드 (대기중 표시)
class _MyCodeCard extends ConsumerWidget {
  final Couple couple;
  const _MyCodeCard({required this.couple});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty, size: 18, color: Colors.orange),
              AppSpacing.gapSm,
              Text(
                '파트너의 합류를 기다리는 중',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Text(
            '내 초대 코드',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          AppSpacing.gapSm,
          Text(
            couple.inviteCode,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: Colors.purple,
            ),
          ),
          AppSpacing.gapSm,
          // 복사 버튼
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: couple.inviteCode));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('코드가 복사되었습니다')));
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('복사'),
          ),
          AppSpacing.gapMd,

          // 공유 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Share.share(
                  '우리 커플 캘린더에서 만나요! 💑\n'
                  '초대 코드: ${couple.inviteCode}\n\n'
                  'Coupley 앱에서 코드를 입력하세요.',
                );
              },
              icon: const Icon(Icons.share, size: 20),
              label: const Text('초대 코드 공유하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ),
          AppSpacing.gapSm,

          // 코드 취소 버튼
          TextButton(
            onPressed: () async {
              await ref
                  .read(coupleNotifierProvider.notifier)
                  .disconnect(couple);
            },
            child: const Text('이 코드 취소', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 연결 완료된 상태
class _ConnectedView extends ConsumerWidget {
  final Couple couple;
  const _ConnectedView({required this.couple});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, size: 80, color: Colors.pink),
              AppSpacing.gapLg,
              const Text(
                '커플 연결 완료! 💑',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              AppSpacing.gapSm,
              Text(
                '이제 일정을 함께 공유할 수 있어요',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              AppSpacing.gapXl,
              Text(
                '연결된 멤버: ${couple.members.length}명',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              AppSpacing.gapXxl,

              // 확인 버튼 (캘린더로 돌아가기)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 캘린더로 돌아감
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: const Text(
                    '캘린더로 가기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              AppSpacing.gapMd,

              // 연결 해제 버튼
              TextButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Text('연결 해제'),
                        ],
                      ),
                      content: const Text(
                        '정말 커플 연결을 해제하시겠습니까?\n\n'
                        '⚠️ 함께 공유한 모든 커플 일정이 삭제되며,\n'
                        '이 작업은 되돌릴 수 없습니다.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text(
                            '해제하기',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ref
                        .read(coupleNotifierProvider.notifier)
                        .disconnect(couple);
                  }
                },
                child: const Text('연결 해제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
