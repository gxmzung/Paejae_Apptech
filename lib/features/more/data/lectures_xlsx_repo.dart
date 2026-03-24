import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../model/lecture.dart';

class LecturesXlsxRepo {
  /// assets/data/lectures.xlsx 읽어서 과목 리스트로 변환
  static Future<List<Lecture>> loadFromAssets({
    String assetPath = 'assets/data/lectures.xlsx',
  }) async {
    final bytes = await rootBundle.load(assetPath);
    final data = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    final excel = Excel.decodeBytes(data);

    // 첫번째 시트 사용 (필요하면 시트명 고정해도 됨)
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName];
    if (sheet == null || sheet.rows.isEmpty) return [];

    // 헤더에서 컬럼 인덱스 찾기 (엑셀 컬럼 순서가 바뀌어도 견고하게)
    final header = sheet.rows.first.map((c) => (c?.value?.toString() ?? '').trim()).toList();

    int idxOf(String name) => header.indexWhere((h) => h.replaceAll(' ', '') == name.replaceAll(' ', ''));

    final idxType = idxOf('이수구분');
    final idxCode = idxOf('과목코드');
    final idxName = idxOf('과목명');
    final idxCredit = idxOf('학점');

    // 안전장치: 못 찾으면 대략적인 기본 위치 fallback (네 파일 기준으로)
    int safe(int i, int fallback) => i >= 0 ? i : fallback;

    final tI = safe(idxType, 0);
    final cI = safe(idxCode, 1);
    final nI = safe(idxName, 2);
    final crI = safe(idxCredit, 6);

    final out = <Lecture>[];

    for (int r = 1; r < sheet.rows.length; r++) {
      final row = sheet.rows[r];
      String cellStr(int i) => (i < row.length ? (row[i]?.value?.toString() ?? '') : '').trim();

      final type = cellStr(tI);
      final code = cellStr(cI);
      final name = cellStr(nI);
      final creditStr = cellStr(crI);

      if (name.isEmpty) continue;

      final credit = int.tryParse(creditStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      out.add(Lecture(
        type: type.isEmpty ? '미분류' : type,
        code: code,
        name: name,
        credit: credit == 0 ? 3 : credit, // 학점이 비어있으면 3으로 기본값
      ));
    }

    return out;
  }
}