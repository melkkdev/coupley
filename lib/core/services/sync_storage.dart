import 'package:shared_preferences/shared_preferences.dart';

/// 마지막 동기화 시각을 저장/관리
class SyncStorage {
  static const String _keyPrefix = 'last_synced_at_';

  /// 마지막 동기화 시각 가져오기 (없으면 null)
  static Future<DateTime?> getLastSyncedAt(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt('$_keyPrefix$userId');
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// 마지막 동기화 시각 저장
  static Future<void> setLastSyncedAt(String userId, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyPrefix$userId', time.millisecondsSinceEpoch);
  }

  /// 동기화 시각 초기화 (로그아웃 시)
  static Future<void> clearLastSyncedAt(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$userId');
  }
}
