import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 앱 전역 팔레트. 색을 바꿀 땐 이 파일만 고치면 된다.
class AppColors {
  AppColors._();

  // Readdy 시안(2026-11) 팔레트
  static const cream = Color(0xFFFFFBF2); // 전체 배경
  static const creamDeep = Color(0xFFFCF3E4); // 섹션 배경, 입력칸 묶음
  static const ink = Color(0xFF3A2A21); // 손그림 선, 본문 글자
  static const inkSoft = Color(0xFF847065); // 보조 글자
  static const line = Color(0xFFF3E4D3); // 카드 테두리, 구분선
  static const coral = Color(0xFFF1735C); // 주요 버튼, 선택 상태, 커플 일정
  static const coralDeep = Color(0xFFD95D49); // 코랄 글자 (밝은 배경 위)
  static const rose = Color(0xFFFFAD98); // 볼터치
  static const roseBg = Color(0xFFFFE1D7); // 커플 일정 배경
  static const pink = Color(0xFFF183A7); // 포인트 (하트, 토글)
  static const pinkBg = Color(0xFFFFE5ED); // 안내 상자, 배지 배경
  static const mint = Color(0xFF51B48D); // 개인 일정
  static const mintBg = Color(0xFFDDF5E9); // 개인 일정 배경
}

/// 글꼴 이름. 손글씨는 제목에만 쓰고, 긴 글은 읽기 쉬운 본문체로 쓴다.
class AppFonts {
  AppFonts._();

  static const display = 'Gaegu';
  static const body = 'GowunDodum';
}

class AppTheme {
  AppTheme._();

  static const _radius = 18.0;

  /// 크림 배경 위 상태바: 투명 배경 + 어두운 아이콘
  static const overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Android
    statusBarBrightness: Brightness.light, // iOS
    systemNavigationBarColor: AppColors.cream,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static TextStyle display(double size, {Color color = AppColors.ink}) {
    return TextStyle(
      fontFamily: AppFonts.display,
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.2,
      // 손글씨체 기본 자간이 넓어서 글자 크기에 비례해 좁힌다
      letterSpacing: size * -0.05,
    );
  }

  static ThemeData light() {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.body,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.coral,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: AppColors.ink,
        secondaryContainer: AppColors.roseBg,
        onSecondaryContainer: AppColors.ink,
        outline: AppColors.line,
        surfaceTint: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        systemOverlayStyle: overlayStyle,
        titleTextStyle: display(24),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.ink, width: 1.5),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.inkSoft),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.inkSoft),
        labelStyle: const TextStyle(color: AppColors.inkSoft),
        prefixIconColor: AppColors.inkSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: display(26),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.pink
              : AppColors.line,
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.coral,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.roseBg,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            color: states.contains(WidgetState.selected)
                ? AppColors.coralDeep
                : AppColors.inkSoft,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.coral
                : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}
