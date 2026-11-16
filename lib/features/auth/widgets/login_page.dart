import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/common/spacing.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../providers/auth_provider.dart';

/// 로그인 페이지
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithApple();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleKakaoSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithKakao();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('카카오 로그인 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CozyBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      const CharacterSlot(
                        height: 190,
                        width: 240,
                        asset: 'assets/images/character_login.png',
                      ),
                      AppSpacing.gapLg,
                      Text(
                        'Coupley',
                        style: AppTheme.display(46, color: AppColors.coralDeep),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '둘이 함께 쓰는 커플 공유 캘린더',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      AppSpacing.gapXl,
                      _LoginButton(
                        icon: Icons.phone_iphone_rounded,
                        label: '휴대폰 번호로 시작하기',
                        onPressed: _isLoading
                            ? null
                            : () => context.push(AppRoutes.phoneLogin),
                      ),
                      AppSpacing.gapSm,
                      // 카카오 로그인 버튼은 카카오 디자인 가이드에 맞춰 노란색을 쓴다
                      _LoginButton(
                        icon: Icons.chat_bubble_rounded,
                        label: '카카오톡 계정으로 계속하기',
                        background: const Color(0xFFFEE500),
                        foreground: const Color(0xFF191919),
                        onPressed: _isLoading ? null : _handleKakaoSignIn,
                      ),
                      AppSpacing.gapSm,
                      _LoginButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: 'Google 계정으로 계속하기',
                        background: Colors.white,
                        foreground: AppColors.ink,
                        bordered: true,
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                      ),
                      if (Platform.isIOS) ...[
                        AppSpacing.gapSm,
                        _LoginButton(
                          icon: Icons.apple,
                          label: 'Apple로 계속하기',
                          background: Colors.black,
                          foreground: Colors.white,
                          onPressed: _isLoading ? null : _handleAppleSignIn,
                        ),
                      ],
                      AppSpacing.gapLg,
                      const Text(
                        '로그인하면 일정이 클라우드에 안전하게 저장돼요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 로그인 화면의 둥근 큰 버튼
class _LoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final bool bordered;

  const _LoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.background = AppColors.coral,
    this.foreground = Colors.white,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
            side: bordered
                ? const BorderSide(color: AppColors.line, width: 1.5)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
