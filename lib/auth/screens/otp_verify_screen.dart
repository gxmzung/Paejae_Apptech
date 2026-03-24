import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:apptech_flutter/app/root/root_screen.dart';
import 'package:apptech_flutter/auth/state/auth_state.dart';
import 'package:apptech_flutter/auth/screens/student_profile_screen.dart';

class OtpVerifyArgs {
  final String email;
  final bool isLogin;

  const OtpVerifyArgs({
    required this.email,
    required this.isLogin,
  });
}

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.args,
  });

  static const routeName = '/auth/otp';

  final OtpVerifyArgs args;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  String? _localError;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _codeFocusNode.requestFocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInit) return;
    _didInit = true;

    final auth = context.read<AuthState>();
    auth.clearError();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthState>();
    final code = _codeController.text.trim();

    setState(() {
      _localError = null;
    });

    if (code.length != 6) {
      setState(() {
        _localError = '인증번호 6자리를 입력해 주세요.';
      });
      return;
    }

    final result = await auth.verifyOtp(
      email: widget.args.email,
      code: code,
      isLogin: widget.args.isLogin,
    );

    if (!mounted) return;

    if (result == null) {
      return;
    }

    if (result.isNewUser) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        StudentProfileScreen.routeName,
            (route) => false,
      );
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      RootScreen.routeName,
          (route) => false,
    );
  }

  Future<void> _resend() async {
    final auth = context.read<AuthState>();
    setState(() {
      _localError = null;
    });

    final ok = await auth.resendOtp();
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('인증번호를 다시 보냈습니다. 메일함을 확인해 주세요.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, auth, _) {
        final isLoading = auth.isLoading;
        final errorText = _localError ?? auth.errorMessage;

        return Scaffold(
          appBar: AppBar(
            title: const Text('이메일 인증'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.args.isLogin ? '로그인을 위해 인증이 필요해요' : '회원가입을 위해 인증이 필요해요',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.args.email} 로 전송된 6자리 인증번호를 입력해 주세요.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _codeController,
                      focusNode: _codeFocusNode,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      autofocus: true,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: '인증번호',
                        hintText: '예: 123456',
                        counterText: '',
                        prefixIcon: const Icon(Icons.verified_user_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '메일이 안 보이면 스팸함이나 프로모션함도 확인해 주세요.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (errorText != null && errorText.trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          errorText,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (errorText != null && errorText.trim().isNotEmpty)
                      const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                            : const Text('인증 확인'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _resend,
                        child: const Text('인증번호 다시 보내기'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('이메일 다시 입력하기'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}