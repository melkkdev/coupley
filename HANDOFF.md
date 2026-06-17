# Coupley 프로젝트 핸드오프 문서

> 작성일: 2026-06-18 (갱신)
> 다음 세션에서 이어서 작업하기 위한 현재 상태 정리

---

## 프로젝트 경로

- 절대 경로(진짜 루트, pubspec.yaml 있는 곳): `C:\Users\tkdals\dev\app\coupley_dev\coupley\`
- 패키지명: `com.mellkk.coupley`
- Firebase 프로젝트: `coupley-219a1`
- GitHub: `origin/main` — 이번 세션 변경분은 아직 커밋 전(아래 "차단 이슈" 참고)
- 보조 브랜치: `feature/offline-sync-queue` (로컬·리모트 둘 다 존재, 미병합 — "직접 오프라인 동기화 큐" 작업용)

---

## 현재 상태

커플 캘린더 앱(Flutter + Firebase + Drift)의 핵심 기능이 안정적으로 구현된 상태이며, 이번 세션에서 스플래시 화면 중복 제거와 캘린더 한글화·주말/공휴일 강조 표시를 추가 구현함.

---

## 이번 세션(2026-06-18)에 한 작업

1. **스플래시 중복 제거** — `main.dart`의 `AppInitializer`(인위적 2초 대기 + 자체 스플래시)를 삭제하고, `router.dart`의 `/splash`(인증 초기화 상태 `isInitializing` 기반) 하나로 통일. `main()`은 이제 `runApp(const ProviderScope(child: MyApp()))`만 호출.
2. **캘린더 한글화** — `table_calendar`의 월 헤더("2026년 6월")와 요일 헤더(일/월/화/수/목/금/토)가 영어로 나오던 것을 해결.
   - `main.dart`에서 `initializeDateFormatting('ko_KR')` 호출(intl 로케일 데이터 초기화, 안 하면 런타임 에러).
   - `calendar_view.dart`의 `TableCalendar`에 `locale: 'ko_KR'` 추가.
3. **주말/공휴일 빨간색 표시**
   - `daysOfWeekStyle.weekendStyle` + `calendarStyle.weekendTextStyle`로 토/일 텍스트를 빨간색으로.
   - `lib/core/common/korea_holidays.dart` 신규 생성 — 2024~2027년 공휴일 데이터(설날/추석/부처님오신날 등 음력 기반 포함, 정부 발표 기준 수동 입력). `holidayPredicate: KoreaHolidays.isHoliday` + `calendarStyle.holidayTextStyle`로 공휴일도 빨간색.
   - 음력 공휴일은 매년 양력 날짜가 바뀌므로 **2028년 이후는 데이터가 없어 공휴일 표시가 안 됨** — 연도가 지날 때마다 `korea_holidays.dart`에 추가 입력 필요.

`flutter analyze` 통과 확인함.

---

## 구현된 파일

```
lib/
├─ main.dart                          # Firebase 초기화, Firestore offline persistence 설정, 2초 스플래시(AppInitializer)
├─ app/
│  ├─ app.dart                        # MaterialApp 루트, 테마/로컬라이제이션 적용
│  └─ router.dart                     # go_router 설정 — /splash·/login·/calendar·/couple-connect, isInitializing 기반 리다이렉트
├─ core/
│  ├─ common/
│  │  ├─ spacing.dart                 # 공통 간격 상수
│  │  ├─ nickname_generator.dart      # 랜덤 닉네임 생성("행복한판다482" 형식)
│  │  └─ korea_holidays.dart          # 한국 공휴일 데이터(2024~2027, 수동 입력), 캘린더 공휴일 빨간색 표시용
│  ├─ database/
│  │  ├─ drift_database.dart(+.g.dart) # Drift 로컬 DB 스키마(Firebase 미러 구조)
│  │  └─ database_provider.dart       # Drift DB Riverpod provider
│  ├─ services/
│  │  ├─ firebase_service.dart        # Firestore CRUD 래퍼
│  │  ├─ sync_service.dart / sync_provider.dart / sync_storage.dart / realtime_sync_provider.dart
│  │  │                               # Firebase=진실의 원천, Drift=단방향 미러. 실시간 리스너 동기화
│  │  ├─ user_service.dart / user_provider.dart  # 유저 프로필 CRUD, 닉네임 변경, 작성자 이름 조회
│  │  └─ couple_service.dart          # 커플 연결/해제, 초대 코드 합류
│  └─ debug/
│     ├─ debug_mode.dart / debug_provider.dart  # 디버그 모드(예: skipAuth) 상태
│     └─ debug_panel.dart             # 디버그 패널 UI(DebugFloatingButton 포함, kDebugMode로 감싸짐)
└─ features/
   ├─ auth/
   │  ├─ models/auth_status.dart       # AuthState 단일 정의(중복 정리 완료)
   │  ├─ models/user_profile.dart      # 유저 프로필 모델(phoneNumber/fcmToken은 Phase 4 예약 필드)
   │  ├─ providers/auth_provider.dart  # 로그인 상태, isInitializing 플래그
   │  └─ widgets/login_page.dart       # 이메일/Google 로그인 UI
   ├─ calendar/
   │  ├─ providers/calendar_provider.dart  # monthEvents/selectedDayEvents, authProvider.select 최적화
   │  └─ widgets/
   │     ├─ calendar_home.dart         # 캘린더 메인 화면, DebugFloatingButton kDebugMode 분기 포함
   │     ├─ calendar_view.dart / calendar_widgets.dart  # table_calendar 래핑, 마커 색 구분, ko_KR 로케일·주말/공휴일 빨간색
   │     ├─ event_card.dart            # 이벤트 카드(개인/커플 색 구분, 작성자 표시)
   │     ├─ add_event_dialog.dart      # 이벤트 추가/수정 다이얼로그
   │     └─ greeting_header.dart       # 인사말 + 닉네임 변경 연필 아이콘
   └─ couple/
      ├─ models/couple.dart
      ├─ providers/couple_provider.dart    # coupleId는 userProfileProvider.select로만 구독
      ├─ widgets/couple_connect_page.dart  # 초대 코드 생성/입력, 연결 해제(SingleChildScrollView로 오버플로우 수정됨)
      └─ invite_code_generator.dart        # 6자리 초대 코드 생성
```

---

## 설치된 패키지

`pubspec.yaml` 기준 (Flutter SDK `>=3.38.9 <3.39.0`, Dart `>=3.10.8`):

- **상태관리**: `flutter_riverpod ^2.6.1`
- **내비게이션**: `go_router ^14.6.2`
- **로컬 DB**: `drift ^2.20.3`, `sqlite3_flutter_libs ^0.5.24`, `path_provider ^2.1.5`, `path ^1.9.0`
- **Firebase**: `firebase_core ^3.8.1`, `firebase_auth ^5.3.4`, `cloud_firestore ^5.5.2`
- **인증**: `google_sign_in ^6.2.2`, `sign_in_with_apple ^6.1.3` (iOS용, 미연동)
- **로컬 저장소**: `shared_preferences ^2.3.3`
- **UI/캘린더**: `cupertino_icons ^1.0.8`, `intl ^0.20.2`(flutter_localizations 호환 위해 핀 고정), `table_calendar ^3.1.2`, `share_plus ^13.1.0`(초대 코드 공유)
- **dev**: `flutter_lints ^5.0.0`, `drift_dev ^2.20.3`, `build_runner ^2.4.13`, `change_app_package_name ^1.5.0`

---

## 차단 이슈

현재 빌드를 막는 이슈는 없음. 이번 세션 변경분(`main.dart`, `calendar_view.dart`, `korea_holidays.dart`)은 `flutter analyze` 통과했지만 아직 git 커밋 전 상태였음(이 핸드오프 작성 직후 커밋 진행). 다만 알아둘 환경 제약:

- 공휴일 데이터(`korea_holidays.dart`)는 2024~2027년만 채워져 있음 — 2028년 진입 전에 해당 연도 공휴일을 추가 입력해야 캘린더에 표시됨.
- Apple Sign In(`sign_in_with_apple`) 패키지는 설치만 돼 있고 실제 연동 미구현.
- Firestore 복합 색인이 필요한 쿼리(userId+date, coupleId+date 등) 추가 시, 콘솔 에러 링크로 색인 직접 생성해야 함.
- 에뮬레이터에서 GoogleApiManager/Phenotype/DEVELOPER_ERROR 류 로그는 Google Play Services 노이즈이며 무시해도 됨.
- Windows PowerShell 환경 — `rmdir /s /q`(cmd) 대신 `Remove-Item -Recurse -Force` 사용.
- Provider/리스너/StateNotifier 코드 변경은 Hot Reload로 반영 안 됨 → 완전 재시작 필요.

---

## 다음 구현할 기능

- [x] 인증(이메일/Google), 랜덤 닉네임 생성·변경
- [x] 커플 연결(초대 코드 생성/공유/합류/해제)
- [x] 이벤트 CRUD, 개인/커플 일정 분리(색·마커·뱃지)
- [x] 실시간 동기화(Firebase 진실의 원천 + Drift 미러)
- [x] 작성자 표시("나 추가" / "상대닉네임 추가")
- [x] 오프라인 지원(Firestore persistence)
- [x] Firestore 보안 규칙(isOwner, isMyPartner, isCoupleMember)
- [x] Production 디버그 버튼 `kDebugMode` 처리 — `calendar_home.dart:147`에 적용 완료, 커밋됨
- [x] README 작성 및 저장소 루트에 커밋
- [x] `main.dart`의 2초 스플래시(AppInitializer)와 `router.dart`의 `/splash` 중복 제거 — router의 isInitializing 기반 스플래시 하나로 통일
- [x] 캘린더 한글화(`locale: 'ko_KR'`) + 토/일·공휴일 빨간색 표시(`korea_holidays.dart`)
- [ ] README 스크린샷 추가(`screenshots/` 폴더 생성, placeholder 교체)
- [ ] 옵션: 직접 오프라인 동기화 큐 구현 — `feature/offline-sync-queue` 브랜치에서 진행. syncStatus 필드(pending/updated/deleted/synced) + 동기화 워커 + `connectivity_plus` + firebaseId 기반 충돌 처리. 포트폴리오 어필 포인트로 의도된 것이라 복잡해도 단계별 진행 권장
- [ ] 커플 연결 완료 화면 꾸미기(파트너 이름/사진, D-day)
- [ ] 이벤트 색상 직접 선택 기능
- [ ] 위젯 분리 마저 정리(EventList, AppBar 등)
- [ ] Phase 4 예약 기능: 전화번호 기반 유저 찾기(`user_service.dart:103`), FCM 토큰 업데이트(`user_service.dart:113`) — `user_profile.dart`에 필드는 이미 있음
- [ ] 카카오/Apple 로그인, FCM 푸시 알림

---

## 핵심 코드 패턴

- **Firebase = 진실의 원천, Drift = 단방향 미러**: 모든 쓰기는 Firestore에 먼저 반영하고, 실시간 리스너(`realtime_sync_provider.dart`)가 변경을 감지해 Drift 로컬 DB를 갱신. 로컬 DB를 직접 쓰지 않음.
- **Riverpod `select`로 불필요한 리빌드 차단**: `coupleProvider`는 `userProfileProvider.select((s) => s.coupleId)`만, `calendar_provider`의 `monthEvents`/`selectedDayEvents`는 `authProvider.select((s) => s.userId)`만 구독. 닉네임 변경처럼 무관한 상태가 바뀌어도 캘린더가 리빌드되지 않도록 의도적으로 좁게 구독함.
- **`skipLoadingOnReload: true`**: 날짜 선택 시 이전 데이터를 유지한 채 새 데이터를 불러와 캘린더 깜빡임을 제거.
- **인증 초기화 상태(`isInitializing`)**: `router.dart`의 `redirect`에서 `authState.isInitializing`이 true면 `/splash` 유지. 로그인된 상태로 앱을 켜도 로그인 페이지가 잠깐 보이는 깜빡임을 방지.
- **커플 연결 해제 순서**: 커플 일정 삭제 → 본인 coupleId 정리 → couples 문서 존재 확인 후 삭제. "연결 해제 후"가 아니라 "전"에 삭제해야 Firestore 권한이 살아있는 동안 처리 가능. 상대방은 couples 문서가 사라진 것을 감지해 자동으로 자기 쪽 정리.
- **오프라인 쓰기**: Firestore 쓰기에 `await` 대신 `.catchError`만 걸어 UI 응답성 유지(오프라인이어도 즉시 로컬 캐시에 반영되고 추후 자동 동기화).
