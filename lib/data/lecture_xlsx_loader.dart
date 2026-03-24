import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

class LectureRow {
  final String dept;     // 학과/전공
  final String code;     // 과목코드
  final String name;     // 과목명
  final String professor;// 교수
  final String day;      // 요일 (월/화/수/목/금 or 1~7)
  final String start;    // 시작 (HH:mm)
  final String end;      // 끝 (HH:mm)
  final String room;     // 강의실
  final String rawTime;  // 원본 시간표 문자열

  const LectureRow({
    required this.dept,
    required this.code,
    required this.name,
    required this.professor,
    required this.day,
    required this.start,
    required this.end,
    required this.room,
    required this.rawTime,
  });
}

class LectureXlsxLoader {
  // ✅ 엑셀에서 흔히 쓰는 컬럼명 후보들(자동 매핑)
  static const _deptKeys = ['학과', '전공', '개설학과', '소속', 'department', 'dept'];
  static const _codeKeys = ['과목코드', '학수번호', '교과목코드', 'code'];
  static const _nameKeys = ['과목명', '교과목명', '강의명', 'name', 'title'];
  static const _profKeys = ['교수', '담당교수', '교원명', 'professor', 'instructor'];
  static const _timeKeys = ['시간', '강의시간', '요일시간', 'time', 'schedule'];
  static const _dayKeys  = ['요일', 'day'];
  static const _startKeys= ['시작', 'start', 'startTime'];
  static const _endKeys  = ['끝', 'end', 'endTime'];
  static const _roomKeys = ['강의실', '강의실명', 'room', 'location'];

  static Future<List<LectureRow>> loadFromAsset(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final data = bytes.buffer.asUint8List();
    return _parse(data);
  }

  static List<LectureRow> _parse(Uint8List data) {
    final excel = Excel.decodeBytes(data);

    // ✅ 첫 번째 시트를 사용 (필요하면 시트명 지정 가능)
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName];
    if (sheet == null || sheet.rows.isEmpty) return const [];

    // ✅ 1행: 헤더로 가정
    final headerRow = sheet.rows.first;
    final headers = headerRow.map((c) => (c?.value?.toString() ?? '').trim()).toList();

    int idxOf(List<String> keys) {
      for (int i = 0; i < headers.length; i++) {
        final h = headers[i];
        if (h.isEmpty) continue;
        for (final k in keys) {
          if (h.toLowerCase() == k.toLowerCase()) return i;
          // 포함 매칭도 허용 (예: "개설학과(전공)" 같은 경우)
          if (h.toLowerCase().contains(k.toLowerCase())) return i;
        }
      }
      return -1;
    }

    final deptIdx = idxOf(_deptKeys);
    final codeIdx = idxOf(_codeKeys);
    final nameIdx = idxOf(_nameKeys);
    final profIdx = idxOf(_profKeys);
    final timeIdx = idxOf(_timeKeys);
    final dayIdx  = idxOf(_dayKeys);
    final startIdx= idxOf(_startKeys);
    final endIdx  = idxOf(_endKeys);
    final roomIdx = idxOf(_roomKeys);

    String cellAt(List<Data?> row, int idx) {
      if (idx < 0 || idx >= row.length) return '';
      return (row[idx]?.value?.toString() ?? '').trim();
    }

    // 시간 파싱(아주 단순 버전: "월 09:00~10:15" / "월09:00-10:15" / "1 09:00~10:15" 등)
    Map<String, String> parseDayStartEnd(String raw) {
      final s = raw.replaceAll(' ', '');
      // 요일 추출
      String day = '';
      const days = ['월','화','수','목','금','토','일'];
      for (final d in days) {
        if (s.contains(d)) { day = d; break; }
      }
      if (day.isEmpty) {
        // 숫자 요일도 지원(1~7)
        final m = RegExp(r'(^|[^0-9])([1-7])([^0-9]|$)').firstMatch(s);
        if (m != null) day = m.group(2) ?? '';
      }

      // 시간 추출
      final tm = RegExp(r'(\d{1,2}:\d{2}).*?(\d{1,2}:\d{2})').firstMatch(s);
      final start = tm?.group(1) ?? '';
      final end = tm?.group(2) ?? '';
      return {'day': day, 'start': start, 'end': end};
    }

    final out = <LectureRow>[];

    // ✅ 2행부터 데이터
    for (int r = 1; r < sheet.rows.length; r++) {
      final row = sheet.rows[r];

      final dept = cellAt(row, deptIdx);
      final code = cellAt(row, codeIdx);
      final name = cellAt(row, nameIdx);
      final prof = cellAt(row, profIdx);
      final room = cellAt(row, roomIdx);

      String rawTime = '';
      String day = '';
      String start = '';
      String end = '';

      if (timeIdx >= 0) {
        rawTime = cellAt(row, timeIdx);
        final parsed = parseDayStartEnd(rawTime);
        day = parsed['day'] ?? '';
        start = parsed['start'] ?? '';
        end = parsed['end'] ?? '';
      } else {
        day = cellAt(row, dayIdx);
        start = cellAt(row, startIdx);
        end = cellAt(row, endIdx);
        rawTime = '$day $start~$end';
      }

      // 최소 필드가 없으면 스킵
      if (dept.isEmpty && name.isEmpty) continue;

      out.add(
        LectureRow(
          dept: dept.isEmpty ? '미분류' : dept,
          code: code,
          name: name,
          professor: prof,
          day: day,
          start: start,
          end: end,
          room: room,
          rawTime: rawTime,
        ),
      );
    }

    return out;
  }
}