import 'dart:convert';

enum MissionType { steps, openFeature, manual }

class MissionTemplate {
  final String id;
  final MissionType type;

  /// 카드 제목/설명
  final String title;
  final String? description;

  /// 보상 포인트
  final int reward;

  /// ✅ 걸음 미션 목표
  final int? targetSteps;

  /// ✅ 기능 열기 미션용 키
  final String? featureKey;

  /// ✅ 수동 체크형 미션 여부(선택)
  final bool manualToggle;

  const MissionTemplate({
    required this.id,
    required this.type,
    required this.title,

    /// ✅ 기존 repo에서 쓰는 desc: 를 그대로 받기(호환)
    String? desc,

    /// ✅ 새 이름도 지원
    String? description,

    required this.reward,

    /// ✅ repo 쪽에서 targetSteps / stepTarget / goalSteps 등 어떤 이름을 쓰든 대응하려면
    ///   여기서는 하나로 통일: targetSteps
    this.targetSteps,

    this.featureKey,
    this.manualToggle = false,
  }) : description = description ?? desc;

  /// ✅ 호환: UI 코드에서 stepTarget 사용
  int? get stepTarget => targetSteps;

  MissionTemplate copyWith({
    String? id,
    MissionType? type,
    String? title,
    String? description,
    int? reward,
    int? targetSteps,
    String? featureKey,
    bool? manualToggle,
  }) {
    return MissionTemplate(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      targetSteps: targetSteps ?? this.targetSteps,
      featureKey: featureKey ?? this.featureKey,
      manualToggle: manualToggle ?? this.manualToggle,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'title': title,
    // 저장은 description로 통일
    'description': description,
    'reward': reward,
    'targetSteps': targetSteps,
    'featureKey': featureKey,
    'manualToggle': manualToggle,
  };

  static MissionTemplate fromMap(Map<String, dynamic> m) {
    final typeStr = (m['type'] ?? 'manual').toString();
    final t = MissionType.values.firstWhere(
          (e) => e.name == typeStr,
      orElse: () => MissionType.manual,
    );

    int? _readInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    final target = _readInt(m['targetSteps']) ??
        _readInt(m['stepTarget']) ??
        _readInt(m['stepsTarget']) ??
        _readInt(m['goalSteps']);

    return MissionTemplate(
      id: (m['id'] ?? '').toString(),
      type: t,
      title: (m['title'] ?? '').toString(),
      // ✅ 과거 desc 키도 읽어줌
      description: m['description']?.toString() ?? m['desc']?.toString(),
      reward: _readInt(m['reward']) ?? 0,
      targetSteps: target,
      featureKey: m['featureKey']?.toString(),
      manualToggle: (m['manualToggle'] == true),
    );
  }
}

class DailyMission {
  final MissionTemplate t;

  /// ✅ 수동 완료(체크형)
  final bool manualDone;

  /// ✅ 기능 열기 완료(openFeature)
  final bool featureDone;

  /// ✅ 보상 수령 여부
  final bool claimed;

  const DailyMission({
    required this.t,
    this.manualDone = false,
    this.featureDone = false,
    this.claimed = false,
  });

  bool isDone({required int stepsToday}) {
    switch (t.type) {
      case MissionType.steps:
        final target = t.stepTarget ?? 0;
        if (target <= 0) return false;
        return stepsToday >= target;
      case MissionType.openFeature:
        return featureDone;
      case MissionType.manual:
        return manualDone;
    }
  }

  DailyMission copyWith({
    MissionTemplate? t,
    bool? manualDone,
    bool? featureDone,
    bool? claimed,
  }) {
    return DailyMission(
      t: t ?? this.t,
      manualDone: manualDone ?? this.manualDone,
      featureDone: featureDone ?? this.featureDone,
      claimed: claimed ?? this.claimed,
    );
  }

  Map<String, dynamic> toMap() => {
    't': t.toMap(),
    'manualDone': manualDone,
    'featureDone': featureDone,
    'claimed': claimed,
  };

  static DailyMission fromMap(Map<String, dynamic> m) => DailyMission(
    t: MissionTemplate.fromMap((m['t'] as Map).cast<String, dynamic>()),
    manualDone: m['manualDone'] == true,
    featureDone: m['featureDone'] == true,
    claimed: m['claimed'] == true,
  );

  static String encodeList(List<DailyMission> list) =>
      jsonEncode(list.map((e) => e.toMap()).toList());

  static List<DailyMission> decodeList(String raw) {
    final arr = (jsonDecode(raw) as List).cast<dynamic>();
    return arr
        .map((e) => DailyMission.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
