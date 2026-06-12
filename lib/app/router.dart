import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      // Debug 모드에서 Auth Skip인 경우
      if (debugMode == DebugMode.skipAuth) {
        if (state.matchedLocation == '/login') {
          return '/calendar';
        }
        return null;
      }

      // 일반 인증 플로우
      final isAuthenticated = authState.isAuthenticated;
      final isLoginPage = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginPage) {
        return '/login';
      }
      if (isAuthenticated && isLoginPage) {
        return '/calendar';
      }
      return null;
    },
    routes: [
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
