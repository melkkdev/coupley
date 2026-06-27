import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화
  KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);
  // 캘린더 한글 표시(월 제목, 요일)를 위한 로케일 데이터 초기화
  await initializeDateFormatting('ko_KR');
  // Firebase 초기화
  await Firebase.initializeApp();

  // FCM 백그라운드 핸들러 등록 (Firebase 초기화 직후)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Firestore 오프라인 지속성 활성화
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // 알림 서비스 초기화 (권한 요청 + 토큰 저장)
  await NotificationService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}
