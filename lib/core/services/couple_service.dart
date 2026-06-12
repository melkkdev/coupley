import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/couple/models/couple.dart';
import '../../features/couple/invite_code_generator.dart';

/// 커플 연결 Firestore 서비스
class CoupleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _couplesRef =>
      _firestore.collection('couples');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _firestore.collection('events');

  /// 초대 코드 생성 (커플 문서 생성, status: pending)
  Future<Couple> createInvite(String userId) async {
    // 중복되지 않는 코드 생성 (최대 5회 시도)
    String code = '';
    for (int i = 0; i < 5; i++) {
      code = InviteCodeGenerator.generate();
      final existing = await _findByInviteCode(code);
      if (existing == null) break;
    }

    final now = DateTime.now();
    final couple = Couple(
      id: '', // Firestore가 생성
      members: [userId], // 처음엔 나만
      inviteCode: code,
      status: CoupleStatus.pending,
      createdBy: userId,
      createdAt: now,
    );

    final docRef = await _couplesRef.add(couple.toMap());

    // 내 프로필에 coupleId 연결
    await _usersRef.doc(userId).update({'coupleId': docRef.id});

    return Couple(
      id: docRef.id,
      members: couple.members,
      inviteCode: couple.inviteCode,
      status: couple.status,
      createdBy: couple.createdBy,
      createdAt: couple.createdAt,
    );
  }

  /// 초대 코드로 합류 (상대가 코드 입력 시)
  Future<Couple> joinByCode(String userId, String inviteCode) async {
    final couple = await _findByInviteCode(inviteCode.toUpperCase());

    if (couple == null) {
      throw Exception('유효하지 않은 초대 코드입니다');
    }

    if (couple.isConnected) {
      throw Exception('이미 연결된 커플입니다');
    }

    if (couple.members.contains(userId)) {
      throw Exception('본인이 만든 코드입니다');
    }

    // 커플 문서 업데이트: 멤버 추가 + 연결 완료
    final updatedMembers = [...couple.members, userId];
    await _couplesRef.doc(couple.id).update({
      'members': updatedMembers,
      'status': CoupleStatus.connected.value,
      'connectedAt': Timestamp.fromDate(DateTime.now()),
    });

    // 합류한 사람 프로필에 coupleId 연결
    await _usersRef.doc(userId).update({'coupleId': couple.id});

    return Couple(
      id: couple.id,
      members: updatedMembers,
      inviteCode: couple.inviteCode,
      status: CoupleStatus.connected,
      createdBy: couple.createdBy,
      createdAt: couple.createdAt,
      connectedAt: DateTime.now(),
    );
  }

  /// 커플 정보 가져오기
  Future<Couple?> getCouple(String coupleId) async {
    final doc = await _couplesRef.doc(coupleId).get();
    if (doc.exists) {
      return Couple.fromFirestore(doc);
    }
    return null;
  }

  /// 커플 정보 실시간 스트림
  Stream<Couple?> getCoupleStream(String coupleId) {
    return _couplesRef.doc(coupleId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Couple.fromFirestore(snapshot);
      }
      return null;
    });
  }

  /// 커플 연결 해제
  /// 1. 커플 일정 삭제 (아직 멤버일 때 = 권한 있음)
  /// 2. 내 coupleId 제거
  /// 3. couples 문서 삭제
  Future<void> disconnect(String coupleId, String myUserId) async {
    // couples 문서가 이미 삭제됐는지 확인
    final coupleDoc = await _couplesRef.doc(coupleId).get();

    if (coupleDoc.exists) {
      // 1. 커플 일정 삭제 (아직 있을 때만)
      final coupleEvents = await _eventsRef
          .where('coupleId', isEqualTo: coupleId)
          .get();

      for (final doc in coupleEvents.docs) {
        await doc.reference.delete();
      }

      // 2. couples 문서 삭제
      await _couplesRef.doc(coupleId).delete();
    }

    // 3. 내 coupleId는 항상 정리 (이미 null이어도 무해)
    await _usersRef.doc(myUserId).update({'coupleId': null});
  }

  /// 내 coupleId 정리 (상대가 해제했을 때 자동 호출용)
  Future<void> clearMyCoupleId(String myUserId) async {
    await _usersRef.doc(myUserId).update({'coupleId': null});
  }

  /// 초대 코드로 커플 찾기 (내부용)
  Future<Couple?> _findByInviteCode(String code) async {
    final snapshot = await _couplesRef
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Couple.fromFirestore(snapshot.docs.first);
  }
}
