# Coupley 💑

> 커플을 위한 실시간 공유 캘린더

연인이 일정을 함께 만들고, 실시간으로 공유하며, 각자의 개인 일정과 함께 관리할 수 있는 Flutter 모바일 앱입니다. 오프라인에서도 끊김 없이 동작하며, 네트워크가 복구되면 자동으로 동기화됩니다.

<br>

## 📱 소개

연인끼리 약속, 기념일, 데이트 일정을 따로 메신저로 주고받는 번거로움을 없애기 위해 만들었습니다. 한 사람이 일정을 추가하면 상대방의 캘린더에 실시간으로 반영되고, 개인 일정과 커플 일정을 색으로 구분해 한눈에 볼 수 있습니다.

- **초대 코드**로 두 사람을 연결
- **개인 / 커플 일정 분리** 및 색상 구분
- **실시간 동기화** (한쪽이 추가하면 상대 화면에 즉시 반영)
- **오프라인 우선** 동작 (비행기 모드에서도 일정 추가 가능)

<br>

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| 🔐 인증 | 이메일/비밀번호 및 Google 로그인. 이메일 가입 시 랜덤 닉네임 자동 생성 |
| 💞 커플 연결 | 6자리 초대 코드를 생성·공유하여 두 사람을 연결 (카카오톡 등으로 공유 가능) |
| 📅 일정 관리 | 일정 추가·수정·삭제, 종일/시간 지정, 설명 입력 |
| 👤 개인 / 커플 구분 | 개인 일정(파랑)과 커플 일정(핑크)을 색상과 뱃지로 구분 |
| 🔄 실시간 동기화 | 커플 일정은 상대방 화면에 실시간 반영 |
| 📝 작성자 표시 | 커플 일정에 누가 만들었는지("나" / 상대 닉네임) 표시 |
| 📡 오프라인 지원 | 네트워크 없이도 일정 추가 가능, 복구 시 자동 동기화 |
| ✏️ 닉네임 변경 | 캘린더 화면에서 바로 닉네임 수정 |

<br>

## 📸 스크린샷

> 스크린샷은 추후 추가 예정입니다.

| 로그인 | 캘린더 | 커플 연결 | 일정 추가 |
|:---:|:---:|:---:|:---:|
| _준비 중_ | _준비 중_ | _준비 중_ | _준비 중_ |

<br>

## 🛠 기술 스택

**프레임워크 & 언어**
- Flutter (Dart)

**상태 관리 & 라우팅**
- `flutter_riverpod` — 상태 관리
- `go_router` — 선언적 라우팅

**데이터 & 백엔드**
- `cloud_firestore` — 원격 데이터베이스 (진실의 원천)
- `firebase_auth` — 인증
- `drift` — 로컬 데이터베이스 (오프라인 캐시 / 미러)

**인증**
- `google_sign_in`, `sign_in_with_apple`

**기타**
- `table_calendar` — 캘린더 UI
- `share_plus` — 초대 코드 공유
- `shared_preferences` — 동기화 시점 저장
- `intl` — 날짜 포맷

<br>

## 🏗 아키텍처

### Feature-first + MVVM

기능별로 폴더를 나누고(`auth`, `calendar`, `couple`), 각 기능 안에서 모델·프로바이더·위젯을 분리했습니다. 공통 로직은 `core/`에 모았습니다.

```
lib/
├─ main.dart                  # Firebase 초기화 + 오프라인 설정
├─ app/                       # 앱 진입점, 라우터
├─ core/
│  ├─ common/                 # 공통 유틸 (간격, 닉네임 생성기)
│  ├─ database/               # Drift 로컬 DB
│  └─ services/               # Firebase, 동기화, 유저, 커플 서비스
└─ features/
   ├─ auth/                   # 인증 (모델 / 프로바이더 / 위젯)
   ├─ calendar/               # 캘린더 (일정 CRUD, 뷰, 위젯)
   └─ couple/                 # 커플 연결 (초대 코드, 연결/해제)
```

### 로컬 우선 + 실시간 동기화

**Firebase를 진실의 원천(source of truth), Drift를 로컬 미러**로 두는 단방향 구조를 채택했습니다.

```
[일정 추가/수정/삭제]
        │
        ▼
   Firebase (Firestore)  ◀── 모든 쓰기는 여기로만
        │
        ▼
   실시간 리스너 (snapshots)
        │
        ▼
   Drift (로컬 DB)  ──▶  화면(UI)
```

- 모든 변경은 **Firebase에만** 기록합니다.
- 화면에 보이는 데이터는 **Drift**에서 읽습니다.
- Firebase의 실시간 리스너가 변경을 감지해 Drift에 반영합니다.
- 이 단방향 흐름 덕분에 "내가 추가한 일정"과 "상대가 추가한 일정"이 동일한 경로로 처리되어 일관성이 유지됩니다.

리스너는 두 갈래로 나눠 각자의 범위만 동기화합니다.
- **커플 일정 리스너** — `coupleId` 기준
- **개인 일정 리스너** — 본인의 `coupleId == null` 일정 기준

<br>

## 💡 기술적 도전과 해결

실제 개발 중 마주친 문제들과 해결 과정을 기록합니다.

### 1. 로컬 우선 + 실시간 동기화에서의 중복·삭제 처리

로컬 캐시와 실시간 리스너를 함께 쓰면 같은 일정이 중복 삽입되거나, 삭제가 반영되지 않는 문제가 생깁니다.

- **중복 방지**: Drift의 `firebaseId`에 unique 제약을 걸고 upsert(onConflict)로 처리해, 같은 일정이 두 번 들어가지 않도록 했습니다.
- **삭제 반영**: 리스너가 받은 Firebase 데이터에 없는 로컬 일정은 삭제 처리하여, 상대가 지운 일정이 내 화면에서도 사라지도록 했습니다.

### 2. Firestore 보안 규칙과 기능의 균형

보안 규칙을 "본인 문서만 접근"으로 짰더니, 정작 필요한 기능이 막히는 문제를 여러 번 만났습니다.

- **작성자 표시**: 커플 일정의 작성자 이름을 보여주려면 상대방의 `users` 문서를 읽어야 하는데 규칙에 막혔습니다(`permission-denied`). 같은 커플 멤버인지 확인하는 `isMyPartner` 함수를 추가해, 커플끼리는 서로의 프로필을 읽을 수 있도록 허용했습니다.
- **연결 해제**: 한 사람이 양쪽의 데이터를 정리하려 하면 "남의 문서 수정 금지" 규칙에 걸립니다. 그래서 **본인 데이터만 정리하고, 상대는 `couples` 문서 삭제를 감지해 스스로 정리**하는 방식으로 바꿨습니다(분산 환경에서의 권한 문제 해결).

### 3. Riverpod `select`로 불필요한 리빌드 제거

닉네임을 변경할 때 캘린더 전체가 다시 그려지며 깜빡이는 문제가 있었습니다. 원인은 여러 프로바이더가 인증 상태 전체를 구독하고 있어서, 이름만 바뀌어도 연쇄적으로 재평가된 것이었습니다.

`ref.watch(authProvider.select((s) => s.userId))`처럼 **필요한 필드만 구독**하도록 바꿔, 닉네임 변경이 캘린더 리빌드로 이어지지 않게 했습니다.

### 4. `skipLoadingOnReload`로 캘린더 깜빡임 개선

날짜를 선택할 때마다 `StreamProvider`가 재평가되며 로딩 인디케이터가 잠깐 나타나 화면이 깜빡였습니다. `AsyncValue.when`에 `skipLoadingOnReload: true`를 적용해, 재로드 중에는 이전 데이터를 유지하도록 하여 부드러운 전환을 만들었습니다.

### 5. 인증 초기화 상태 처리

이미 로그인된 상태로 앱을 켜도 로그인 화면이 잠깐 보였다가 캘린더로 넘어가는 문제가 있었습니다. Firebase가 인증 상태를 복원하는 짧은 시간 동안 "로그아웃"으로 취급된 것이 원인이었습니다.

`AuthState`에 **`isInitializing`(확인 중)** 상태를 추가하고, 라우터가 그동안 스플래시를 유지하도록 하여 로그인 화면 깜빡임을 없앴습니다.

### 6. 오프라인 쓰기와 UI 응답성

Firestore는 오프라인일 때 쓰기 작업의 Future가 서버 확정까지 완료되지 않아, `await`하면 일정 추가 다이얼로그가 닫히지 않는 문제가 있었습니다. 로컬 캐시에는 즉시 반영된다는 특성을 활용해, 쓰기 작업을 `await`하지 않고 `.catchError`로 백그라운드 에러만 로깅하도록 했습니다.

<br>

## 🚀 실행 방법

### 사전 준비

- Flutter SDK
- Firebase 프로젝트 (Authentication, Firestore 활성화)

### 설치

```bash
# 저장소 클론
git clone https://github.com/melkkdev/coupley.git
cd coupley

# 의존성 설치
flutter pub get

# Drift 코드 생성
dart run build_runner build
```

### Firebase 설정

이 저장소에는 보안을 위해 Firebase 설정 파일이 포함되어 있지 않습니다. 직접 생성해야 합니다.

```bash
# FlutterFire CLI로 설정 파일 생성
flutterfire configure
```

다음 파일들이 필요합니다 (`.gitignore`에 의해 제외됨):
- `lib/firebase_options.dart`
- `android/app/google-services.json`

### 실행

```bash
flutter run
```

<br>

## 📂 프로젝트 구조 (상세)

```
lib/
├─ main.dart
├─ app/
│  ├─ app.dart                # MyApp, 동기화 리스너
│  └─ router.dart             # go_router 설정
├─ core/
│  ├─ common/
│  │  ├─ spacing.dart
│  │  └─ nickname_generator.dart
│  ├─ database/
│  │  ├─ drift_database.dart
│  │  └─ database_provider.dart
│  └─ services/
│     ├─ firebase_service.dart
│     ├─ sync_service.dart
│     ├─ realtime_sync_provider.dart
│     ├─ user_service.dart
│     └─ couple_service.dart
└─ features/
   ├─ auth/
   │  ├─ models/              # AuthState, UserProfile
   │  ├─ providers/           # auth_provider
   │  └─ widgets/             # login_page
   ├─ calendar/
   │  ├─ providers/           # calendar_provider
   │  └─ widgets/             # calendar_home, calendar_view,
   │                          #   event_card, add_event_dialog,
   │                          #   greeting_header
   └─ couple/
      ├─ models/              # Couple
      ├─ providers/           # couple_provider
      └─ widgets/             # couple_connect_page
```

<br>

## 👤 만든 사람

- GitHub: [@melkkdev](https://github.com/melkkdev)

<br>

---

<sub>이 프로젝트는 Flutter와 Firebase를 활용한 풀스택 모바일 앱 개발 학습 및 포트폴리오 목적으로 제작되었습니다.</sub>