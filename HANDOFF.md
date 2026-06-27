# HANDOFF.md — Coupley

## 프로젝트 경로
`C:\Users\tkdals\dev\app\coupley_dev\coupley`

## 현재 상태
커플 캘린더 앱 — 인증(이메일/Google/카카오), 커플 연결, 캘린더(한글/공휴일/주말), 실시간 동기화, FCM 푸시 알림 모두 작동 중. Firebase Blaze 플랜 사용 중.

---

## 구현된 파일

### 진입점
| 파일 | 역할 |
|------|------|
| `lib/main.dart` | Firebase 초기화, FCM 백그라운드 핸들러 등록, Firestore 오프라인 지속성, 한글 로케일, NotificationService 초기화 |
| `lib/app/app.dart` | `MyApp` — `MaterialApp.router` 래퍼 |
| `lib/app/router.dart` | GoRouter 설정; 인증 상태에 따른 리다이렉트(`/splash` → `/login` or `/calendar`), 스플래시 위젯 포함 |

### 인증 (auth)
| 파일 | 역할 |
|------|------|
| `lib/features/auth/models/auth_status.dart` | `AuthState` sealed/freezed 모델 (initializing / unauthenticated / authenticated) |
| `lib/features/auth/models/user_profile.dart` | 유저 프로필 데이터 모델 (`fcmToken` 필드 포함) |
| `lib/features/auth/providers/auth_provider.dart` | `AuthNotifier` — Google/Apple/카카오/이메일 로그인, 닉네임 변경, 로그아웃(FCM 토큰 제거 포함) |
| `lib/features/auth/widgets/login_page.dart` | 이메일·카카오·Google·Apple(iOS 전용) 로그인 UI, 로딩 오버레이 |

### 캘린더 (calendar)
| 파일 | 역할 |
|------|------|
| `lib/features/calendar/providers/calendar_provider.dart` | `selectedDateProvider`, `monthEventsProvider`, `selectedDayEventsProvider`, `CalendarNotifier`(추가/수정/삭제) — 커플/솔로 자동 분기 |
| `lib/features/calendar/widgets/calendar_home.dart` | 메인 홈 화면 — 실시간 동기화 리스너 활성화, 캘린더+이벤트 목록, 설정 다이얼로그 |
| `lib/features/calendar/widgets/calendar_view.dart` | `TableCalendar` — 한글 로케일, 공휴일 표시, 개인(파란점)/커플(핑크점) 마커 분리, `daysOfWeekHeight: 32`, `rowHeight: 58` |
| `lib/features/calendar/widgets/greeting_header.dart` | 상단 닉네임 + 편집 버튼 (닉네임 변경 시 이 위젯만 리빌드) |
| `lib/features/calendar/widgets/add_event_dialog.dart` | 일정 추가/수정 다이얼로그 — 커플 일정 토글 포함 |
| `lib/features/calendar/widgets/event_card.dart` | 선택된 날짜의 이벤트 카드 — 작성자 표시, 수정/삭제 메뉴 |
| `lib/features/calendar/widgets/calendar_widgets.dart` | 공유 위젯 모음 |

### 커플 (couple)
| 파일 | 역할 |
|------|------|
| `lib/features/couple/models/couple.dart` | `Couple` 모델 (`isConnected`, `members`, `inviteCode` 등) |
| `lib/features/couple/providers/couple_provider.dart` | `coupleNotifierProvider` — 초대 코드 생성/참여/해제 |
| `lib/features/couple/widgets/couple_connect_page.dart` | 커플 연결 화면 — 연결 전(초대코드 만들기/입력) / 연결 후(파트너 정보) |
| `lib/features/couple/invite_code_generator.dart` | 6자 알파벳+숫자 초대 코드 생성 유틸 |

### 코어 (core)
| 파일 | 역할 |
|------|------|
| `lib/core/database/drift_database.dart` | `AppDatabase` — Events/CoupleInfo 테이블, CRUD + 스트림 쿼리, 마이그레이션 (schemaVersion=4) |
| `lib/core/database/drift_database.g.dart` | drift_dev 자동 생성 파일 (수동 편집 금지) |
| `lib/core/database/database_provider.dart` | `databaseProvider` Riverpod 프로바이더 |
| `lib/core/services/firebase_service.dart` | Firestore CRUD, 실시간 스트림 (`getCoupleEventsStream`, `getPersonalEventsStream`) |
| `lib/core/services/sync_service.dart` | `SyncService` — 스마트 증분 동기화, Drift↔Firebase 머지 |
| `lib/core/services/sync_provider.dart` | `syncServiceProvider`, `firebaseServiceProvider` |
| `lib/core/services/sync_storage.dart` | SharedPreferences 기반 마지막 동기화 시각 저장 |
| `lib/core/services/realtime_sync_provider.dart` | `realtimeCoupleSyncProvider` + `realtimePersonalSyncProvider` — Firebase 실시간 리스너 → Drift upsert/delete |
| `lib/core/services/notification_service.dart` | FCM 초기화, 권한 요청, 토큰 Firestore 저장/제거, 포그라운드 알림 표시 |
| `lib/core/services/user_service.dart` | Firestore `users` 컬렉션 관리 |
| `lib/core/services/user_provider.dart` | `userServiceProvider` |
| `lib/core/services/couple_service.dart` | 커플 관련 Firestore 작업 |
| `lib/core/config/app_config.dart` | 앱 전역 상수 (카카오 네이티브 앱 키 등) |
| `lib/core/common/nickname_generator.dart` | 회원가입 시 랜덤 닉네임 자동 생성 |
| `lib/core/common/korea_holidays.dart` | 한국 공휴일 데이터 (2024~2027년 하드코딩) |
| `lib/core/common/spacing.dart` | 앱 전체 간격/radius 상수 (`xs`~`xxl`, `smMd=12`) |
| `lib/core/theme/app_theme.dart` | 앱 테마 설정 |
| `lib/core/design/indicators/app_loading_indicator.dart` | 로딩 인디케이터 위젯 |
| `lib/core/debug/debug_mode.dart` | `DebugMode` enum (normal / skipAuth) |
| `lib/core/debug/debug_provider.dart` | `debugModeProvider` |
| `lib/core/debug/debug_panel.dart` | 디버그 플로팅 패널 (kDebugMode에서만 표시) |

### Cloud Functions
| 파일 | 역할 |
|------|------|
| `functions/index.js` | Firestore 트리거 — 커플 일정 추가/수정/삭제 시 파트너 FCM 발송 (asia-northeast3, Node.js 22) |
| `functions/package.json` | Firebase Functions 의존성 (firebase-admin ^12, firebase-functions ^6) |
| `firebase.json` | Functions 소스 경로 설정 |
| `.firebaserc` | 기본 프로젝트 `coupley-219a1` 지정 |

---

## 설치된 패키지 (pubspec.yaml)

### 런타임 의존성
| 패키지 | 버전 | 용도 |
|--------|------|------|
| flutter_riverpod | ^2.6.1 | 상태 관리 |
| go_router | ^14.6.2 | 라우팅 |
| drift | ^2.20.3 | 로컬 SQLite DB |
| sqlite3_flutter_libs | ^0.5.24 | SQLite 네이티브 바인딩 |
| path_provider | ^2.1.5 | 앱 문서 디렉토리 경로 |
| path | ^1.9.0 | 경로 조합 유틸 |
| firebase_core | ^3.8.1 | Firebase 초기화 |
| firebase_auth | ^5.3.4 | 인증 |
| cloud_firestore | ^5.5.2 | 원격 DB |
| firebase_messaging | ^15.1.5 | FCM 푸시 알림 |
| flutter_local_notifications | ^18.0.1 | 포그라운드 알림 표시 |
| google_sign_in | ^6.2.2 | Google 로그인 |
| sign_in_with_apple | ^6.1.3 | Apple 로그인 (iOS) |
| kakao_flutter_sdk_user | ^1.9.9 | 카카오 로그인 |
| shared_preferences | ^2.3.3 | 동기화 타임스탬프 로컬 저장 |
| intl | ^0.20.2 | 날짜 포맷, 한글 로케일 |
| table_calendar | ^3.1.2 | 캘린더 UI |
| share_plus | ^13.1.0 | 초대 코드 공유 |
| flutter_localizations | SDK | 한글 지원 |

### 개발 의존성
| 패키지 | 버전 | 용도 |
|--------|------|------|
| drift_dev | ^2.20.3 | DB 코드 생성 |
| build_runner | ^2.4.13 | 코드 제너레이터 실행 |
| change_app_package_name | ^1.5.0 | 패키지명 변경 도구 |

---

## 차단 이슈

현재 알려진 빌드/실행 차단 이슈 없음.

**주의사항:**
- Drift 스키마 변경 시 반드시 `flutter pub run build_runner build` 실행 필요
- `drift_database.g.dart`는 자동 생성 파일 — 수동 편집 금지
- 한국 공휴일 데이터는 2027년까지만 있음 (2028년 이후 연도 추가 필요)
- Apple 로그인은 iOS에서만 작동 (`Platform.isIOS` 분기 처리됨)
- `flutter_local_notifications` 사용으로 Android `build.gradle`에 `coreLibraryDesugaringEnabled true` 설정 필요 (이미 적용됨)
- Cloud Functions 수정 후 반드시 `firebase deploy --only functions` 재배포 필요

---

## 다음 구현할 기능

### 완료 ✅
- [x] Firebase 인증 (이메일/Google/Apple)
- [x] 카카오 로그인 연동
- [x] 랜덤 닉네임 자동 생성 + 닉네임 변경
- [x] Drift 로컬 DB (Events, CoupleInfo 테이블)
- [x] Firebase Firestore 동기화 (실시간 리스너 기반)
- [x] 스마트 증분 동기화 (첫 실행=전체, 이후=변경분만)
- [x] 커플 연결 (초대 코드 6자 생성/참여/해제)
- [x] 커플 일정 vs 개인 일정 분리 (마커 색상 구분: 파랑/핑크)
- [x] 캘린더 한글화 (월 제목, 요일 표시)
- [x] 주말/공휴일 빨간색 표시
- [x] 한국 공휴일 데이터 (2024~2027)
- [x] 이벤트 카드에 작성자 표시
- [x] 설정 다이얼로그 (커플 연결, 로그아웃)
- [x] Firestore 오프라인 지속성 활성화
- [x] 인증 초기화 UX 개선 (스플래시 → 리다이렉트)
- [x] 디버그 모드 (Auth Skip)
- [x] FCM 푸시 알림 — 파트너 일정 추가/수정/삭제 시 알림 (Cloud Functions + firebase_messaging)
- [x] 패키지명 변경 — `com.mellkk.coupley` → `com.melkk.coupley`

### 미완료 / 다음 세션 작업 후보

#### 공통 기능
- [ ] 기념일 D-day 표시 (커플 기준일 설정)
- [ ] 일정 반복 기능 (매주/매월/매년)
- [ ] 이벤트 색상 커스터마이즈 UI 개선
- [ ] 커플 프로필 사진 업로드 (Firebase Storage)
- [ ] 2028년 이후 공휴일 데이터 추가
- [ ] 단위 테스트 / 위젯 테스트

#### Android (AOS)
- [ ] 앱 아이콘 설정 (`android/app/src/main/res/` 각 density별 이미지 교체)
- [ ] 스플래시 이미지 설정 (`android/app/src/main/res/drawable/`)
- [ ] 서명 키스토어 생성 및 `build.gradle` 서명 설정
- [ ] Google Play 스토어 릴리즈 빌드 (`flutter build appbundle`)
- [x] 카카오 로그인 — Android 디버그 해시 키 등록 완료 (`phiTM5xjx5Kr+6eHuxPzevhy1Bs=`, 패키지명: `com.melkk.coupley`)
- [ ] 카카오 로그인 — 릴리즈 키스토어 생성 후 릴리즈 해시 키 콘솔 등록

#### iOS
- [ ] Apple 로그인 연동 — Xcode Signing & Capabilities에서 `Sign In with Apple` 활성화 (현재 코드는 준비됨, 인증서 설정 필요)
- [ ] 앱 아이콘 설정 (`ios/Runner/Assets.xcassets/AppIcon.appiconset/`)
- [ ] 스플래시 이미지 설정 (`ios/Runner/Assets.xcassets/LaunchImage.imageset/`)
- [ ] Bundle ID 설정 (Xcode → Runner → Signing & Capabilities)
- [ ] 프로비저닝 프로파일 / 인증서 설정 (Apple Developer 계정 필요)
- [ ] App Store 릴리즈 빌드 (`flutter build ipa`)
- [x] 카카오 로그인 — Info.plist URL Scheme 등록 완료

---

## 핵심 코드 패턴

### 데이터 플로우
```
사용자 액션
  → Firebase에만 쓰기 (CalendarNotifier.addEvent/updateEvent/deleteEvent)
  → Firestore 실시간 리스너 발화 (realtimeCoupleSyncProvider / realtimePersonalSyncProvider)
  → Drift upsert/delete
  → Drift Stream → UI 자동 갱신
  → Cloud Functions 트리거 → 파트너 FCM 발송
```

### FCM 알림 플로우
```
커플 일정 추가/수정/삭제
  → Firestore events 컬렉션 변경
  → Cloud Functions (onEventCreated / onEventUpdated / onEventDeleted)
  → couples/{coupleId}.members에서 파트너 userId 조회
  → users/{partnerId}.fcmToken 조회
  → FCM 발송 (닉네임 + 일정 제목 포함)
```

### 커플/솔로 분기 패턴
```dart
final couple = coupleAsync.valueOrNull;
if (couple != null && couple.isConnected) {
  return database.watchEventsByDateRangeCombined(userId, couple.id, ...);
} else {
  return database.watchEventsByDateRange(userId, ...);
}
```

### 리빌드 최소화 패턴
```dart
// userId만 select → userName 변경 시 이 Provider 재평가 안 됨
final userId = ref.watch(authProvider.select((s) => s.userId));
```

### 캘린더 마커 분리 (개인=파랑, 커플=핑크)
```dart
final hasCouple = events.any((e) => e.coupleId != null);
final hasPersonal = events.any((e) => e.coupleId == null);
```

### Drift 스키마 변경 절차
1. `drift_database.dart`에서 테이블/컬럼 수정
2. `schemaVersion` 증가
3. `migration.onUpgrade`에 마이그레이션 코드 추가
4. `flutter pub run build_runner build --delete-conflicting-outputs`
