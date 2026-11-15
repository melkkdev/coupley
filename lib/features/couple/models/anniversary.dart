/// 기념일 아이콘 종류
enum AnniversaryIcon {
  heart('heart'),
  cake('cake'),
  star('star');

  const AnniversaryIcon(this.value);
  final String value;

  static AnniversaryIcon fromString(String? value) {
    return AnniversaryIcon.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnniversaryIcon.heart,
    );
  }
}

/// 기념일 카드 색
enum AnniversaryColor {
  coral('coral', '코랄'),
  pink('pink', '핑크'),
  mint('mint', '민트');

  const AnniversaryColor(this.value, this.label);
  final String value;
  final String label;

  /// 예전에 저장돼 색 값이 없는 기념일은 코랄로 읽는다
  static AnniversaryColor fromString(String? value) {
    return AnniversaryColor.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnniversaryColor.coral,
    );
  }
}

/// 커플이 직접 추가한 기념일 (생일, 첫 만남 등)
///
/// couples 문서의 `anniversaries` 배열에 저장한다. 하위 컬렉션을 쓰지 않아
/// 기존 couples 보안 규칙만으로 두 사람 모두 읽고 쓸 수 있다.
class Anniversary {
  final String id;
  final String title;
  final DateTime date;

  /// true면 매년 같은 날 반복 (생일처럼)
  final bool yearly;
  final AnniversaryIcon icon;
  final AnniversaryColor color;

  /// 메모 (최대 80자, 없으면 null)
  final String? memo;

  const Anniversary({
    required this.id,
    required this.title,
    required this.date,
    this.yearly = true,
    this.icon = AnniversaryIcon.heart,
    this.color = AnniversaryColor.coral,
    this.memo,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    // 시간대와 무관하게 날짜만 저장한다
    'date': dateKey(date),
    'yearly': yearly,
    'icon': icon.value,
    'color': color.value,
    if (memo != null) 'memo': memo,
  };

  factory Anniversary.fromMap(Map<String, dynamic> map) {
    return Anniversary(
      id: map['id'] as String,
      title: map['title'] as String,
      date: parseDateKey(map['date'] as String),
      yearly: map['yearly'] as bool? ?? true,
      icon: AnniversaryIcon.fromString(map['icon'] as String?),
      color: AnniversaryColor.fromString(map['color'] as String?),
      memo: map['memo'] as String?,
    );
  }
}

/// 특정 날짜에 돌아오는 기념일 한 건
class AnniversaryOccurrence {
  final String title;
  final DateTime date;
  final AnniversaryIcon icon;

  /// 자동 기념일은 코랄
  AnniversaryColor get color => source?.color ?? AnniversaryColor.coral;

  /// 직접 추가한 기념일이면 원본, 사귄 날 기준 자동 기념일이면 null
  final Anniversary? source;

  const AnniversaryOccurrence({
    required this.title,
    required this.date,
    required this.icon,
    this.source,
  });

  bool get isAuto => source == null;
}

/// 'yyyy-MM-dd'
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// [from]부터 [to]까지 남은 날수. 같은 날이면 0.
int daysUntil(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// D-day 표기: 오늘이면 'D-day', 남았으면 'D-12', 지났으면 'D+3'
String dDayLabel(int daysLeft) => daysLeft == 0
    ? 'D-day'
    : daysLeft > 0
    ? 'D-$daysLeft'
    : 'D+${-daysLeft}';

/// 남은 날 문구: '오늘이에요', '12일 남음', '3일 지남'
String daysLeftLabel(int daysLeft) => daysLeft == 0
    ? '오늘이에요'
    : daysLeft > 0
    ? '$daysLeft일 남음'
    : '${-daysLeft}일 지남';

/// 함께한 날수. 시작한 날을 1일째로 센다. 시각은 무시하고 날짜만 비교한다.
int daysTogether(DateTime since, DateTime now) => daysUntil(since, now) + 1;

/// 이미 지나간 한 번뿐인 기념일 (최근 것부터)
List<AnniversaryOccurrence> pastOneTimeAnniversaries({
  List<Anniversary> custom = const [],
  required DateTime today,
}) {
  final from = _day(today);
  final list = [
    for (final a in custom)
      if (!a.yearly && _day(a.date).isBefore(from))
        AnniversaryOccurrence(
          title: a.title,
          date: _day(a.date),
          icon: a.icon,
          source: a,
        ),
  ];
  list.sort((a, b) => b.date.compareTo(a.date));
  return list;
}

/// [base]의 월/일을 [year]에 맞춘다. 2월 29일은 평년에 2월 28일로 옮긴다.
DateTime _sameDayIn(DateTime base, int year) {
  final lastDay = DateTime(year, base.month + 1, 0).day;
  return DateTime(year, base.month, base.day > lastDay ? lastDay : base.day);
}

/// [from]~[to] 사이(양 끝 포함)에 돌아오는 기념일을 날짜순으로 돌려준다.
///
/// - 사귄 날([startDate])이 있으면 100일 단위(100일, 200일 …)와 N주년을 자동으로 넣는다.
///   사귄 날을 1일째로 세므로 100일은 사귄 날 + 99일이다.
/// - 직접 추가한 기념일은 매년 반복이면 해마다, 아니면 그 날짜 하루만 넣는다.
List<AnniversaryOccurrence> anniversariesBetween({
  DateTime? startDate,
  List<Anniversary> custom = const [],
  required DateTime from,
  required DateTime to,
}) {
  final start = _day(from);
  final end = _day(to);
  bool inRange(DateTime d) => !d.isBefore(start) && !d.isAfter(end);

  final result = <AnniversaryOccurrence>[];

  if (startDate != null) {
    final base = _day(startDate);

    // 100일 단위: 범위 시작 이후 첫 배수부터
    final elapsed = daysUntil(base, start) + 1; // 범위 시작일이 며칠째인지
    var n = elapsed <= 100 ? 1 : (elapsed + 99) ~/ 100;
    while (true) {
      final d = DateTime(base.year, base.month, base.day + n * 100 - 1);
      if (d.isAfter(end)) break;
      if (inRange(d)) {
        result.add(
          AnniversaryOccurrence(
            title: '${n * 100}일',
            date: d,
            icon: AnniversaryIcon.heart,
          ),
        );
      }
      n++;
    }

    // N주년
    for (var y = start.year; y <= end.year; y++) {
      final years = y - base.year;
      if (years < 1) continue;
      final d = _sameDayIn(base, y);
      if (inRange(d)) {
        result.add(
          AnniversaryOccurrence(
            title: '$years주년',
            date: d,
            icon: AnniversaryIcon.star,
          ),
        );
      }
    }
  }

  for (final a in custom) {
    if (a.yearly) {
      for (var y = start.year; y <= end.year; y++) {
        final d = _sameDayIn(a.date, y);
        if (inRange(d) && !d.isBefore(_day(a.date))) {
          result.add(
            AnniversaryOccurrence(
              title: a.title,
              date: d,
              icon: a.icon,
              source: a,
            ),
          );
        }
      }
    } else if (inRange(_day(a.date))) {
      result.add(
        AnniversaryOccurrence(
          title: a.title,
          date: _day(a.date),
          icon: a.icon,
          source: a,
        ),
      );
    }
  }

  result.sort((a, b) => a.date.compareTo(b.date));
  return result;
}

/// 오늘부터 다가오는 기념일 목록.
///
/// 자동 기념일과 매년 반복 기념일은 1년 안의 것만, 한 번뿐인 기념일은
/// 아직 지나지 않았으면 날짜와 상관없이 넣는다.
List<AnniversaryOccurrence> upcomingAnniversaries({
  DateTime? startDate,
  List<Anniversary> custom = const [],
  required DateTime today,
}) {
  final from = _day(today);
  final to = DateTime(from.year + 1, from.month, from.day - 1);
  final list = anniversariesBetween(
    startDate: startDate,
    custom: custom,
    from: from,
    to: to,
  );
  for (final a in custom) {
    if (!a.yearly && _day(a.date).isAfter(to)) {
      list.add(
        AnniversaryOccurrence(
          title: a.title,
          date: _day(a.date),
          icon: a.icon,
          source: a,
        ),
      );
    }
  }
  list.sort((a, b) => a.date.compareTo(b.date));
  return list;
}
