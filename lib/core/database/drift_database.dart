import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'drift_database.g.dart';

/// 이벤트 테이블
class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseId => text().nullable().unique()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().nullable()();
  TextColumn get color => text().withDefault(const Constant('#FF2196F3'))();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(true))();
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get userId => text()();
  TextColumn get coupleId => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 커플 정보 테이블
class CoupleInfo extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().unique()();
  TextColumn get userName => text()();
  TextColumn get partnerName => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get themeColor =>
      text().withDefault(const Constant('#FFE91E63'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Drift Database
@DriftDatabase(tables: [Events, CoupleInfo])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(events, events.firebaseId);
      }
      if (from < 3) {
        await m.addColumn(events, events.coupleId);
        await m.addColumn(events, events.createdBy);
      }
      // from < 4 (firebaseId unique)는 앱 재설치로 처리
    },
  );

  // ==================== Events CRUD ====================

  /// 모든 이벤트 가져오기
  Future<List<Event>> getAllEvents(String userId) {
    return (select(events)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
  }

  /// 특정 이벤트 가져오기
  Future<Event?> getEvent(int id) {
    return (select(
      events,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// firebaseId로 이벤트 찾기
  Future<Event?> getEventByFirebaseId(String firebaseId) {
    return (select(
      events,
    )..where((tbl) => tbl.firebaseId.equals(firebaseId))).getSingleOrNull();
  }

  /// 날짜 범위로 이벤트 조회 (userId 기준 - 솔로용)
  Stream<List<Event>> watchEventsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return (select(events)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBiggerOrEqualValue(start) &
                tbl.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .watch();
  }

  /// 날짜 범위 조회 (커플 유저용: 내 개인 일정 + 커플 일정 합쳐서)
  Stream<List<Event>> watchEventsByDateRangeCombined(
    String userId,
    String coupleId,
    DateTime start,
    DateTime end,
  ) {
    return (select(events)
          ..where(
            (tbl) =>
                (tbl.coupleId.equals(coupleId) |
                    (tbl.userId.equals(userId) & tbl.coupleId.isNull())) &
                tbl.date.isBiggerOrEqualValue(start) &
                tbl.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .watch();
  }

  /// 날짜 범위로 이벤트 조회 (coupleId 기준 - 커플 공유용)
  Stream<List<Event>> watchEventsByDateRangeForCouple(
    String coupleId,
    DateTime start,
    DateTime end,
  ) {
    return (select(events)
          ..where(
            (tbl) =>
                tbl.coupleId.equals(coupleId) &
                tbl.date.isBiggerOrEqualValue(start) &
                tbl.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .watch();
  }

  /// 이벤트 추가
  Future<int> insertEvent(EventsCompanion event) {
    return into(events).insert(event);
  }

  /// 이벤트 수정
  Future<bool> updateEvent(EventsCompanion event) {
    return update(events).replace(event);
  }

  /// 이벤트 삭제
  Future<int> deleteEvent(int id) {
    return (delete(events)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// firebaseId 업데이트 (Firebase 업로드 후 ID 저장용)
  Future<void> updateEventFirebaseId(int localId, String firebaseId) {
    return (update(events)..where((tbl) => tbl.id.equals(localId))).write(
      EventsCompanion(firebaseId: Value(firebaseId)),
    );
  }

  /// Firebase에 없는 이벤트를 Drift에서 삭제 (실시간 동기화용)
  Future<void> deleteEventsNotInFirebase({
    required Set<String> firebaseIds,
    String? coupleId,
    required String userId,
  }) async {
    final query = select(events);
    if (coupleId != null) {
      query.where((tbl) => tbl.coupleId.equals(coupleId));
    } else {
      query.where((tbl) => tbl.userId.equals(userId) & tbl.coupleId.isNull());
    }
    final localEvents = await query.get();

    for (final local in localEvents) {
      if (local.firebaseId != null && !firebaseIds.contains(local.firebaseId)) {
        await (delete(events)..where((tbl) => tbl.id.equals(local.id))).go();
      }
    }
  }

  // ==================== CoupleInfo CRUD ====================

  /// 커플 정보 가져오기
  Future<CoupleInfoData?> getCoupleInfo(String userId) async {
    return await (select(
      coupleInfo,
    )..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
  }

  /// 커플 정보 실시간 스트림
  Stream<CoupleInfoData?> watchCoupleInfo(String userId) {
    return (select(
      coupleInfo,
    )..where((tbl) => tbl.userId.equals(userId))).watchSingleOrNull();
  }

  /// 커플 정보 저장/수정 (Upsert)
  Future<int> upsertCoupleInfo(CoupleInfoCompanion info) {
    return into(coupleInfo).insertOnConflictUpdate(info);
  }

  /// 커플 정보 삭제
  Future<int> deleteCoupleInfo(String userId) {
    return (delete(coupleInfo)..where((tbl) => tbl.userId.equals(userId))).go();
  }
}

/// 데이터베이스 연결 설정
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'couple_calendar.db'));
    return NativeDatabase(file);
  });
}
