import 'dart:math';

/// 초대 코드 생성기
class InviteCodeGenerator {
  // 헷갈리는 문자 제외: 0, O, 1, I, L 제외
  static const String _chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int _length = 6;

  /// 6자리 랜덤 초대 코드 생성 (예: A7K2P9)
  static String generate() {
    final random = Random.secure();
    return List.generate(
      _length,
      (_) => _chars[random.nextInt(_chars.length)],
    ).join();
  }
}
