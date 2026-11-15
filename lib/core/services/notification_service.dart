import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 백그라운드 메시지 핸들러 — 반드시 최상위 함수
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase는 main()에서 이미 초기화됨
}

class NotificationService {
  static final _local = FlutterLocalNotificationsPlugin();

  static const _channelId = 'coupley_events';
  static const _channelName = '일정 알림';

  /// 설정 탭의 '커플 일정 알림' 스위치 값 (기본 켜짐)
  static const enabledKey = 'push_enabled';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(enabledKey) ?? true;
  }

  /// 알림 켜기/끄기. 끄면 서버의 토큰을 지워 푸시가 오지 않게 하고,
  /// 켜면 토큰을 다시 저장한다.
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(enabledKey, enabled);
    if (enabled) {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await messaging.getToken();
      if (token != null) await _saveToken(token);
    } else {
      await clearToken();
    }
  }

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    // 알림 권한 요청
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // flutter_local_notifications 초기화 (포그라운드 알림 표시용)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Android 알림 채널 생성
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 포그라운드 메시지 → 직접 로컬 알림 표시
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // FCM 토큰 저장 및 갱신 구독
    final token = await messaging.getToken();
    if (token != null) await _saveToken(token);
    messaging.onTokenRefresh.listen(_saveToken);
  }

  static Future<void> _saveToken(String token) async {
    if (!await isEnabled()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': token,
      'updatedAt': Timestamp.now(),
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// 로그아웃 시 FCM 토큰 제거
  static Future<void> clearToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': null,
      'updatedAt': Timestamp.now(),
    });
    await FirebaseMessaging.instance.deleteToken();
  }
}
