// lib/features/auth/auth_status.dart
enum AuthStatus {
  unknown, // 앱 시작 직후 (Splash)
  unauthenticated, // 로그인 안 됨
  authenticated, // 로그인 완료
}
