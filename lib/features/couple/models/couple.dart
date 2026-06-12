import 'package:cloud_firestore/cloud_firestore.dart';

/// 커플 연결 상태
enum CoupleStatus {
  pending('pending'), // 초대 코드 생성됨, 상대 합류 대기중
  connected('connected'); // 두 사람 연결 완료

  const CoupleStatus(this.value);
  final String value;

  static CoupleStatus fromString(String value) {
    return CoupleStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CoupleStatus.pending,
    );
  }
}

/// 커플 모델
class Couple {
  final String id; // coupleId (Firestore 문서 ID)
  final List<String> members; // [userIdA, userIdB]
  final String inviteCode; // 초대 코드 (예: A7K2P9)
  final CoupleStatus status;
  final String createdBy; // 코드를 생성한 사람
  final DateTime createdAt;
  final DateTime? connectedAt; // 연결 완료 시각

  Couple({
    required this.id,
    required this.members,
    required this.inviteCode,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.connectedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'members': members,
      'inviteCode': inviteCode,
      'status': status.value,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'connectedAt': connectedAt != null
          ? Timestamp.fromDate(connectedAt!)
          : null,
    };
  }

  factory Couple.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return Couple(
      id: snapshot.id,
      members: List<String>.from(data['members'] as List),
      inviteCode: data['inviteCode'] as String,
      status: CoupleStatus.fromString(data['status'] as String),
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      connectedAt: data['connectedAt'] != null
          ? (data['connectedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// 상대방 userId 가져오기 (내 id를 빼고)
  String? getPartnerId(String myUserId) {
    final others = members.where((id) => id != myUserId).toList();
    return others.isEmpty ? null : others.first;
  }

  /// 연결 완료 여부
  bool get isConnected => status == CoupleStatus.connected;
}
