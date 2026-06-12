import 'package:firebase_auth/firebase_auth.dart';

/// 사용자 인증 상태
class AuthState {
  final bool isAuthenticated;
  final bool isInitializing; // 초기 인증 확인 중
  final String? userId;
  final String? userName;
  final String? email;
  final String? photoUrl;

  const AuthState({
    required this.isAuthenticated,
    this.isInitializing = false,
    this.userId,
    this.userName,
    this.email,
    this.photoUrl,
  });

  // 초기 상태 = 인증 확인 중
  const AuthState.initializing()
    : isAuthenticated = false,
      isInitializing = true,
      userId = null,
      userName = null,
      email = null,
      photoUrl = null;

  const AuthState.unauthenticated()
    : isAuthenticated = false,
      isInitializing = false,
      userId = null,
      userName = null,
      email = null,
      photoUrl = null;

  AuthState.authenticated({required User user})
    : isAuthenticated = true,
      isInitializing = false,
      userId = user.uid,
      userName = user.displayName,
      email = user.email,
      photoUrl = user.photoURL;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isInitializing,
    String? userId,
    String? userName,
    String? email,
    String? photoUrl,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitializing: isInitializing ?? this.isInitializing,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
