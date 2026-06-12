import 'dart:math';

/// 랜덤 닉네임 생성기 (형용사 + 명사 + 숫자)
class NicknameGenerator {
  static const List<String> _adjectives = [
    '행복한',
    '용감한',
    '즐거운',
    '따뜻한',
    '멋진',
    '귀여운',
    '신나는',
    '엉뚱한',
    '느긋한',
    '반짝이는',
    '활발한',
    '차분한',
    '씩씩한',
    '상냥한',
    '재빠른',
    '포근한',
    '명랑한',
    '깜찍한',
    '훈훈한',
    '발랄한',
  ];

  static const List<String> _nouns = [
    '판다',
    '토끼',
    '고양이',
    '강아지',
    '곰',
    '여우',
    '너구리',
    '다람쥐',
    '햄스터',
    '펭귄',
    '코알라',
    '사자',
    '호랑이',
    '수달',
    '고슴도치',
    '알파카',
    '병아리',
    '오리',
    '돌고래',
    '꿀벌',
  ];

  /// 랜덤 닉네임 생성 (예: "행복한판다482")
  static String generate() {
    final random = Random();
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    final noun = _nouns[random.nextInt(_nouns.length)];
    final number = random.nextInt(1000);

    return '$adjective$noun$number';
  }
}
