import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';

/// 커플 일정 푸시 알림을 받을지 (기기마다 따로 저장)
class PushEnabledNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => NotificationService.isEnabled();

  Future<void> set(bool enabled) async {
    final previous = state.valueOrNull ?? true;
    state = AsyncData(enabled);
    try {
      await NotificationService.setEnabled(enabled);
    } catch (e, st) {
      // 서버에 반영하지 못하면 스위치를 되돌린다
      state = AsyncData(previous);
      Error.throwWithStackTrace(e, st);
    }
  }
}

final pushEnabledProvider = AsyncNotifierProvider<PushEnabledNotifier, bool>(
  PushEnabledNotifier.new,
);
