import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Firebase 이벤트 모델
class FirebaseEvent {
  final String id;
  final String title;
  final DateTime date;
  final String? description;
  final Color color;
  final bool isAllDay;
  final DateTime? startTime;
  final DateTime? endTime;
  final String userId;
  final String? coupleId;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirebaseEvent({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    required this.color,
    required this.isAllDay,
    this.startTime,
    this.endTime,
    required this.userId,
    this.coupleId,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'description': description,
      'color': '#${color.value.toRadixString(16).padLeft(8, '0')}',
      'isAllDay': isAllDay,
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'userId': userId,
      'coupleId': coupleId, // ← 추가
      'createdBy': createdBy, // ← 추가
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory FirebaseEvent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return FirebaseEvent(
      id: snapshot.id,
      title: data['title'] as String,
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] as String?,
      color: Color(int.parse(data['color'].substring(1), radix: 16)),
      isAllDay: data['isAllDay'] as bool? ?? true,
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      userId: data['userId'] as String,
      coupleId: data['coupleId'] as String?, // ← 추가
      createdBy: data['createdBy'] as String?, // ← 추가
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

/// Firebase 커플 정보 모델
class FirebaseCoupleInfo {
  final String userId;
  final String userName;
  final String? partnerName;
  final String? photoUrl;
  final Color themeColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirebaseCoupleInfo({
    required this.userId,
    required this.userName,
    this.partnerName,
    this.photoUrl,
    required this.themeColor,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'partnerName': partnerName,
      'photoUrl': photoUrl,
      'themeColor': '#${themeColor.value.toRadixString(16).padLeft(8, '0')}',
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory FirebaseCoupleInfo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return FirebaseCoupleInfo(
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      partnerName: data['partnerName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      themeColor: Color(int.parse(data['themeColor'].substring(1), radix: 16)),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

/// Firebase Service
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _firestore.collection('events');

  CollectionReference<Map<String, dynamic>> get _coupleInfoRef =>
      _firestore.collection('coupleInfo');

  // ==================== Events ====================
  /// 첫 동기화: 최근 N개월 이벤트 가져오기 (1회성)
  Future<List<FirebaseEvent>> getInitialEvents(
    String userId, {
    int monthsBack = 3,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(days: 30 * monthsBack));

    final snapshot = await _eventsRef
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .get();

    return snapshot.docs
        .map((doc) => FirebaseEvent.fromFirestore(doc))
        .toList();
  }

  /// 커플의 첫 동기화: 최근 N개월 이벤트 (coupleId 기준)
  Future<List<FirebaseEvent>> getInitialEventsForCouple(
    String coupleId, {
    int monthsBack = 3,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(days: 30 * monthsBack));

    final snapshot = await _eventsRef
        .where('coupleId', isEqualTo: coupleId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .get();

    return snapshot.docs
        .map((doc) => FirebaseEvent.fromFirestore(doc))
        .toList();
  }

  /// 커플의 증분 동기화: 특정 시각 이후 변경분 (coupleId 기준)
  Future<List<FirebaseEvent>> getEventsSinceForCouple(
    String coupleId,
    DateTime since,
  ) async {
    final snapshot = await _eventsRef
        .where('coupleId', isEqualTo: coupleId)
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(since))
        .get();

    return snapshot.docs
        .map((doc) => FirebaseEvent.fromFirestore(doc))
        .toList();
  }

  /// 커플의 모든 이벤트 실시간 스트림 (coupleId 기준)
  Stream<List<FirebaseEvent>> getCoupleEventsStream(String coupleId) {
    return _eventsRef
        .where('coupleId', isEqualTo: coupleId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FirebaseEvent.fromFirestore(doc))
              .toList(),
        );
  }

  /// 내 개인 일정 실시간 스트림 (coupleId == null인 내 일정)
  Stream<List<FirebaseEvent>> getPersonalEventsStream(String userId) {
    return _eventsRef
        .where('userId', isEqualTo: userId)
        .where('coupleId', isEqualTo: null)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FirebaseEvent.fromFirestore(doc))
              .toList(),
        );
  }

  /// 증분 동기화: 특정 시각 이후 변경된 이벤트만 가져오기
  Future<List<FirebaseEvent>> getEventsSince(
    String userId,
    DateTime since,
  ) async {
    final snapshot = await _eventsRef
        .where('userId', isEqualTo: userId)
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(since))
        .get();

    return snapshot.docs
        .map((doc) => FirebaseEvent.fromFirestore(doc))
        .toList();
  }

  /// 모든 이벤트 스트림
  Stream<List<FirebaseEvent>> getEventsStream(String userId) {
    return _eventsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FirebaseEvent.fromFirestore(doc))
              .toList(),
        );
  }

  /// 월별 이벤트 스트림
  Stream<List<FirebaseEvent>> getMonthEventsStream(
    String userId,
    DateTime month,
  ) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _eventsRef
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FirebaseEvent.fromFirestore(doc))
              .toList(),
        );
  }

  /// 날짜 범위 이벤트 스트림
  Stream<List<FirebaseEvent>> getDateRangeEventsStream(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return _eventsRef
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FirebaseEvent.fromFirestore(doc))
              .toList(),
        );
  }

  /// 이벤트 추가
  Future<String> addEvent(FirebaseEvent event) async {
    final doc = await _eventsRef.add(event.toMap());
    return doc.id;
  }

  /// 이벤트 수정
  Future<void> updateEvent(String id, FirebaseEvent event) async {
    await _eventsRef.doc(id).update(event.toMap());
  }

  /// 이벤트 삭제
  Future<void> deleteEvent(String id) async {
    await _eventsRef.doc(id).delete();
  }

  // ==================== CoupleInfo ====================

  /// 커플 정보 가져오기
  Future<FirebaseCoupleInfo?> getCoupleInfo(String userId) async {
    final doc = await _coupleInfoRef.doc(userId).get();
    if (doc.exists) {
      return FirebaseCoupleInfo.fromFirestore(doc);
    }
    return null;
  }

  /// 커플 정보 스트림
  Stream<FirebaseCoupleInfo?> getCoupleInfoStream(String userId) {
    return _coupleInfoRef.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return FirebaseCoupleInfo.fromFirestore(snapshot);
      }
      return null;
    });
  }

  /// 커플 정보 저장/수정
  Future<void> saveCoupleInfo(FirebaseCoupleInfo info) async {
    await _coupleInfoRef.doc(info.userId).set(info.toMap());
  }
}
