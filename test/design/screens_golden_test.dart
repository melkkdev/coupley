import 'dart:io';

import 'package:coupley/app/router.dart';
import 'package:coupley/core/database/drift_database.dart';
import 'package:coupley/core/services/realtime_sync_provider.dart';
import 'package:coupley/core/theme/app_theme.dart';
import 'package:coupley/features/auth/models/auth_status.dart';
import 'package:coupley/features/auth/providers/auth_provider.dart';
import 'package:coupley/features/auth/widgets/login_page.dart';
import 'package:coupley/features/calendar/providers/calendar_provider.dart';
import 'package:coupley/features/calendar/widgets/event_form_page.dart';
import 'package:coupley/features/couple/models/anniversary.dart';
import 'package:coupley/features/couple/models/couple.dart';
import 'package:coupley/features/couple/providers/couple_provider.dart';
import 'package:coupley/features/couple/widgets/anniversary_form_page.dart';
import 'package:coupley/features/couple/widgets/couple_connect_page.dart';
import 'package:coupley/features/settings/providers/notification_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
          email: 'minji@example.com',
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PushOn extends PushEnabledNotifier {
  @override
  Future<bool> build() async => true;
}

Event _event(
  int id,
  String title, {
  String? coupleId,
  DateTime? start,
  DateTime? end,
  int day = 5,
}) {
  final date = DateTime(2026, 11, day);
  return Event(
    id: id,
    title: title,
    date: date,
    color: '#FF51B48D',
    isAllDay: start == null,
    startTime: start,
    endTime: end,
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
    Anniversary(
      id: 'a2',
      title: '첫 만남',
      date: DateTime(2025, 7, 12),
      color: AnniversaryColor.mint,
    ),
    Anniversary(
      id: 'a3',
      title: '처음 간 여행',
      date: DateTime(2025, 10, 3),
      yearly: false,
      color: AnniversaryColor.pink,
    ),
  ],
);

/// [screen]을 바로 그리거나, [tab]이 있으면 하단 탭까지 포함한 라우터로 그린다.
Future<void> _shoot(
  WidgetTester tester,
  String name, {
  Widget? screen,
  String? tab,
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
  final dayEvents = events.where((e) => e.date.day == day.day).toList();
  final theme = AppTheme.light();

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
        weekSelectedDateProvider.overrideWith((ref) => day),
        selectedDayEventsProvider.overrideWith(
          (ref) => Stream.value(dayEvents),
        ),
        monthEventsProvider.overrideWith((ref) => Stream.value(events)),
        weekEventsProvider.overrideWith((ref) => Stream.value(events)),
        pushEnabledProvider.overrideWith(_PushOn.new),
      ],
      child: tab != null
          ? MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: theme,
              routerConfig: GoRouter(
                initialLocation: tab,
                routes: [appShellRoute()],
              ),
            )
          : MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme,
              home: screen,
            ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  await expectLater(
    find.byWidgetPredicate((w) => w is MaterialApp),
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

  final connected = _couple(CoupleStatus.connected);
  final weekEvents = [
    _event(
      1,
      '저녁 데이트',
      coupleId: 'c1',
      start: DateTime(2026, 11, 5, 19),
      end: DateTime(2026, 11, 5, 21),
    ),
    _event(
      2,
      '치과 예약',
      start: DateTime(2026, 11, 5, 10, 30),
      end: DateTime(2026, 11, 5, 11, 30),
    ),
    _event(3, '영화 보기', coupleId: 'c1', day: 7),
  ];

  testWidgets('로그인', (tester) async {
    await _shoot(tester, 'login', screen: const LoginPage());
  });

  testWidgets('오늘 일정 - 연결됨, 일정 있음', (tester) async {
    await _shoot(
      tester,
      'today_events',
      tab: AppTabs.today,
      couple: connected,
      events: weekEvents,
    );
  });

  testWidgets('오늘 일정 - 미연결, 일정 없음', (tester) async {
    await _shoot(tester, 'today_empty', tab: AppTabs.today);
  });

  testWidgets('달력', (tester) async {
    await _shoot(
      tester,
      'calendar',
      tab: AppTabs.calendar,
      couple: connected,
      events: weekEvents,
    );
  });

  testWidgets('기념일', (tester) async {
    await _shoot(
      tester,
      'anniversaries',
      tab: AppTabs.anniversaries,
      couple: connected,
    );
  });

  testWidgets('설정', (tester) async {
    await _shoot(tester, 'settings', tab: AppTabs.settings, couple: connected);
  });

  testWidgets('일정 추가', (tester) async {
    await _shoot(
      tester,
      'event_form',
      screen: EventFormPage(initialDate: DateTime(2026, 11, 5)),
      couple: connected,
    );
  });

  testWidgets('기념일 추가', (tester) async {
    await _shoot(
      tester,
      'anniversary_form',
      screen: const AnniversaryFormPage(),
      couple: connected,
    );
  });

  testWidgets('커플 연결 - 코드 대기', (tester) async {
    await _shoot(
      tester,
      'connect_pending',
      screen: const CoupleConnectPage(),
      couple: _couple(CoupleStatus.pending),
    );
  });

  testWidgets('커플 연결 - 완료', (tester) async {
    await _shoot(
      tester,
      'connect_done',
      screen: const CoupleConnectPage(),
      couple: connected,
    );
  });
}
