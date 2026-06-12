/// 디버그 모드 설정
enum DebugMode {
  /// 실제 인증 플로우 사용 (Firebase)
  production('Production'),

  /// 로그인 스킵 (개발용)
  skipAuth('Skip Auth'),

  /// 목업 데이터 사용 (로컬 DB만)
  mockData('Mock Data');

  const DebugMode(this.label);
  final String label;
}
