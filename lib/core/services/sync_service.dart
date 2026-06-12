import 'package:drift/drift.dart' as drift;
import '../database/drift_database.dart';
import 'firebase_service.dart';
import 'sync_storage.dart';
import 'package:flutter/material.dart';

/// Firebase와 Drift 간 동기화 서비스
class SyncService {
  final AppDatabase _database;
  final FirebaseService _firebaseService;

  SyncService(this._database, this._firebaseService);

  // ==================== 스마트 동기화 (증분) ====================

  /// 스마트 동기화 (커플/솔로 분기, 첫 실행=전체, 이후=변경분만)
  Future<void> smartSyncEvents(String userId, {String? coupleId}) async {
    // 동기화 키: 커플이면 coupleId, 솔로면 userId
    final syncKey = coupleId ?? userId;
    final lastSyncedAt = await SyncStorage.getLastSyncedAt(syncKey);

    final List<FirebaseEvent> events;

    if (coupleId != null) {
      // 커플: coupleId 기준
      if (lastSyncedAt == null) {
        events = await _firebaseService.getInitialEventsForCouple(
          coupleId,
          monthsBack: 3,
        );
        print('🔄 커플 첫 동기화: ${events.length}개 로드');
      } else {
        events = await _firebaseService.getEventsSinceForCouple(
          coupleId,
          lastSyncedAt,
        );
        print('🔄 커플 증분 동기화: ${events.length}개 변경분');
      }
    } else {
      // 솔로: userId 기준
      if (lastSyncedAt == null) {
        events = await _firebaseService.getInitialEvents(userId, monthsBack: 3);
        print('🔄 솔로 첫 동기화: ${events.length}개 로드');
      } else {
        events = await _firebaseService.getEventsSince(userId, lastSyncedAt);
        print('🔄 솔로 증분 동기화: ${events.length}개 변경분');
      }
    }

    // Drift에 머지
    for (final fbEvent in events) {
      await _mergeEvent(fbEvent);
    }

    // 동기화 시각 갱신
    await SyncStorage.setLastSyncedAt(syncKey, DateTime.now());
  }

  /// 개별 이벤트 머지 (firebaseId로 중복 체크)
  Future<void> _mergeEvent(FirebaseEvent fbEvent) async {
    final existing = await _database.getEventByFirebaseId(fbEvent.id);

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

    if (existing == null) {
      await _database.into(_database.events).insert(companion);
    } else {
      if (fbEvent.updatedAt.isAfter(existing.updatedAt)) {
        await (_database.update(
          _database.events,
        )..where((tbl) => tbl.firebaseId.equals(fbEvent.id))).write(companion);
      }
    }
  }

  // ==================== Drift → Firebase (업로드) ====================

  /// Drift → Firebase: 이벤트 업로드 (문서 ID 반환)
  Future<String> uploadEventToFirebase(Event event) async {
    final fbEvent = FirebaseEvent(
      id: '',
      title: event.title,
      date: event.date,
      description: event.description,
      color: Color(int.parse(event.color.substring(1), radix: 16)),
      isAllDay: event.isAllDay,
      startTime: event.startTime,
      endTime: event.endTime,
      userId: event.userId,
      coupleId: event.coupleId,
      createdBy: event.createdBy,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    );

    return await _firebaseService.addEvent(fbEvent);
  }

  /// Drift → Firebase: 이벤트 수정
  Future<void> updateEventInFirebase(Event event) async {
    if (event.firebaseId == null) return;

    final fbEvent = FirebaseEvent(
      id: event.firebaseId!,
      title: event.title,
      date: event.date,
      description: event.description,
      color: Color(int.parse(event.color.substring(1), radix: 16)),
      isAllDay: event.isAllDay,
      startTime: event.startTime,
      endTime: event.endTime,
      userId: event.userId,
      coupleId: event.coupleId,
      createdBy: event.createdBy,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    );

    await _firebaseService.updateEvent(event.firebaseId!, fbEvent);
  }

  /// Drift → Firebase: 이벤트 삭제
  Future<void> deleteEventFromFirebase(String firebaseId) async {
    await _firebaseService.deleteEvent(firebaseId);
  }

  /// Drift → Firebase: 커플 정보 업로드
  Future<void> uploadCoupleInfoToFirebase(CoupleInfoData coupleInfo) async {
    final fbCoupleInfo = FirebaseCoupleInfo(
      userId: coupleInfo.userId,
      userName: coupleInfo.userName,
      partnerName: coupleInfo.partnerName,
      photoUrl: coupleInfo.photoUrl,
      themeColor: Color(
        int.parse(coupleInfo.themeColor.substring(1), radix: 16),
      ),
      createdAt: coupleInfo.createdAt,
      updatedAt: coupleInfo.updatedAt,
    );

    await _firebaseService.saveCoupleInfo(fbCoupleInfo);
  }

  // ==================== 커플 정보 동기화 ====================

  /// Firebase → Drift: 커플 정보 동기화
  Future<void> syncCoupleInfoFromFirebase(String userId) async {
    final fbCoupleInfo = await _firebaseService.getCoupleInfo(userId);

    if (fbCoupleInfo != null) {
      await _database.upsertCoupleInfo(
        CoupleInfoCompanion(
          userId: drift.Value(fbCoupleInfo.userId),
          userName: drift.Value(fbCoupleInfo.userName),
          partnerName: drift.Value(fbCoupleInfo.partnerName),
          photoUrl: drift.Value(fbCoupleInfo.photoUrl),
          themeColor: drift.Value(
            '#${fbCoupleInfo.themeColor.value.toRadixString(16).padLeft(8, '0')}',
          ),
          createdAt: drift.Value(fbCoupleInfo.createdAt),
          updatedAt: drift.Value(fbCoupleInfo.updatedAt),
        ),
      );
    }
  }

  /// 전체 동기화 (이벤트 + 커플 정보)
  Future<void> syncAll(String userId, {String? coupleId}) async {
    await Future.wait([
      smartSyncEvents(userId, coupleId: coupleId),
      syncCoupleInfoFromFirebase(userId),
    ]);
  }
}
