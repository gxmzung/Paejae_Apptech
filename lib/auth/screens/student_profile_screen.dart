import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:apptech_flutter/app/root/root_screen.dart';
import 'package:apptech_flutter/auth/state/auth_state.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class StudentProfileScreen extends StatefulWidget {
  static const routeName = '/auth/profile';

  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();

  String? _entranceYear;
  String? _department;
  String? _localError;

  final entranceYears = List.generate(8, (i) {
    final year = DateTime.now().year - i;
    return '$year';
  });

  final departments = const [
    '컴퓨터공학과',
    '소프트웨어공학과',
    '정보보안학과',
    '게임공학과',
    '전기전자공학과',
    '드론로봇공학과',
    '스마트배터리학과',
    '기타',
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  String? _nicknameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '닉네임을 입력해 주세요.';
    }

    final v = value.trim();
    if (v.length < 2) return '닉네임은 2자 이상이어야 해요.';
    if (v.length > 12) return '닉네임은 12자 이하로 입력해 주세요.';

    final invalid = RegExp(r'[^a-zA-Z0-9가-힣_]');
    if (invalid.hasMatch(v)) {
      return '특수문자와 공백은 사용할 수 없어요. (_ 허용)';
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() == true;
    if (!valid || _entranceYear == null || _department == null) {
      setState(() {
        _localError = '모든 항목을 채워 주세요.';
      });
      return;
    }

    final auth = context.read<AuthState>();

    final ok = await auth.completeProfile(
      nickname: _nicknameController.text.trim(),
      department: _department!,
      entranceYear: int.tryParse(_entranceYear!),
    );

    if (!mounted) return;
    if (!ok) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      RootScreen.routeName,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Consumer<AuthState>(
      builder: (context, auth, _) {
        final isLoading = auth.isLoading;
        final errorText = _localError ?? auth.errorMessage;
        final email = auth.currentUser?.email ?? '';

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.paejaeBlue.withOpacity(0.10),
                        Colors.white,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Opacity(
                      opacity: 0.20,
                      child: Image.asset(
                        'assets/brand/paejae_logo.png',
                        width: 280,
                        height: 280,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.school_rounded,
                          size: 180,
                          color: AppColors.paejaeBlue.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(22, 22, 22, 24 + bottomInset),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '프로필 입력',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '회원가입이 완료됐어요. 시작하려면 최소 정보만 입력해 주세요.',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.62),
                            height: 1.3,
                          ),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            email,
                            style: const TextStyle(
                              color: AppColors.paejaeBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        _CardField(
                          child: TextFormField(
                            controller: _nicknameController,
                            textInputAction: TextInputAction.next,
                            enabled: !isLoading,
                            decoration: const InputDecoration(
                              labelText: '닉네임',
                              hintText: '특수문자/공백 금지 (_ 허용)',
                              prefixIcon: Icon(Icons.person_rounded),
                            ),
                            validator: _nicknameValidator,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CardField(
                          child: DropdownButtonFormField<String>(
                            value: _entranceYear,
                            decoration: const InputDecoration(
                              labelText: '입학년도',
                              prefixIcon: Icon(Icons.calendar_month_rounded),
                            ),
                            items: entranceYears
                                .map(
                                  (y) => DropdownMenuItem(
                                value: y,
                                child: Text('$y학번'),
                              ),
                            )
                                .toList(),
                            onChanged: isLoading
                                ? null
                                : (v) => setState(() => _entranceYear = v),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _CardField(
                          child: DropdownButtonFormField<String>(
                            value: _department,
                            decoration: const InputDecoration(
                              labelText: '학과',
                              prefixIcon: Icon(Icons.apartment_rounded),
                            ),
                            items: departments
                                .map(
                                  (d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: isLoading
                                ? null
                                : (v) => setState(() => _department = v),
                          ),
                        ),
                        if (errorText != null && errorText.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
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
                        ],
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.paejaeBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              '완료하고 시작하기',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _CardField extends StatelessWidget {
  final Widget child;

  const _CardField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}