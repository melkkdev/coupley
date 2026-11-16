import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/spacing.dart';
import 'debug_mode.dart';
import 'debug_provider.dart';

/// 플로팅 디버그 버튼 (개발 시에만 표시)
/// 화면 우측 하단에 작은 벌레 아이콘으로 표시되고,
/// 누르면 디버그 모드 선택 팝업이 열립니다.
class DebugFloatingButton extends ConsumerWidget {
  const DebugFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Release 모드에서는 표시하지 않음
    if (const bool.fromEnvironment('dart.vm.product')) {
      return const SizedBox.shrink();
    }

    final currentMode = ref.watch(debugModeProvider);

    // Production에서는 화면을 가리지 않도록 왼쪽 가장자리에 작은 반투명 아이콘만 둔다.
    // 다른 모드일 때만 눈에 띄는 라벨을 보여 줘서 실수로 켜 둔 걸 알아챌 수 있게 한다.
    final isProduction = currentMode == DebugMode.production;

    return Positioned(
      left: 0,
      top: MediaQuery.of(context).size.height * 0.4,
      child: GestureDetector(
        onTap: () => _showDebugSheet(context, ref),
        child: Opacity(
          opacity: isProduction ? 0.35 : 1,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isProduction ? 6 : AppSpacing.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(AppSpacing.radiusXl),
              ),
              border: isProduction
                  ? null
                  : Border.all(color: Colors.yellow, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bug_report, color: Colors.yellow, size: 16),
                if (!isProduction) ...[
                  const SizedBox(width: 4),
                  Text(
                    currentMode.label,
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDebugSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DebugBottomSheet(),
    );
  }
}

/// 디버그 모드 선택 바텀시트
class _DebugBottomSheet extends ConsumerWidget {
  const _DebugBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(debugModeProvider);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.yellow, size: 24),
              AppSpacing.gapSm,
              const Text(
                'Debug Mode',
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.yellow, size: 24),
              ),
            ],
          ),
          AppSpacing.gapMd,
          ...DebugMode.values.map((mode) {
            final isSelected = currentMode == mode;
            return InkWell(
              onTap: () {
                ref.read(debugModeProvider.notifier).setDebugMode(mode);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.md,
                ),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.yellow.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isSelected ? Colors.yellow : Colors.grey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.yellow : Colors.grey,
                      size: 20,
                    ),
                    AppSpacing.gapSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.label,
                            style: TextStyle(
                              color: isSelected ? Colors.yellow : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                          if (mode == DebugMode.production)
                            Text(
                              'Firebase 사용',
                              style: TextStyle(
                                color:
                                    (isSelected ? Colors.yellow : Colors.grey)
                                        .withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          if (mode == DebugMode.mockData)
                            Text(
                              '로컬 DB만 사용',
                              style: TextStyle(
                                color:
                                    (isSelected ? Colors.yellow : Colors.grey)
                                        .withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
