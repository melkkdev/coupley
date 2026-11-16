import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cozy/cozy_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// 휴대폰 번호 + SMS 인증 로그인 화면 (로그인 화면의 '휴대폰 번호로 시작하기')
///
/// 1단계: 번호 입력 → 인증번호 받기
/// 2단계: 6자리 인증번호 입력 → 확인. 처음이면 자동 가입된다.
class PhoneLoginPage extends ConsumerStatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  ConsumerState<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends ConsumerState<PhoneLoginPage> {
  static const _resendSeconds = 60;

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  String? _verificationId;
  int? _resendToken;
  bool _isLoading = false;
  int _secondsLeft = 0;
  Timer? _timer;

  bool get _isCodeStep => _verificationId != null;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// 010-1234-5678 / 01012345678 → +821012345678
  String? _toE164(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^01[016789]\d{7,8}$').hasMatch(digits)) return null;
    return '+82${digits.substring(1)}';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _sendCode({bool resend = false}) async {
    final phone = _toE164(_phoneController.text);
    if (phone == null) {
      _showMessage('휴대폰 번호를 정확히 입력해 주세요');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(authProvider.notifier)
          .sendSmsCode(phone, resendToken: resend ? _resendToken : null);
      if (result.autoVerified) return; // 로그인되면 라우터가 오늘 일정 탭으로 보낸다

      setState(() {
        _verificationId = result.verificationId;
        _resendToken = result.resendToken;
        _codeController.clear();
      });
      _startTimer();
      _showMessage('인증번호를 보냈어요');
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showMessage('인증번호 6자리를 입력해 주세요');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .confirmSmsCode(_verificationId!, code);
      // 로그인되면 라우터가 오늘 일정 탭으로 보낸다
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _editPhone() {
    _timer?.cancel();
    setState(() {
      _verificationId = null;
      _secondsLeft = 0;
      _codeController.clear();
    });
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
                _isCodeStep ? '인증번호 입력' : '휴대폰 번호로 시작',
                style: AppTheme.display(30),
              ),
              const SizedBox(height: 2),
              Text(
                _isCodeStep
                    ? '${_phoneController.text}로 보낸 6자리 숫자를 입력해 주세요.'
                    : '처음이면 자동으로 가입되고, 귀여운 닉네임이 만들어져요.',
                style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
              AppSpacing.gapLg,
              TextField(
                controller: _phoneController,
                enabled: !_isCodeStep && !_isLoading,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
                  LengthLimitingTextInputFormatter(13),
                ],
                onSubmitted: (_) => _sendCode(),
                decoration: const InputDecoration(
                  hintText: '010-1234-5678',
                  prefixIcon: Icon(Icons.phone_iphone_rounded),
                ),
              ),
              if (_isCodeStep) ...[
                AppSpacing.gapSm,
                TextField(
                  controller: _codeController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onSubmitted: (_) => _confirmCode(),
                  decoration: InputDecoration(
                    hintText: '인증번호 6자리',
                    prefixIcon: const Icon(Icons.sms_outlined),
                    suffixIcon: _secondsLeft > 0
                        ? Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Center(
                              widthFactor: 1,
                              child: Text(
                                '${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: AppColors.coralDeep,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
              AppSpacing.gapLg,
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_isCodeStep ? _confirmCode : _sendCode),
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
                          _isCodeStep ? '확인' : '인증번호 받기',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              if (_isCodeStep) ...[
                AppSpacing.gapSm,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : _editPhone,
                      child: const Text(
                        '번호 다시 입력',
                        style: TextStyle(color: AppColors.ink),
                      ),
                    ),
                    const Text('·', style: TextStyle(color: AppColors.inkSoft)),
                    TextButton(
                      onPressed: _isLoading || _secondsLeft > 0
                          ? null
                          : () => _sendCode(resend: true),
                      child: Text(
                        _secondsLeft > 0 ? '재전송 ($_secondsLeft초)' : '인증번호 재전송',
                        style: TextStyle(
                          color: _secondsLeft > 0
                              ? AppColors.inkSoft
                              : AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
