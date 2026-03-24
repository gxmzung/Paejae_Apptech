// lib/features/timetable/data/lecture_xlsx_loader.dart
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

import 'package:excel/excel.dart';

import '../domain/lecture_row.dart';
import '../domain/lecture_parse.dart';

class LectureXlsxLoader {
  static Future<List<LectureRow>> loadFromAsset(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    return compute(_parseXlsxIsolate, bytes.buffer.asUint8List());
  }

  static List<LectureRow> _parseXlsxIsolate(Uint8List bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) return const [];

      // 첫 시트 사용(필요하면 감정님이 원하는 시트명으로 바꿔도 됨)
      final sheetName = excel.tables.keys.first;
      final table = excel.tables[sheetName];
      if (table == null) return const [];

      if (table.rows.isEmpty) return const [];

      // 헤더 인덱스 찾기(엑셀 헤더명이 조금 달라도 최대한 맞춤)
      final header = table.rows.first.map((c) => (c?.value?.toString() ?? '').trim()).toList();

      int idxOf(List<String> keys) {
        for (int i = 0; i < header.length; i++) {
          final h = header[i];
          for (final k in keys) {
            if (h == k || h.contains(k)) return i;
          }
        }
        return -1;
      }

      final iCode = idxOf(['과목코드']);
      final iName = idxOf(['과목명']);
      final iDiv = idxOf(['이수구분', '분반', '구분']);
      final iProf = idxOf(['담당교수', '교수']);
      final iRoomTime = idxOf(['강의실/강의시간', '강의시간', '강의실']);

      // 최소 필드가 없으면 빈 리스트(크래시 방지)
      if (iName < 0) return const [];

      final out = <LectureRow>[];

      for (int r = 1; r < table.rows.length; r++) {
        final row = table.rows[r];

        String cell(int idx) {
          if (idx < 0 || idx >= row.length) return '';
          return (row[idx]?.value?.toString() ?? '').trim();
        }

        final name = cell(iName);
        if (name.isEmpty) continue;

        final code = cell(iCode);
        final div = cell(iDiv);
        final prof = cell(iProf);
        final roomTimeRaw = cell(iRoomTime);

        // ✅ 핵심 파싱
        final meetings = LectureParse.parseMeetingsFromRoomTimeCell(roomTimeRaw);

        // 대표 room(첫 meeting room 우선)
        final room = meetings.isNotEmpty
            ? (meetings.first.room)
            : '';

        // day/time는 fallback 표시용으로만 유지(지금 엑셀 형태에선 대부분 비어도 OK)
        out.add(LectureRow(
          code: code,
          name: name,
          division: div,
          professor: prof,
          roomTimeRaw: roomTimeRaw,
          room: room,
          day: '',
          time: '',
          meetings: meetings,
        ));
      }

      return out;
    } catch (_) {
      // 어떤 엑셀이 와도 앱이 죽지 않게
      return const [];
    }
  }
}