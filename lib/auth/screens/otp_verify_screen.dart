import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:apptech_flutter/auth/state/auth_state.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class OtpVerifyArgs {
  final String email;
  final String title;

  const OtpVerifyArgs({
    required this.email,
    required this.title,
  });
}

class OtpVerifyScreen extends StatefulWidget {
  static const routeName = '/auth/otp-verify';

  final OtpVerifyArgs args;

  const OtpVerifyScreen({
    super.key,
    required this.args,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _code = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthState>();
    final code = _code.text.trim();

    setState(() => _localError = null);

    if (code.length != 6) {
      setState(() => _localError = '인증번호 6자리를 입력해 주세요.');
      return;
    }

    try {
      await auth.verifyOtp(
        email: widget.args.email,
        code: code,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, auth, _) {
        final errorText = _localError ?? auth.errorMessage;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F4F4),
          appBar: AppBar(
            title: Text(widget.args.title),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
            children: [
              const Icon(
                Icons.mark_email_read_rounded,
                size: 84,
                color: AppColors.paejaeBlue,
              ),
              const SizedBox(height: 18),
              Text(
                widget.args.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.paejaeBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '학교 이메일로 받은 인증번호를 입력해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '6자리 인증번호',
                  counterText: '',
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
                    '인증 완료',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}