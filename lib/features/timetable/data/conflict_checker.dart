import 'recommend_templates.dart';

class TTConflict {
  final TTSlot a;
  final TTSlot b;
  const TTConflict(this.a, this.b);
}

/// 같은 요일(day)에서 시간이 겹치면 충돌
List<TTConflict> findConflicts(List<TTSlot> slots) {
  final conflicts = <TTConflict>[];

  // day별로 모아 정렬
  final byDay = <int, List<TTSlot>>{};
  for (final s in slots) {
    byDay.putIfAbsent(s.day, () => []).add(s);
  }

  for (final day in byDay.keys) {
    final list = byDay[day]!..sort((x, y) => x.start.compareTo(y.start));

    for (int i = 0; i < list.length; i++) {
      for (int j = i + 1; j < list.length; j++) {
        final a = list[i];
        final b = list[j];

        // 겹침 조건: a.start <= b.end && b.start <= a.end
        final overlap = a.start <= b.end && b.start <= a.end;
        if (overlap) conflicts.add(TTConflict(a, b));
      }
    }
  }

  return conflicts;
}