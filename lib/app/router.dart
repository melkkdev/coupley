import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../core/database/drift_database.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/widgets/email_login_page.dart';
import '../features/auth/widgets/login_page.dart';
import '../features/calendar/widgets/calendar_page.dart';
import '../features/calendar/widgets/event_form_page.dart';
import '../features/calendar/widgets/today_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../core/debug/debug_provider.dart';
import '../core/debug/debug_mode.dart';
import '../features/couple/models/anniversary.dart';
import '../features/couple/widgets/anniversary_form_page.dart';
import '../features/couple/widgets/couple_connect_page.dart';
import '../features/couple/widgets/anniversary_page.dart';
import '../features/settings/widgets/settings_page.dart';
import 'main_shell.dart';

/// 하단 탭 4개의 경로. 순서가 탭 순서다.
class AppTabs {
  AppTabs._();

  static const today = '/today';
  static const calendar = '/calendar';
  static const anniversaries = '/anniversaries';
  static const settings = '/settings';
}

/// 추가·수정 페이지 경로
class AppRoutes {
  AppRoutes._();

  static const emailLogin = '/login/email';
  static const coupleConnect = '/couple-connect';

  /// extra: 처음 고를 날짜(DateTime)
  static const eventNew = '/event/new';

  /// extra: 고칠 일정(Event)
  static const eventEdit = '/event/edit';

  static const anniversaryNew = '/anniversary/new';

  /// extra: 고칠 기념일(Anniversary)
  static const anniversaryEdit = '/anniversary/edit';
}

final _rootKey = GlobalKey<NavigatorState>();

/// 라우터 설정
///
/// 라우터는 한 번만 만들고, 로그인 상태가 바뀔 때만 [refresh]로 redirect를 다시 돌린다.
/// 닉네임 변경 같은 다른 변화로 라우터를 새로 만들면 보던 탭이 처음으로 돌아가기 때문이다.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(
    authProvider.select((s) => (s.isInitializing, s.isAuthenticated)),
    (_, _) => refresh.value++,
  );
  ref.listen(debugModeProvider, (_, _) => refresh.value++);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final debugMode = ref.read(debugModeProvider);
      // 초기 인증 확인 중이면 스플래시 유지 (리다이렉트 안 함)
      if (authState.isInitializing) {
        return '/splash';
      }

      final location = state.matchedLocation;
      final isLoginPage = location.startsWith('/login');
      final isSplash = location == '/splash';

      // Debug 모드에서 Auth Skip인 경우
      if (debugMode == DebugMode.skipAuth) {
        if (isLoginPage || isSplash) return AppTabs.today;
        return null;
      }

      // 일반 인증 플로우
      final isAuthenticated = authState.isAuthenticated;

      // 확인 끝났는데 스플래시에 있으면 적절한 곳으로
      if (isSplash) {
        return isAuthenticated ? AppTabs.today : '/login';
      }

      if (!isAuthenticated && !isLoginPage) {
        return '/login';
      }
      if (isAuthenticated && isLoginPage) {
        return AppTabs.today;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
        routes: [
          GoRoute(
            path: 'email',
            builder: (context, state) => const EmailLoginPage(),
          ),
        ],
      ),
      GoRoute(path: '/', redirect: (context, state) => AppTabs.today),
      appShellRoute(),
      GoRoute(
        path: AppRoutes.coupleConnect,
        builder: (context, state) => const CoupleConnectPage(),
      ),
      GoRoute(
        path: AppRoutes.eventNew,
        pageBuilder: (context, state) => _slideUp(
          state,
          EventFormPage(
            initialDate: state.extra as DateTime? ?? DateTime.now(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.eventEdit,
        pageBuilder: (context, state) {
          final event = state.extra as Event;
          return _slideUp(
            state,
            EventFormPage(initialDate: event.date, editEvent: event),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.anniversaryNew,
        pageBuilder: (context, state) =>
            _slideUp(state, const AnniversaryFormPage()),
      ),
      GoRoute(
        path: AppRoutes.anniversaryEdit,
        pageBuilder: (context, state) => _slideUp(
          state,
          AnniversaryFormPage(editing: state.extra as Anniversary),
        ),
      ),
    ],
  );
});

/// 하단 탭 4개를 담은 경로 (테스트에서도 같은 구성을 쓴다)
StatefulShellRoute appShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, shell) => MainShell(shell: shell),
    branches: [
      for (final (path, page) in [
        (AppTabs.today, const TodayPage()),
        (AppTabs.calendar, const CalendarPage()),
        (AppTabs.anniversaries, const AnniversaryPage()),
        (AppTabs.settings, const SettingsPage()),
      ])
        StatefulShellBranch(
          routes: [GoRoute(path: path, builder: (context, state) => page)],
        ),
    ],
  );
}

/// 아래에서 올라오는 전체 화면 페이지 (추가·수정 화면용)
Page<void> _slideUp(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    fullscreenDialog: true,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

/// 인증 확인 중 스플래시
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Coupley',
              style: AppTheme.display(48, color: AppColors.coralDeep),
            ),
            const SizedBox(height: 4),
            const Text(
              '둘이 함께 쓰는 캘린더',
              style: TextStyle(fontSize: 14, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
