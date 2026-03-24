import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:apptech_flutter/auth/state/auth_state.dart';
import 'package:apptech_flutter/auth/screens/login_screen.dart';
import 'package:apptech_flutter/auth/screens/student_profile_screen.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/auth/signup';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  String? _localError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _emailFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthState>();
    final email = _email.text.trim();
    final password = _password.text.trim();
    final passwordConfirm = _passwordConfirm.text.trim();

    setState(() {
      _localError = null;
    });

    if (email.isEmpty) {
      setState(() => _localError = '이메일을 입력해 주세요.');
      return;
    }

    if (password.isEmpty) {
      setState(() => _localError = '비밀번호를 입력해 주세요.');
      return;
    }

    if (password.length < 6) {
      setState(() => _localError = '비밀번호는 6자 이상이어야 해요.');
      return;
    }

    if (password != passwordConfirm) {
      setState(() => _localError = '비밀번호 확인이 일치하지 않아요.');
      return;
    }

    final ok = await auth.signUp(
      email: email,
      password: password,
    );

    if (!mounted) return;
    if (!ok) return;

    Navigator.pushReplacementNamed(
      context,
      StudentProfileScreen.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Consumer<AuthState>(
      builder: (context, auth, _) {
        final isLoading = auth.isLoading;
        final errorText = _localError ?? auth.errorMessage;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/brand/paejae_logo.png',
                          width: 110,
                          height: 110,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.school_rounded,
                            size: 100,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '회원가입',
                          style: t.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.paejaeNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '이메일과 비밀번호로 계정을 만들어요.',
                          style: t.bodyMedium?.copyWith(
                            color: Colors.black.withOpacity(0.62),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    '이메일',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _email,
                    focusNode: _emailFocusNode,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      _passwordFocusNode.requestFocus();
                    },
                    decoration: InputDecoration(
                      hintText: '예) example@pcu.ac.kr',
                      filled: true,
                      fillColor: const Color(0xFFEDEDED),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 22,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '비밀번호',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    focusNode: _passwordFocusNode,
                    enabled: !isLoading,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      _passwordConfirmFocusNode.requestFocus();
                    },
                    decoration: InputDecoration(
                      hintText: '6자 이상 입력',
                      filled: true,
                      fillColor: const Color(0xFFEDEDED),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 22,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '비밀번호 확인',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordConfirm,
                    focusNode: _passwordConfirmFocusNode,
                    enabled: !isLoading,
                    obscureText: _obscurePasswordConfirm,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: '비밀번호 다시 입력',
                      filled: true,
                      fillColor: const Color(0xFFEDEDED),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 22,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePasswordConfirm =
                            !_obscurePasswordConfirm;
                          });
                        },
                        icon: Icon(
                          _obscurePasswordConfirm
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (errorText != null && errorText.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.20),
                        ),
                      ),
                      child: Text(
                        errorText,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 64,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.paejaeBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '이미 계정이 있나요?',
                        style: t.bodyMedium?.copyWith(
                          color: Colors.black.withOpacity(0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          Navigator.pushReplacementNamed(
                            context,
                            LoginScreen.routeName,
                          );
                        },
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.paejaeBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}