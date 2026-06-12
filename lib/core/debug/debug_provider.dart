import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'debug_mode.dart';

/// DebugMode 상태를 관리하는 Provider
class DebugModeNotifier extends StateNotifier<DebugMode> {
  DebugModeNotifier() : super(DebugMode.production) {
    _loadDebugMode();
  }

  static const String _debugModeKey = 'debug_mode';

  /// SharedPreferences에서 저장된 디버그 모드 불러오기
  Future<void> _loadDebugMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_debugModeKey);

    if (savedMode != null) {
      final mode = DebugMode.values.firstWhere(
        (m) => m.name == savedMode,
        orElse: () => DebugMode.production,
      );
      state = mode;
    }
  }

  /// 디버그 모드 변경 및 저장
  Future<void> setDebugMode(DebugMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_debugModeKey, mode.name);
  }
}

/// DebugMode Provider
final debugModeProvider = StateNotifierProvider<DebugModeNotifier, DebugMode>(
  (ref) => DebugModeNotifier(),
);
