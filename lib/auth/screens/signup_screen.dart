import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:apptech_flutter/auth/state/auth_state.dart';
import 'package:apptech_flutter/auth/screens/login_screen.dart';
import 'package:apptech_flutter/auth/screens/otp_verify_screen.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/auth/signup';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _email = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthState>();
    final email = _email.text.trim().toLowerCase();

    setState(() => _localError = null);

    if (email.isEmpty) {
      setState(() => _localError = '학교 이메일을 입력해 주세요.');
      return;
    }

    try {
      await auth.requestOtp(email);

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        OtpVerifyScreen.routeName,
        arguments: OtpVerifyArgs(
          email: email,
          title: '회원가입 인증',
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, auth, _) {
        final errorText = _localError ?? auth.errorMessage;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: auth.isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.verified_user_rounded,
                  size: 96,
                  color: AppColors.paejaeBlue,
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.paejaeNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '학교 이메일 OTP 인증 후 가입할 수 있어요.',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: '예) 2661002@pcu.ac.kr',
                    filled: true,
                    fillColor: const Color(0xFFEDEDED),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (errorText != null && errorText.trim().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      errorText,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.paejaeBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      '인증번호 받기',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('이미 인증 계정이 있나요?'),
                    TextButton(
                      onPressed: auth.isLoading
                          ? null
                          : () {
                        Navigator.pushReplacementNamed(
                          context,
                          LoginScreen.routeName,
                        );
                      },
                      child: const Text(
                        '로그인',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}