import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';

import '../../../core/common/nickname_generator.dart';
import '../models/auth_status.dart';

/// Auth 상태를 관리하는 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initializing()) {
    // ← initializing으로
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        state = const AuthState.unauthenticated();
      } else {
        state = AuthState.authenticated(user: user);
      }
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Google 로그인
  Future<void> signInWithGoogle() async {
    try {
      // Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // 사용자가 취소함

      // Google Auth 획득
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase credential 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase 로그인
      await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign In Error: $e');
      rethrow;
    }
  }

  /// 이메일/비밀번호 회원가입
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 랜덤 닉네임 자동 생성 후 설정
      final nickname = NicknameGenerator.generate();
      await credential.user?.updateDisplayName(nickname);
      await credential.user?.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      print('SignUp Error: $e');
      rethrow;
    }
  }

  /// 이메일/비밀번호 로그인
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      print('SignIn Error: $e');
      rethrow;
    }
  }

  /// Firebase Auth 에러 메시지 한글화
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return '비밀번호는 6자 이상이어야 합니다';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다';
      case 'invalid-email':
        return '올바른 이메일 형식이 아닙니다';
      case 'user-not-found':
        return '존재하지 않는 계정입니다';
      case 'wrong-password':
        return '비밀번호가 틀렸습니다';
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다';
      default:
        return '로그인 실패: ${e.message}';
    }
  }

  /// Apple 로그인 (iOS만)
  Future<void> signInWithApple() async {
    try {
      if (!Platform.isIOS) {
        throw UnsupportedError('Apple Sign In is only supported on iOS');
      }

      // Apple Sign In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Firebase credential 생성
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Firebase 로그인
      await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      print('Apple Sign In Error: $e');
      rethrow;
    }
  }

  /// displayName(닉네임) 변경
  Future<void> updateDisplayName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(newName);
    // await user.reload();
    state = state.copyWith(userName: newName);
    // 갱신된 user로 상태 재생성
    // final updated = _auth.currentUser;
    // if (updated != null) {
    //   state = AuthState.authenticated(user: updated);
    // }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  /// 현재 사용자
  User? get currentUser => _auth.currentUser;
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
