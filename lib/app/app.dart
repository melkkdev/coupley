import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/couple/providers/couple_provider.dart';
import '../core/services/sync_provider.dart';
import '../core/services/user_provider.dart';

/// 앱의 루트 위젯
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // 🔄 로그인되면 프로필 생성 + 동기화
    ref.listen(authProvider, (previous, next) async {
      final wasAuthenticated = previous?.isAuthenticated ?? false;
      final isNowAuthenticated = next.isAuthenticated;

      if (!wasAuthenticated && isNowAuthenticated && next.userId != null) {
        // 프로필 생성/업데이트
        await ref
            .read(userServiceProvider)
            .createOrUpdateProfile(
              userId: next.userId!,
              userName: next.userName ?? '사용자',
              email: next.email,
              photoUrl: next.photoUrl,
            );

        // 동기화 (이 시점엔 솔로로, 커플이면 아래 리스너가 재동기화)
        ref.read(syncNotifierProvider.notifier).syncEvents(next.userId!);
      }
    });

    // 🔄 커플 연결되면 coupleId 기준으로 재동기화
    ref.listen(coupleProvider, (previous, next) {
      final prevCouple = previous?.valueOrNull;
      final nextCouple = next.valueOrNull;

      final wasConnected = prevCouple?.isConnected ?? false;
      final isNowConnected = nextCouple?.isConnected ?? false;

      if (!wasConnected && isNowConnected && nextCouple != null) {
        final authState = ref.read(authProvider);
        if (authState.userId != null) {
          ref
              .read(syncNotifierProvider.notifier)
              .syncEvents(authState.userId!, coupleId: nextCouple.id);
        }
      }
    });

    return MaterialApp.router(
      title: 'Coupley',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      // 날짜·시간 선택기 등 기본 위젯을 한국어로 표시
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 앱바가 없는 화면도 밝은 배경에 맞춰 상태바 아이콘을 어둡게 한다
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.overlayStyle,
        child: child!,
      ),
    );
  }
}
