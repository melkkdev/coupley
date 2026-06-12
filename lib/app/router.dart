import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../features/auth/widgets/login_page.dart';
import '../features/calendar/widgets/calendar_home.dart';
import '../features/auth/providers/auth_provider.dart';
import '../core/debug/debug_provider.dart';
import '../core/debug/debug_mode.dart';
import '../features/couple/widgets/couple_connect_page.dart';

/// 라우터 설정
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final debugMode = ref.watch(debugModeProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // 초기 인증 확인 중이면 스플래시 유지 (리다이렉트 안 함)
      if (authState.isInitializing) {
        return '/splash';
      }

      // Debug 모드에서 Auth Skip인 경우
      if (debugMode == DebugMode.skipAuth) {
        if (state.matchedLocation == '/login' ||
            state.matchedLocation == '/splash') {
          return '/calendar';
        }
        return null;
      }

      // 일반 인증 플로우
      final isAuthenticated = authState.isAuthenticated;
      final isLoginPage = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      // 확인 끝났는데 스플래시에 있으면 적절한 곳으로
      if (isSplash) {
        return isAuthenticated ? '/calendar' : '/login';
      }

      if (!isAuthenticated && !isLoginPage) {
        return '/login';
      }
      if (isAuthenticated && isLoginPage) {
        return '/calendar';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', redirect: (context, state) => '/calendar'),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarHome(),
      ),
      GoRoute(
        path: '/couple-connect',
        builder: (context, state) => const CoupleConnectPage(),
      ),
    ],
  );
});

/// 인증 확인 중 스플래시
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade100, Colors.blue.shade100],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month, size: 100, color: Colors.purple),
              SizedBox(height: 24),
              Text(
                'Coupley',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
