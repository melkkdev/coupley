import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/models/user_profile.dart';

/// 유저 프로필 Firestore 서비스
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// 유저 프로필 가져오기
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (doc.exists) {
      return UserProfile.fromFirestore(doc);
    }
    return null;
  }

  /// 유저 프로필 스트림 (실시간)
  Stream<UserProfile?> getUserProfileStream(String userId) {
    return _usersRef.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromFirestore(snapshot);
      }
      return null;
    });
  }

  /// 로그인 시 프로필 생성 (없으면 생성, 있으면 정보 업데이트)
  Future<UserProfile> createOrUpdateProfile({
    required String userId,
    required String userName,
    String? email,
    String? photoUrl,
  }) async {
    final existing = await getUserProfile(userId);

    if (existing == null) {
      // 신규 유저 → 프로필 생성
      final now = DateTime.now();
      final profile = UserProfile(
        userId: userId,
        userName: userName,
        email: email,
        photoUrl: photoUrl,
        phoneNumber: null, // Phase 4
        fcmToken: null, // Phase 4
        coupleId: null,
        createdAt: now,
        updatedAt: now,
      );
      await _usersRef.doc(userId).set(profile.toMap());
      return profile;
    } else {
      // 기존 유저 → 로그인 정보만 갱신 (이름/사진 변경 반영)
      final updated = existing.copyWith(
        userName: userName,
        email: email,
        photoUrl: photoUrl,
      );
      await _usersRef.doc(userId).update({
        'userName': updated.userName,
        'email': updated.email,
        'photoUrl': updated.photoUrl,
        'updatedAt': Timestamp.fromDate(updated.updatedAt),
      });
      return updated;
    }
  }

  /// coupleId 업데이트 (커플 연결 시 사용 - Phase 2)
  Future<void> updateCoupleId(String userId, String? coupleId) async {
    await _usersRef.doc(userId).update({
      'coupleId': coupleId,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// 닉네임(userName) 변경
  Future<void> updateUserName(String userId, String newName) async {
    await _usersRef.doc(userId).update({
      'userName': newName,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // TODO: Phase 4 - 전화번호로 유저 찾기
  // Future<UserProfile?> findUserByPhone(String phoneNumber) async {
  //   final snapshot = await _usersRef
  //       .where('phoneNumber', isEqualTo: phoneNumber)
  //       .limit(1)
  //       .get();
  //   if (snapshot.docs.isEmpty) return null;
  //   return UserProfile.fromFirestore(snapshot.docs.first);
  // }

  // TODO: Phase 4 - FCM 토큰 업데이트
  // Future<void> updateFcmToken(String userId, String token) async {
  //   await _usersRef.doc(userId).update({'fcmToken': token});
  // }
}
