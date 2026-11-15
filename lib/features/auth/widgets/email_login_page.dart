import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// 이메일 로그인·회원가입 화면 (로그인 화면의 '이메일로 시작하기')
class EmailLoginPage extends ConsumerStatefulWidget {
  const EmailLoginPage({super.key});

  @override
  ConsumerState<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends ConsumerState<EmailLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUpMode = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 비밀번호를 입력해 주세요')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authProvider.notifier);
      if (_isSignUpMode) {
        await auth.signUpWithEmail(email, password);
      } else {
        await auth.signInWithEmail(email, password);
      }
      // 로그인되면 라우터가 오늘 일정 탭으로 보낸다
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
      appBar: AppBar(),
      body: CozyBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              Text(
                _isSignUpMode ? '이메일로 가입하기' : '이메일로 로그인',
                style: AppTheme.display(30),
              ),
              const SizedBox(height: 2),
              Text(
                _isSignUpMode
                    ? '가입하면 귀여운 닉네임이 자동으로 만들어져요.'
                    : '가입한 이메일과 비밀번호를 입력해 주세요.',
                style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
              AppSpacing.gapLg,
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  hintText: '이메일',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              AppSpacing.gapSm,
              TextField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(
                  hintText: '비밀번호',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              AppSpacing.gapLg,
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isSignUpMode ? '가입하기' : '로그인',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              AppSpacing.gapSm,
              TextButton(
                onPressed: () => setState(() => _isSignUpMode = !_isSignUpMode),
                child: Text(
                  _isSignUpMode ? '이미 계정이 있어요 · 로그인' : '계정이 없어요 · 회원가입',
                  style: const TextStyle(color: AppColors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
