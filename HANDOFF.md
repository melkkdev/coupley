# HANDOFF.md — Coupley

## 프로젝트 경로
`C:\Users\tkdals\dev\app\coupley` (GitHub `melkkdev/coupley`, 작업 브랜치 `design/readdy-redesign`)

## 현재 상태
Readdy 리디자인 + 스토어 출시 준비 코드 완료(2026-11-24, `3bf8e13` push). Functions·개인정보처리방침 배포 완료, Codemagic iOS 서명 설정(인증서·프로파일) 진행 중.

---

## 구현된 파일

### 앱 / 라우팅
| 파일 | 역할 |
|------|------|
| `lib/main.dart` | Firebase 초기화, FCM 백그라운드 핸들러, Firestore 오프라인 지속성, 한글 로케일 |
| `lib/app/app.dart` | `MaterialApp.router` 래퍼 |
| `lib/app/router.dart` | GoRouter, 인증 상태 리다이렉트, `appShellRoute()` |
| `lib/app/main_shell.dart` | 하단 탭 4개(오늘 일정·달력·기념일·설정) 셸 |

### 인증 (auth)
| 파일 | 역할 |
|------|------|
| `lib/features/auth/providers/auth_provider.dart` | `AuthNotifier` — 휴대폰(SMS)·카카오(Custom Token)·Google·Apple 로그인, 로그아웃, **`deleteAccount()` 회원 탈퇴** |
| `lib/features/auth/widgets/login_page.dart` | 로그인 화면 (Apple 버튼은 iOS 전용) |
| `lib/features/auth/widgets/phone_login_page.dart` | 휴대폰 번호 인증 화면 |
| `lib/features/auth/models/*` | `AuthState`, `UserProfile` |

### 캘린더 (calendar)
| 파일 | 역할 |
|------|------|
| `lib/features/calendar/widgets/today_page.dart` | 오늘 일정 탭 (D+N 카드 포함) |
| `lib/features/calendar/widgets/calendar_page.dart` / `calendar_view.dart` | 달력 탭, TableCalendar(공휴일·개인 민트/커플 핑크/기념일 하트 마커) |
| `lib/features/calendar/widgets/event_form_page.dart` | 일정 추가/수정 (fullscreenDialog 페이지) |
| `lib/features/calendar/widgets/event_card.dart`, `day_anniversaries.dart` | 일정 카드, 날짜별 기념일 |
| `lib/features/calendar/providers/calendar_provider.dart` | 일정 CRUD, 커플/솔로 분기 |

### 커플·기념일 (couple)
| 파일 | 역할 |
|------|------|
| `lib/features/couple/models/anniversary.dart` | 100일 단위·N주년 자동 계산 + 직접 등록 기념일 |
| `lib/features/couple/widgets/anniversary_page.dart`, `anniversary_form_page.dart` | 기념일 탭, 기념일 추가 |
| `lib/features/couple/widgets/couple_connect_page.dart`, `dday_card.dart` | 커플 연결, D+N 카드 |
| `lib/features/couple/providers/couple_provider.dart`, `models/couple.dart` | 초대 코드 생성/참여/해제 |

### 설정 (settings)
| 파일 | 역할 |
|------|------|
| `lib/features/settings/widgets/settings_page.dart` | 커플 연결, 알림, **개인정보처리방침 링크, 회원 탈퇴** |
| `lib/features/settings/providers/notification_settings_provider.dart` | 알림 설정 |

### 코어 (core)
| 파일 | 역할 |
|------|------|
| `lib/core/database/drift_database.dart` | Drift 로컬 미러 DB (탈퇴 시 전체 삭제 메서드 포함) |
| `lib/core/services/*` | Firestore CRUD, 증분/실시간 동기화, FCM, 유저/커플 서비스 |
| `lib/core/design/cozy/*` | 귀여운 톤 공용 위젯, `CharacterSlot` |
| `lib/core/theme/app_theme.dart` | 팔레트(크림·코랄·민트), 폰트 |
| `lib/core/config/app_config.dart` | 카카오 키, 개인정보처리방침 URL 등 상수 |

### 서버 / 배포
| 파일 | 역할 |
|------|------|
| `functions/index.js` | `onEventCreated/Updated/Deleted`(파트너 FCM), `kakaoLogin`(Custom Token), `deleteAccount`(회원 탈퇴) — asia-northeast3, Node 22 |
| `hosting/privacy.html` | 개인정보처리방침 → https://coupley-219a1.web.app/privacy (시행일 2026-11-24) |
| `firebase.json` | Functions + Hosting(`/privacy` rewrite) |
| `codemagic.yaml` | `ios-release`(TestFlight), `android-release`(Play 내부 테스트, 초안) — 수동 트리거 |

### 출시 설정
| 파일 | 역할 |
|------|------|
| `android/app/build.gradle` | `key.properties` 있으면 업로드 키 서명, 없으면 debug. targetSdk 36 |
| `android/key.properties` (git 제외) | 업로드 키스토어 `C:/Users/tkdals/keys/coupley-upload.jks`, alias `upload` |
| `ios/Runner/Runner.entitlements` | 푸시(`aps-environment`), Sign in with Apple |
| `ios/Runner/Info.plist` | 카카오·Google(REVERSED_CLIENT_ID)·휴대폰 인증(Encoded App ID) URL scheme, `ITSAppUsesNonExemptEncryption=false` |
| `ios/Podfile` | iOS 13.0 |
| `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` (git 제외) | 2026-11-24 `com.melkk.coupley`로 재등록한 Firebase 앱 설정 |

---

## 설치된 패키지 (pubspec.yaml)
- 상태/라우팅: `flutter_riverpod ^2.6.1`, `go_router ^14.6.2`
- 로컬 DB: `drift ^2.20.3`, `path_provider`, `path`, `shared_preferences`
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`, `cloud_functions ^5.6.2`
- 로그인: `google_sign_in ^6.2.2`, `sign_in_with_apple ^6.1.3`, `kakao_flutter_sdk_user ^1.9.9`
- UI/기타: `table_calendar`, `intl`, `flutter_local_notifications`, `share_plus`, `url_launcher ^6.3.3`
- dev: `drift_dev`, `build_runner`, `flutter_lints`, `change_app_package_name`
- Flutter 3.44.2 (Codemagic도 동일 버전 고정)

---

## 차단 이슈
- **Codemagic iOS 빌드 실패**: `No matching profiles found for bundle identifier "com.melkk.coupley" and distribution type "app_store"`
  → ① Apple Developer에 App ID 등록(Sign in with Apple·Push 켜기) ② Codemagic에서 Apple Distribution 인증서 Generate ③ Apple Developer에서 App Store 프로비저닝 프로파일 생성 ④ Codemagic에서 Fetch profiles
- Codemagic은 `main`에서 `codemagic.yaml`을 찾음 → 지금은 브랜치 `design/readdy-redesign` 선택해서 빌드
- iOS 빌드는 Windows에서 검증 불가 — Codemagic 첫 성공 빌드 전까지 iOS 설정 미검증

**주의사항**
- Firebase 앱은 2026-11-24 `com.mellkk.coupley`(오타) → `com.melkk.coupley`로 Android·iOS 모두 재등록함. 설정 파일 교체 시 패키지명 확인
- Functions 빌드는 compute 서비스 계정 사용 — `roles/cloudbuild.builds.builder` 2026-11-24 부여함
- 배포 실패로 FAILED 상태가 된 함수는 업데이트가 계속 실패 → `firebase functions:delete <name>` 후 재배포
- Drift 스키마 변경 시 `dart run build_runner build --delete-conflicting-outputs`

---

## 다음 구현할 기능

### 완료 ✅
- [x] Readdy 시안 리디자인 (하단 탭 4개, 기념일, 캐릭터 이미지)
- [x] 휴대폰 SMS 로그인, 카카오 Custom Token 로그인
- [x] 업로드 키스토어 생성 + release 서명 (AAB 서명 확인)
- [x] targetSdk 36, Android 앱 이름 `Coupley`
- [x] iOS entitlements, 최소 13.0, Podfile, URL scheme
- [x] 회원 탈퇴 (`deleteAccount` 함수 + 앱 흐름, Apple 토큰 해지 포함)
- [x] 개인정보처리방침 페이지 배포
- [x] Firebase SHA 등록 (업로드 키 SHA-1/256 + debug SHA-1), 카카오 키 해시·iOS 번들 ID 등록
- [x] `codemagic.yaml` 작성

### 미완료
- [ ] Codemagic iOS 서명 설정 (위 차단 이슈 ①~④) 후 `ios-release` 첫 빌드
- [ ] Codemagic 환경변수: `firebase` 그룹(base64 2개), `app_store`(APP_STORE_APPLE_ID), `google_play`(서비스 계정 JSON), Android keystore `coupley_upload`
- [ ] Firebase Auth에서 Apple 제공업체 사용 설정 + OAuth 코드 흐름(Team ID·Key ID·.p8) — 탈퇴 시 토큰 해지에 필요
- [ ] APNs 키(.p8)를 Firebase Cloud Messaging에 업로드
- [ ] Play Console 앱 등록 → 첫 AAB 수동 업로드 → 비공개 테스트(12명·14일) → Play 앱 서명 키 SHA·키 해시를 Firebase·카카오에 추가 등록
- [ ] 실제 기기에서 회원 탈퇴 테스트 (Firestore·Auth 삭제 확인)
- [ ] TestFlight로 카카오·Apple·휴대폰 로그인, 푸시 확인
- [ ] 스토어 정보: 스크린샷, 데이터 보안/App Privacy, 심사용 테스트 번호(010-1234-1234 / 123456)
- [ ] 리디자인 QA 후 `main` 병합
- [ ] Functions 빌드 이미지 정리 경고 확인 (Artifact Registry)

---

## 핵심 코드 패턴

### 데이터 플로우
```
사용자 액션 → Firestore에만 쓰기 → 실시간 리스너 → Drift upsert/delete → Drift Stream → UI
                                   └→ Cloud Functions 트리거 → 파트너 FCM
```

### 회원 탈퇴 순서 (`AuthNotifier.deleteAccount`)
1. Apple 계정이면 Apple 재로그인 → `revokeTokenWithAuthorizationCode`
2. FCM 토큰 삭제
3. Cloud Function `deleteAccount` 호출 — 커플 문서를 일정보다 먼저 삭제(파트너 알림 폭주 방지), 파트너 `coupleId` 정리, 프로필·Auth 삭제
4. 카카오 unlink, Google disconnect
5. Drift 데이터 + 동기화 시각 삭제

### 서명 분기 (android/app/build.gradle)
```groovy
signingConfig keystorePropertiesFile.exists() ? signingConfigs.release : signingConfigs.debug
```
Codemagic에서는 `CM_KEYSTORE_*` 환경변수로 `key.properties`를 생성.

### 커플/솔로 분기
```dart
final couple = coupleAsync.valueOrNull;
if (couple != null && couple.isConnected) { /* combined */ } else { /* personal */ }
```
