import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptech_flutter/features/missions/models/mission.dart';

class MissionRepo {
  static const String _kDay = 'missions_day_yyyymmdd_v1';
  static const String _kMissions = 'missions_today_v1';

  /// feature 완료 플래그 저장 키 prefix
  static const String _kFeatureDonePrefix = 'missions_feature_done_';

  static String _yyyymmdd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y$m$day';
  }

  static String get todayKey => _yyyymmdd(DateTime.now());

  // ✅ 랜덤 미션 풀 (원하는 만큼 추가 가능)
  static const List<MissionTemplate> pool = [
    MissionTemplate(
      id: 'steps_3k',
      type: MissionType.steps,
      title: '3,000걸음 달성',
      desc: '교내 산책 한 바퀴만 돌아도 달성!',
      reward: 20,
      targetSteps: 3000,
    ),
    MissionTemplate(
      id: 'steps_5k',
      type: MissionType.steps,
      title: '5,000걸음 달성',
      desc: '오늘은 조금 더 걸어보자',
      reward: 35,
      targetSteps: 5000,
    ),
    MissionTemplate(
      id: 'steps_8k',
      type: MissionType.steps,
      title: '8,000걸음 달성',
      desc: '난이도 상! 하지만 보상도 큼',
      reward: 60,
      targetSteps: 8000,
    ),
    MissionTemplate(
      id: 'open_map',
      type: MissionType.openFeature,
      title: '교내 지도 한 번 열기',
      desc: '길찾기/POI 확인하러 들어가보자',
      reward: 15,
      featureKey: 'campus_map',
    ),
    MissionTemplate(
      id: 'open_empty',
      type: MissionType.openFeature,
      title: '빈 강의실 확인하기',
      desc: '강의실 탐색 기능을 써보자',
      reward: 15,
      featureKey: 'empty_room',
    ),
    MissionTemplate(
      id: 'open_points',
      type: MissionType.openFeature,
      title: '포인트 내역 확인',
      desc: '오늘 받은 포인트가 기록돼 있어',
      reward: 10,
      featureKey: 'points_history',
    ),
    MissionTemplate(
      id: 'manual_water',
      type: MissionType.manual,
      title: '물 1잔 마시기',
      desc: '작게 시작해서 꾸준하게',
      reward: 10,
    ),
    MissionTemplate(
      id: 'manual_stretch',
      type: MissionType.manual,
      title: '스트레칭 1분',
      desc: '목/어깨 풀기',
      reward: 10,
    ),
  ];

  /// 오늘 미션 세팅(없거나 날짜 바뀌면 새로 뽑음)
  static Future<void> ensureToday(SharedPreferences sp) async {
    final savedDay = sp.getString(_kDay) ?? '';
    if (savedDay == todayKey) return;

    await sp.setString(_kDay, todayKey);

    // feature 완료 플래그 리셋(오늘 기준)
    for (final t in pool) {
      if (t.type == MissionType.openFeature && t.featureKey != null) {
        await sp.remove(_kFeatureDonePrefix + t.featureKey!);
      }
    }

    final rnd = Random(DateTime.now().millisecondsSinceEpoch);

    // 3개: steps 1개 + 나머지 2개
    final stepPool =
    pool.where((e) => e.type == MissionType.steps).toList()..shuffle(rnd);
    final otherPool =
    pool.where((e) => e.type != MissionType.steps).toList()..shuffle(rnd);

    final picked = <MissionTemplate>[
      stepPool.first,
      ...otherPool.take(2),
    ];

    final missions = picked.map((t) => DailyMission(t: t)).toList();
    await sp.setString(_kMissions, DailyMission.encodeList(missions));
  }

  static Future<List<DailyMission>> loadTodayMissions(
      SharedPreferences sp) async {
    await ensureToday(sp);

    final raw = sp.getString(_kMissions);
    if (raw == null || raw.isEmpty) return const [];

    final list = DailyMission.decodeList(raw);

    // featureDone 반영
    return list.map((m) {
      if (m.t.type == MissionType.openFeature && m.t.featureKey != null) {
        final done = sp.getBool(_kFeatureDonePrefix + m.t.featureKey!) ?? false;
        return m.copyWith(featureDone: done);
      }
      return m;
    }).toList();
  }

  static Future<void> saveTodayMissions(
      SharedPreferences sp, List<DailyMission> missions) async {
    await sp.setString(_kMissions, DailyMission.encodeList(missions));
  }

  /// manual 미션 체크 토글
  static Future<List<DailyMission>> toggleManual(
      SharedPreferences sp, DailyMission target) async {
    final list = await loadTodayMissions(sp);

    final next = list.map((m) {
      if (m.t.id != target.t.id) return m;
      if (m.t.type != MissionType.manual) return m;
      return m.copyWith(manualDone: !m.manualDone);
    }).toList();

    await saveTodayMissions(sp, next);
    return next;
  }

  /// 기능 열었을 때(openFeature) 완료 처리
  static Future<void> markFeatureOpened(
      SharedPreferences sp, String featureKey) async {
    await ensureToday(sp);
    await sp.setBool(_kFeatureDonePrefix + featureKey, true);

    final list = await loadTodayMissions(sp);
    final next = list.map((m) {
      if (m.t.type == MissionType.openFeature && m.t.featureKey == featureKey) {
        return m.copyWith(featureDone: true);
      }
      return m;
    }).toList();

    await saveTodayMissions(sp, next);
  }

  /// 미션 보상 수령(완료된 미션만, 중복수령 방지)
  static Future<({List<DailyMission> missions, int? gained})> claim(
      SharedPreferences sp,
      DailyMission target, {
        required int stepsToday,
      }) async {
    final list = await loadTodayMissions(sp);

    int? gained;
    final next = list.map((m) {
      if (m.t.id != target.t.id) return m;
      if (m.claimed) return m;

      final done = m.isDone(stepsToday: stepsToday);
      if (!done) return m;

      gained = m.t.reward;
      return m.copyWith(claimed: true);
    }).toList();

    await saveTodayMissions(sp, next);
    return (missions: next, gained: gained);
  }
}
