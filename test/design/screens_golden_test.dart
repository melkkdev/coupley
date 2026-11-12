import 'dart:io';

import 'package:coupley/core/database/drift_database.dart';
import 'package:coupley/core/services/realtime_sync_provider.dart';
import 'package:coupley/core/theme/app_theme.dart';
import 'package:coupley/features/auth/models/auth_status.dart';
import 'package:coupley/features/auth/providers/auth_provider.dart';
import 'package:coupley/features/auth/widgets/login_page.dart';
import 'package:coupley/features/calendar/providers/calendar_provider.dart';
import 'package:coupley/features/calendar/widgets/calendar_home.dart';
import 'package:coupley/features/couple/models/anniversary.dart';
import 'package:coupley/features/couple/models/couple.dart';
import 'package:coupley/features/couple/providers/couple_provider.dart';
import 'package:coupley/features/couple/widgets/anniversary_page.dart';
import 'package:coupley/features/couple/widgets/couple_connect_page.dart';
import 'package:coupley/features/couple/widgets/dday_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 디자인 확인용 화면 렌더링 테스트.
/// `flutter test --update-goldens test/design` 으로 goldens/ 아래 PNG를 다시 만든다.
Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File(f).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

class _FakeAuth extends StateNotifier<AuthState> implements AuthNotifier {
  _FakeAuth()
    : super(
        const AuthState(
          isAuthenticated: true,
          userId: 'me',
          userName: '민지',
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Event _event(int id, String title, {String? coupleId, DateTime? start}) {
  final date = DateTime(2026, 11, 5);
  return Event(
    id: id,
    title: title,
    date: date,
    color: '#FF2196F3',
    isAllDay: start == null,
    startTime: start,
    userId: 'me',
    coupleId: coupleId,
    createdBy: 'me',
    createdAt: date,
    updatedAt: date,
  );
}

Couple _couple(CoupleStatus status) => Couple(
  id: 'c1',
  members: const ['me', 'you'],
  inviteCode: 'A7K2P9',
  status: status,
  createdBy: 'me',
  createdAt: DateTime(2025, 9, 20),
  connectedAt: status == CoupleStatus.connected ? DateTime(2025, 9, 20) : null,
  startDate: DateTime(2025, 8, 1),
  anniversaries: [
    Anniversary(
      id: 'a1',
      title: '준호 생일',
      date: DateTime(1998, 12, 24),
      icon: AnniversaryIcon.cake,
    ),
    Anniversary(id: 'a2', title: '첫 만남', date: DateTime(2025, 7, 12)),
  ],
);

Future<void> _shoot(
  WidgetTester tester,
  Widget screen,
  String name, {
  Couple? couple,
  List<Event> events = const [],
}) async {
  // 테스트 기본값은 그림자를 검은 선으로 그려서 실제 화면과 달라진다
  debugDisableShadows = false;
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final day = DateTime(2026, 11, 5);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => _FakeAuth()),
        coupleProvider.overrideWith((ref) => Stream.value(couple)),
        coupleMemberNamesProvider.overrideWith(
          (ref) async => {'me': '민지', 'you': '준호'},
        ),
        realtimeCoupleSyncProvider.overrideWith((ref) => const Stream.empty()),
        realtimePersonalSyncProvider.overrideWith(
          (ref) => const Stream.empty(),
        ),
        selectedDateProvider.overrideWith((ref) => day),
        focusedDateProvider.overrideWith((ref) => day),
        selectedDayEventsProvider.overrideWith((ref) => Stream.value(events)),
        monthEventsProvider.overrideWith((ref) => Stream.value(events)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: screen,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );

  // 프레임워크가 테스트 종료 시 이 값을 검사하므로 끝나기 전에 되돌린다
  await tester.pumpWidget(const SizedBox());
  debugDisableShadows = true;
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('ko_KR');
    await _loadFont('Gaegu', [
      'assets/fonts/Gaegu-Regular.ttf',
      'assets/fonts/Gaegu-Bold.ttf',
    ]);
    await _loadFont('GowunDodum', ['assets/fonts/GowunDodum-Regular.ttf']);
    final icons = File(
      '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (icons.existsSync()) {
      await _loadFont('MaterialIcons', [icons.path]);
    }
  });

  group('daysTogether', () {
    test('연결한 날이 1일째다', () {
      expect(
        daysTogether(DateTime(2026, 11, 5, 23), DateTime(2026, 11, 5, 1)),
        1,
      );
    });

    test('자정을 넘기면 하루가 늘어난다', () {
      expect(
        daysTogether(DateTime(2026, 11, 5, 23), DateTime(2026, 11, 6, 0, 1)),
        2,
      );
    });

    test('한 해의 마지막 날은 365일째다', () {
      expect(daysTogether(DateTime(2026, 1, 1), DateTime(2026, 12, 31)), 365);
    });
  });

  testWidgets('로그인', (tester) async {
    await _shoot(tester, const LoginPage(), 'login');
  });

  testWidgets('홈 - 연결됨, 일정 있음', (tester) async {
    await _shoot(
      tester,
      const CalendarHome(),
      'home_events',
      couple: _couple(CoupleStatus.connected),
      events: [
        _event(1, '저녁 데이트', coupleId: 'c1', start: DateTime(2026, 11, 5, 19)),
        _event(2, '치과 예약', start: DateTime(2026, 11, 5, 10, 30)),
      ],
    );
  });

  testWidgets('홈 - 미연결, 일정 없음', (tester) async {
    await _shoot(tester, const CalendarHome(), 'home_empty');
  });

  testWidgets('커플 연결 - 코드 대기', (tester) async {
    await _shoot(
      tester,
      const CoupleConnectPage(),
      'connect_pending',
      couple: _couple(CoupleStatus.pending),
    );
  });

  testWidgets('기념일', (tester) async {
    await _shoot(
      tester,
      const AnniversaryPage(),
      'anniversaries',
      couple: _couple(CoupleStatus.connected),
    );
  });

  testWidgets('커플 연결 - 완료', (tester) async {
    await _shoot(
      tester,
      const CoupleConnectPage(),
      'connect_done',
      couple: _couple(CoupleStatus.connected),
    );
  });
}
