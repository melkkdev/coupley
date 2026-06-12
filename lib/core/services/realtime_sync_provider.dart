import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database_provider.dart';
import '../database/drift_database.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/couple/providers/couple_provider.dart';
import 'firebase_service.dart';
import 'sync_provider.dart';

/// 커플 일정 실시간 리스너
/// 커플 연결된 경우만 작동, coupleId 기준 구독
final realtimeCoupleSyncProvider = StreamProvider.autoDispose<void>((ref) {
  final authState = ref.watch(authProvider);
  final coupleAsync = ref.watch(coupleProvider);
  final firebaseService = ref.watch(firebaseServiceProvider);
  final database = ref.watch(databaseProvider);

  if (!authState.isAuthenticated || authState.userId == null) {
    return const Stream.empty();
  }

  final couple = coupleAsync.valueOrNull;
  if (couple == null || !couple.isConnected) {
    return const Stream.empty(); // 솔로면 커플 리스너 안 함
  }

  final coupleStream = firebaseService.getCoupleEventsStream(couple.id);

  return coupleStream.asyncMap((firebaseEvents) async {
    await _syncCoupleEvents(database, firebaseEvents, couple.id);
  });
});

/// 개인 일정 실시간 리스너
/// 항상 작동, coupleId == null인 내 일정 구독
final realtimePersonalSyncProvider = StreamProvider.autoDispose<void>((ref) {
  final authState = ref.watch(authProvider);
  final firebaseService = ref.watch(firebaseServiceProvider);
  final database = ref.watch(databaseProvider);

  if (!authState.isAuthenticated || authState.userId == null) {
    return const Stream.empty();
  }

  final userId = authState.userId!;
  final personalStream = firebaseService.getPersonalEventsStream(userId);

  return personalStream.asyncMap((firebaseEvents) async {
    await _syncPersonalEvents(database, firebaseEvents, userId);
  });
});

// ==================== 동기화 헬퍼 ====================

/// 커플 일정 동기화 (coupleId 범위 내에서 upsert + 삭제)
Future<void> _syncCoupleEvents(
  AppDatabase database,
  List<FirebaseEvent> firebaseEvents,
  String coupleId,
) async {
  final firebaseIds = <String>{};
  for (final fbEvent in firebaseEvents) {
    firebaseIds.add(fbEvent.id);
    await _upsertEvent(database, fbEvent);
  }

  // 커플 일정 중 Firebase에서 사라진 것 삭제
  await _deleteCoupleEventsNotIn(database, firebaseIds, coupleId);
}

/// 개인 일정 동기화 (내 개인 일정 범위 내에서 upsert + 삭제)
Future<void> _syncPersonalEvents(
  AppDatabase database,
  List<FirebaseEvent> firebaseEvents,
  String userId,
) async {
  final firebaseIds = <String>{};
  for (final fbEvent in firebaseEvents) {
    firebaseIds.add(fbEvent.id);
    await _upsertEvent(database, fbEvent);
  }

  // 내 개인 일정 중 Firebase에서 사라진 것 삭제
  await _deletePersonalEventsNotIn(database, firebaseIds, userId);
}

/// 이벤트 하나 upsert (firebaseId 기준)
Future<void> _upsertEvent(AppDatabase database, FirebaseEvent fbEvent) async {
  final companion = EventsCompanion(
    firebaseId: drift.Value(fbEvent.id),
    title: drift.Value(fbEvent.title),
    date: drift.Value(fbEvent.date),
    description: drift.Value(fbEvent.description),
    color: drift.Value(
      '#${fbEvent.color.value.toRadixString(16).padLeft(8, '0')}',
    ),
    isAllDay: drift.Value(fbEvent.isAllDay),
    startTime: drift.Value(fbEvent.startTime),
    endTime: drift.Value(fbEvent.endTime),
    userId: drift.Value(fbEvent.userId),
    coupleId: drift.Value(fbEvent.coupleId),
    createdBy: drift.Value(fbEvent.createdBy),
    createdAt: drift.Value(fbEvent.createdAt),
    updatedAt: drift.Value(fbEvent.updatedAt),
  );

  await database
      .into(database.events)
      .insert(
        companion,
        onConflict: DoUpdate(
          (old) => companion,
          target: [database.events.firebaseId],
        ),
      );
}

/// 커플 일정 중 Firebase에 없는 것 삭제
Future<void> _deleteCoupleEventsNotIn(
  AppDatabase database,
  Set<String> firebaseIds,
  String coupleId,
) async {
  final localEvents = await (database.select(
    database.events,
  )..where((tbl) => tbl.coupleId.equals(coupleId))).get();

  for (final local in localEvents) {
    if (local.firebaseId != null && !firebaseIds.contains(local.firebaseId)) {
      await (database.delete(
        database.events,
      )..where((tbl) => tbl.id.equals(local.id))).go();
    }
  }
}

/// 내 개인 일정 중 Firebase에 없는 것 삭제
Future<void> _deletePersonalEventsNotIn(
  AppDatabase database,
  Set<String> firebaseIds,
  String userId,
) async {
  final localEvents = await (database.select(
    database.events,
  )..where((tbl) => tbl.userId.equals(userId) & tbl.coupleId.isNull())).get();

  for (final local in localEvents) {
    if (local.firebaseId != null && !firebaseIds.contains(local.firebaseId)) {
      await (database.delete(
        database.events,
      )..where((tbl) => tbl.id.equals(local.id))).go();
    }
  }
}
