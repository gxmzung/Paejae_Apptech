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
  final _nickname = TextEditingController();

  String? _department;
  String? _entranceYear;
  String? _localError;

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

  List<String> get years {
    final now = DateTime.now().year;
    return List.generate(8, (i) => '${now - i}');
  }

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthState>();

    setState(() => _localError = null);

    if (_nickname.text.trim().length < 2) {
      setState(() => _localError = '닉네임은 2자 이상 입력해 주세요.');
      return;
    }
    if (_department == null || _department!.isEmpty) {
      setState(() => _localError = '학과를 선택해 주세요.');
      return;
    }
    if (_entranceYear == null || _entranceYear!.isEmpty) {
      setState(() => _localError = '입학년도를 선택해 주세요.');
      return;
    }

    try {
      await auth.completeProfile(
        nickname: _nickname.text.trim(),
        department: _department!,
        entranceYear: int.tryParse(_entranceYear!),
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        RootScreen.routeName,
            (route) => false,
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
          appBar: AppBar(
            title: const Text('프로필 입력'),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
            children: [
              Text(
                auth.email ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.paejaeBlue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '인증된 재학생 정보로 프로필을 완료해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _nickname,
                decoration: InputDecoration(
                  hintText: '닉네임',
                  filled: true,
                  fillColor: const Color(0xFFEDEDED),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _department,
                items: departments
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                    .toList(),
                onChanged: auth.isLoading ? null : (v) => setState(() => _department = v),
                decoration: InputDecoration(
                  hintText: '학과 선택',
                  filled: true,
                  fillColor: const Color(0xFFEDEDED),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _entranceYear,
                items: years
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text('$e학번'),
                  ),
                )
                    .toList(),
                onChanged: auth.isLoading ? null : (v) => setState(() => _entranceYear = v),
                decoration: InputDecoration(
                  hintText: '입학년도 선택',
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
        );
      },
    );
  }
}