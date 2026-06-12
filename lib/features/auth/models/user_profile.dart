import 'package:cloud_firestore/cloud_firestore.dart';

/// 유저 프로필 모델
///
/// 확장 포인트:
/// - phoneNumber: Phase 4에서 Phone Auth로 채움
/// - fcmToken: Phase 4에서 FCM 도입 시 채움
class UserProfile {
  final String userId;
  final String userName;
  final String? email;
  final String? photoUrl;
  final String? phoneNumber; // TODO: Phase 4 - Phone Auth
  final String? fcmToken; // TODO: Phase 4 - FCM Push
  final String? coupleId; // 연결되면 채워짐
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    required this.userName,
    this.email,
    this.photoUrl,
    this.phoneNumber,
    this.fcmToken,
    this.coupleId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'fcmToken': fcmToken,
      'coupleId': coupleId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return UserProfile(
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      fcmToken: data['fcmToken'] as String?,
      coupleId: data['coupleId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// 일부 필드만 업데이트할 때 사용
  UserProfile copyWith({
    String? userName,
    String? email,
    String? photoUrl,
    String? phoneNumber,
    String? fcmToken,
    String? coupleId,
  }) {
    return UserProfile(
      userId: userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      coupleId: coupleId ?? this.coupleId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
