import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'dart:async';
import 'dart:io';

import '../../../core/common/nickname_generator.dart';
import '../../../core/services/notification_service.dart';
import '../models/auth_status.dart';

/// 인증번호 발송 결과
class PhoneCodeResult {
  const PhoneCodeResult.codeSent(this.verificationId, this.resendToken)
      : autoVerified = false;
  const PhoneCodeResult.autoVerified()
      : verificationId = null,
        resendToken = null,
        autoVerified = true;

  /// 인증번호 입력 시 필요한 ID (자동 인증이면 null)
  final String? verificationId;

  /// 재전송 시 넘길 토큰
  final int? resendToken;

  /// 안드로이드 SMS 자동 인식으로 이미 로그인됨
  final bool autoVerified;
}

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

  /// 휴대폰 번호로 인증번호(SMS) 발송
  ///
  /// [phoneNumber]는 E.164 형식(+821012345678).
  /// 안드로이드에서 SMS를 자동으로 읽어 바로 로그인되면 [PhoneCodeResult.autoVerified],
  /// 아니면 인증번호 입력에 필요한 verificationId를 담아 돌려준다.
  Future<PhoneCodeResult> sendSmsCode(
    String phoneNumber, {
    int? resendToken,
  }) {
    final completer = Completer<PhoneCodeResult>();

    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // 안드로이드 SMS 자동 인식 → 바로 로그인
        try {
          await _signInWithPhoneCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(const PhoneCodeResult.autoVerified());
          }
        } on FirebaseAuthException catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(_phoneErrorMessage(e));
          }
        }
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(_phoneErrorMessage(e));
        }
      },
      codeSent: (verificationId, newResendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneCodeResult.codeSent(verificationId, newResendToken),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  /// 사용자가 입력한 6자리 인증번호로 로그인
  Future<void> confirmSmsCode(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _signInWithPhoneCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _phoneErrorMessage(e);
    }
  }

  /// 전화번호 credential로 로그인하고, 처음 가입이면 랜덤 닉네임 부여
  Future<void> _signInWithPhoneCredential(PhoneAuthCredential credential) async {
    final result = await _auth.signInWithCredential(credential);
    await _ensureNickname(result.user);
  }

  /// 처음 가입한 사용자면 랜덤 닉네임을 부여하고 상태에 반영한다.
  ///
  /// authStateChanges는 닉네임 설정 전에 먼저 발생하므로, 여기서 상태를 다시
  /// 만들어 줘야 화면에 '사용자' 대신 새 닉네임이 바로 보인다.
  Future<void> _ensureNickname(User? user) async {
    if (user == null || (user.displayName ?? '').isNotEmpty) return;
    await user.updateDisplayName(NicknameGenerator.generate());
    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed != null) state = AuthState.authenticated(user: refreshed);
  }

  /// 전화 인증 에러 메시지 한글화
  String _phoneErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return '올바른 휴대폰 번호가 아니에요';
      case 'invalid-verification-code':
        return '인증번호가 맞지 않아요';
      case 'session-expired':
        return '인증 시간이 지났어요. 인증번호를 다시 받아 주세요';
      case 'too-many-requests':
        return '요청이 너무 많아요. 잠시 후 다시 시도해 주세요';
      case 'quota-exceeded':
        return '오늘 보낼 수 있는 인증 문자를 모두 썼어요';
      case 'operation-not-allowed':
        return '지금은 휴대폰 인증을 쓸 수 없어요. 잠시 후 다시 시도해 주세요';
      case 'network-request-failed':
        return '네트워크 연결을 확인해 주세요';
      default:
        return '인증 실패: ${e.message}';
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

  /// 카카오 로그인
  ///
  /// 카카오톡 앱 설치 시 앱으로, 미설치 시 카카오 계정 웹으로 로그인한 뒤
  /// 카카오 액세스 토큰을 Cloud Functions(`kakaoLogin`)로 보내 서버에서 검증하고,
  /// 발급받은 Firebase Custom Token으로 로그인한다.
  Future<void> signInWithKakao() async {
    try {
      // 카카오톡 설치 여부에 따라 분기
      final kakao.OAuthToken kakaoToken;
      if (await kakao.isKakaoTalkInstalled()) {
        kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 서버에서 카카오 토큰 검증 후 Firebase Custom Token 발급
      final result = await FirebaseFunctions.instanceFor(
        region: 'asia-northeast3',
      ).httpsCallable('kakaoLogin').call<Map<String, dynamic>>({
        'accessToken': kakaoToken.accessToken,
      });
      final customToken = result.data['token'] as String;

      final credential = await _auth.signInWithCustomToken(customToken);

      // 카카오 닉네임 동의를 안 했으면 랜덤 닉네임 부여
      await _ensureNickname(credential.user);
    } catch (e) {
      print('Kakao Sign In Error: $e');
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    // FCM 토큰 제거 (로그아웃 전에 처리)
    await NotificationService.clearToken();
    // 카카오 로그인 상태이면 카카오도 로그아웃
    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {
      // 카카오 로그인 상태가 아니어도 무시
    }
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  /// 현재 사용자
  User? get currentUser => _auth.currentUser;
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
