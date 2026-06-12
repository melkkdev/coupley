import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/common/spacing.dart';
import '../providers/auth_provider.dart';

/// 로그인 페이지
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoading = false;
  // 추가: 이메일 로그인용
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUpMode = false; // false=로그인, true=회원가입

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

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 비밀번호를 입력하세요')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUpMode) {
        await ref.read(authProvider.notifier).signUpWithEmail(email, password);
      } else {
        await ref.read(authProvider.notifier).signInWithEmail(email, password);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade100, Colors.blue.shade100],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고/타이틀
                  const Icon(
                    Icons.calendar_month,
                    size: 100,
                    color: Colors.purple,
                  ),
                  AppSpacing.gapMd,
                  const Text(
                    'Coupley',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  AppSpacing.gapSm,
                  Text(
                    '우리의 특별한 순간을 기록하세요',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  AppSpacing.gapXxl,
                  AppSpacing.gapXl,
                  // ===== 이메일 로그인 폼 =====
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: '이메일',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  AppSpacing.gapSm,
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '비밀번호',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,

                  // 로그인/회원가입 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        _isSignUpMode ? '회원가입' : '로그인',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapSm,

                  // 로그인 ↔ 회원가입 전환
                  TextButton(
                    onPressed: () {
                      setState(() => _isSignUpMode = !_isSignUpMode);
                    },
                    child: Text(
                      _isSignUpMode ? '이미 계정이 있으신가요? 로그인' : '계정이 없으신가요? 회원가입',
                      style: const TextStyle(color: Colors.purple),
                    ),
                  ),
                  AppSpacing.gapMd,

                  // 구분선
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Text(
                          '또는',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  AppSpacing.gapMd,
                  // ===== 여기 아래로 기존 Google 버튼 =====
                  // Google 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: const Icon(Icons.login, size: 24),
                      label: const Text(
                        'Google로 로그인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  // iOS인 경우 Apple 로그인 버튼 표시
                  if (Platform.isIOS) ...[
                    AppSpacing.gapMd,
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleAppleSignIn,
                        icon: const Icon(Icons.apple, size: 24),
                        label: const Text(
                          'Apple로 로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (_isLoading) ...[
                    AppSpacing.gapLg,
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  ],

                  AppSpacing.gapXxl,
                  AppSpacing.gapLg,

                  // 안내 문구
                  Text(
                    '로그인하면 이벤트가\n클라우드에 안전하게 저장됩니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
