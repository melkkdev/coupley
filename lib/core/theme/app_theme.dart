import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 앱 전역 팔레트. 색을 바꿀 땐 이 파일만 고치면 된다.
class AppColors {
  AppColors._();

  static const cream = Color(0xFFFFF8F3); // 전체 배경
  static const ink = Color(0xFF3F3532); // 손그림 선, 본문 글자
  static const inkSoft = Color(0xFF85756F); // 보조 글자
  static const line = Color(0xFFF0E2DB); // 카드 테두리, 구분선
  static const coral = Color(0xFFDB5F5A); // 주요 버튼, 선택 상태
  static const rose = Color(0xFFFFB9B3); // 볼터치, 오늘 표시
  static const roseBg = Color(0xFFFFEBE7); // 커플 일정 배경
  static const sky = Color(0xFF5E93BC); // 개인 일정
  static const skyBg = Color(0xFFE6F1F8); // 개인 일정 배경
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
              ? AppColors.coral
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
    );
  }
}
