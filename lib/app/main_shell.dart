import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/debug/debug_panel.dart';
import '../core/services/realtime_sync_provider.dart';
import '../core/theme/app_theme.dart';

/// 하단 탭 4개(오늘 일정 · 달력 · 기념일 · 설정)를 담는 뼈대
class MainShell extends ConsumerWidget {
  final StatefulNavigationShell shell;

  const MainShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 실시간 동기화 리스너는 어느 탭에 있든 켜 둔다 (커플 + 개인)
    ref.watch(realtimeCoupleSyncProvider);
    ref.watch(realtimePersonalSyncProvider);

    return Scaffold(
      body: Stack(
        children: [shell, if (kDebugMode) const DebugFloatingButton()],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line, width: 1.5)),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          // 지금 탭을 다시 누르면 그 탭의 첫 화면으로 돌아간다
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: '오늘 일정',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: '달력',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: '기념일',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }
}
