import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/drift_database.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/sync_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../couple/providers/couple_provider.dart';

/// 선택된 날짜 Provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// 포커스된 날짜 Provider (캘린더 표시용)
final focusedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// 커플 정보 Provider
final coupleInfoProvider = StreamProvider.autoDispose<CoupleInfoData?>((ref) {
  final database = ref.watch(databaseProvider);
  final authState = ref.watch(authProvider);

  if (!authState.isAuthenticated || authState.userId == null) {
    return Stream.value(null);
  }

  return database.watchCoupleInfo(authState.userId!);
});

/// 선택된 날짜의 이벤트 Provider (커플/솔로 자동 분기)
final selectedDayEventsProvider = StreamProvider.autoDispose<List<Event>>((
  ref,
) {
  final database = ref.watch(databaseProvider);
  final userId = ref.watch(authProvider.select((s) => s.userId));
  final selectedDate = ref.watch(selectedDateProvider);
  final coupleAsync = ref.watch(coupleProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final startOfDay = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final endOfDay = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    23,
    59,
    59,
  );

  final couple = coupleAsync.valueOrNull;
  if (couple != null && couple.isConnected) {
    return database.watchEventsByDateRangeCombined(
      userId,
      couple.id,
      startOfDay,
      endOfDay,
    );
  } else {
    return database.watchEventsByDateRange(userId, startOfDay, endOfDay);
  }
});

/// 현재 월의 모든 이벤트 Provider (커플/솔로 자동 분기)
final monthEventsProvider = StreamProvider.autoDispose<List<Event>>((ref) {
  final database = ref.watch(databaseProvider);
  // userId만 select (userName 변경 시 재평가 방지)
  final userId = ref.watch(authProvider.select((s) => s.userId));
  final focusedDate = ref.watch(focusedDateProvider);
  final coupleAsync = ref.watch(coupleProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final startOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
  final endOfMonth = DateTime(
    focusedDate.year,
    focusedDate.month + 1,
    0,
    23,
    59,
    59,
  );

  final couple = coupleAsync.valueOrNull;
  if (couple != null && couple.isConnected) {
    return database.watchEventsByDateRangeCombined(
      userId,
      couple.id,
      startOfMonth,
      endOfMonth,
    );
  } else {
    return database.watchEventsByDateRange(userId, startOfMonth, endOfMonth);
  }
});

/// 특정 날짜의 이벤트 개수 계산 헬퍼
Map<DateTime, List<Event>> getEventsMap(List<Event> events) {
  final Map<DateTime, List<Event>> eventsMap = {};

  for (final event in events) {
    final date = DateTime(event.date.year, event.date.month, event.date.day);

    if (eventsMap[date] == null) {
      eventsMap[date] = [];
    }
    eventsMap[date]!.add(event);
  }

  return eventsMap;
}

/// 이벤트 추가/수정/삭제 액션
///
/// 모든 변경은 Firebase에만 반영하고,
/// Drift 반영은 실시간 리스너(realtimeSyncProvider)가 담당한다.
class CalendarNotifier extends StateNotifier<AsyncValue<void>> {
  CalendarNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  /// 이벤트 추가 (Firebase에만 → 리스너가 Drift 반영)
  Future<void> addEvent({
    required String title,
    required DateTime date,
    String? description,
    Color color = Colors.blue,
    bool isAllDay = true,
    DateTime? startTime,
    DateTime? endTime,
    bool isCoupleEvent = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final authState = ref.read(authProvider);
      final couple = ref.read(coupleProvider).valueOrNull;
      final firebaseService = ref.read(firebaseServiceProvider);

      if (authState.userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 커플 일정 선택 + 실제 커플 연결됨 → coupleId 설정
      final coupleId = (isCoupleEvent && couple != null && couple.isConnected)
          ? couple.id
          : null;

      final now = DateTime.now();

      final fbEvent = FirebaseEvent(
        id: '',
        title: title,
        date: date,
        description: description,
        color: color,
        isAllDay: isAllDay,
        startTime: startTime,
        endTime: endTime,
        userId: authState.userId!,
        coupleId: coupleId,
        createdBy: authState.userId!,
        createdAt: now,
        updatedAt: now,
      );

      firebaseService.addEvent(fbEvent).catchError((e) {
        print('이벤트 업로드 실패 (백그라운드): $e');
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 이벤트 수정 (Firebase에만 → 리스너가 Drift 반영)
  Future<void> updateEvent({
    required int id,
    required String title,
    required DateTime date,
    String? description,
    required Color color,
    required bool isAllDay,
    DateTime? startTime,
    DateTime? endTime,
    bool isCoupleEvent = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final database = ref.read(databaseProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      final couple = ref.read(coupleProvider).valueOrNull;

      final existing = await database.getEvent(id);
      if (existing == null) {
        throw Exception('이벤트를 찾을 수 없습니다');
      }
      if (existing.firebaseId == null) {
        throw Exception('아직 동기화되지 않은 이벤트입니다');
      }

      final coupleId = (isCoupleEvent && couple != null && couple.isConnected)
          ? couple.id
          : null;

      final fbEvent = FirebaseEvent(
        id: existing.firebaseId!,
        title: title,
        date: date,
        description: description,
        color: color,
        isAllDay: isAllDay,
        startTime: startTime,
        endTime: endTime,
        userId: existing.userId,
        coupleId: coupleId,
        createdBy: existing.createdBy,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      firebaseService.updateEvent(existing.firebaseId!, fbEvent).catchError((
        e,
      ) {
        print('이벤트 수정 실패 (백그라운드): $e');
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 이벤트 삭제 (Firebase에만 → 리스너가 Drift 반영)
  Future<void> deleteEvent(int eventId) async {
    state = const AsyncValue.loading();
    try {
      final database = ref.read(databaseProvider);
      final firebaseService = ref.read(firebaseServiceProvider);

      final event = await database.getEvent(eventId);

      if (event?.firebaseId != null) {
        // Firebase에서 삭제 → 리스너가 Drift에서도 삭제
        firebaseService.deleteEvent(event!.firebaseId!).catchError((e) {
          print('이벤트 삭제 실패 (백그라운드): $e');
        });
      } else {
        // 아직 업로드 안 된 로컬 전용 → Drift에서 직접 삭제
        await database.deleteEvent(eventId);
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final calendarNotifierProvider =
    StateNotifierProvider<CalendarNotifier, AsyncValue<void>>((ref) {
      return CalendarNotifier(ref);
    });
