import 'package:coupley/features/couple/models/anniversary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2025, 9, 20); // 사귄 날 = 1일째

  group('자동 기념일', () {
    test('100일은 사귄 날 + 99일이다', () {
      final list = anniversariesBetween(
        startDate: start,
        from: DateTime(2025, 12, 1),
        to: DateTime(2025, 12, 31),
      );
      expect(list.map((a) => a.title), ['100일']);
      expect(list.single.date, DateTime(2025, 12, 28));
    });

    test('범위 중간부터 세도 100일 단위를 놓치지 않는다', () {
      final list = anniversariesBetween(
        startDate: start,
        from: DateTime(2026, 4, 1),
        to: DateTime(2026, 10, 31),
      );
      expect(list.map((a) => a.title), ['200일', '300일', '1주년', '400일']);
      expect(list[2].date, DateTime(2026, 9, 20));
    });

    test('사귄 날 이전 범위에는 아무것도 없다', () {
      expect(
        anniversariesBetween(
          startDate: start,
          from: DateTime(2025, 1, 1),
          to: DateTime(2025, 9, 19),
        ),
        isEmpty,
      );
    });

    test('2월 29일에 사귀었으면 평년 주년은 2월 28일이다', () {
      final list = anniversariesBetween(
        startDate: DateTime(2024, 2, 29),
        from: DateTime(2025, 2, 1),
        to: DateTime(2025, 3, 31),
      );
      expect(list.where((a) => a.title == '1주년').single.date,
          DateTime(2025, 2, 28));
    });
  });

  group('직접 추가한 기념일', () {
    final birthday = Anniversary(
      id: 'b',
      title: '준호 생일',
      date: DateTime(1998, 3, 2),
      icon: AnniversaryIcon.cake,
    );
    final trip = Anniversary(
      id: 't',
      title: '제주 여행',
      date: DateTime(2028, 5, 1),
      yearly: false,
    );

    test('매년 반복은 해마다 나온다', () {
      final list = anniversariesBetween(
        custom: [birthday],
        from: DateTime(2026, 1, 1),
        to: DateTime(2027, 12, 31),
      );
      expect(list.map((a) => a.date), [
        DateTime(2026, 3, 2),
        DateTime(2027, 3, 2),
      ]);
      expect(list.first.source, birthday);
    });

    test('한 번뿐인 기념일은 1년 넘게 남아도 다가오는 목록에 나온다', () {
      final list = upcomingAnniversaries(
        custom: [birthday, trip],
        today: DateTime(2026, 11, 12),
      );
      expect(list.map((a) => a.title), ['준호 생일', '제주 여행']);
    });

    test('다가오는 목록은 오늘을 포함하고 날짜순이다', () {
      final list = upcomingAnniversaries(
        startDate: start,
        custom: [birthday],
        today: DateTime(2026, 3, 2),
      );
      expect(list.first.title, '준호 생일');
      expect(daysUntil(DateTime(2026, 3, 2, 22), list.first.date), 0);
      expect(dDayLabel(0), 'D-day');
      final dates = list.map((a) => a.date).toList();
      expect(dates, [...dates]..sort());
    });
  });

  test('저장 형식을 오가도 값이 같다', () {
    final a = Anniversary(
      id: 'x',
      title: '첫 만남',
      date: DateTime(2025, 8, 15),
      yearly: false,
      icon: AnniversaryIcon.star,
    );
    final b = Anniversary.fromMap(a.toMap());
    expect(
      [b.id, b.title, b.date, b.yearly, b.icon],
      [a.id, a.title, a.date, a.yearly, a.icon],
    );
  });
}
