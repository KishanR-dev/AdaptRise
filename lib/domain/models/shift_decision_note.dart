enum ShiftDecisionRule {
  caseAOverslept,
  caseB1OnTimeRamp,
  caseB1GoalReached,
  caseB2aEarlyFullRest,
  caseB2bEarlyShortRest,
  caseCLateOnsetOverride,
}

enum ShiftDirection { forward, backward, neutral }

class ShiftDecisionNote {
  final ShiftDecisionRule rule;
  final int shiftMinutes;
  final int deltaOversleepMinutes;
  final String note;
  final Map<String, String> tags;

  const ShiftDecisionNote({
    required this.rule,
    required this.shiftMinutes,
    required this.deltaOversleepMinutes,
    required this.note,
    this.tags = const {},
  });

  ShiftDirection get direction {
    if (shiftMinutes > 0) return ShiftDirection.forward;
    if (shiftMinutes < 0) return ShiftDirection.backward;
    return ShiftDirection.neutral;
  }

  @override
  String toString() =>
      'ShiftDecisionNote(rule: $rule, shiftMinutes: $shiftMinutes, delta: $deltaOversleepMinutes, note: "$note", tags: $tags)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftDecisionNote &&
          runtimeType == other.runtimeType &&
          rule == other.rule &&
          shiftMinutes == other.shiftMinutes &&
          deltaOversleepMinutes == other.deltaOversleepMinutes &&
          note == other.note &&
          _mapsEqual(tags, other.tags);

  bool _mapsEqual(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      rule.hashCode ^
      shiftMinutes.hashCode ^
      deltaOversleepMinutes.hashCode ^
      note.hashCode ^
      tags.entries.fold(
        0,
        (hash, e) => hash ^ e.key.hashCode ^ e.value.hashCode,
      );
}
