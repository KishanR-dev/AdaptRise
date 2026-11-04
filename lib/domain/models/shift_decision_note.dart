enum ShiftDecisionRule {
  caseAOverslept,
  caseB1OnTimeRamp,
  caseB1GoalReached,
  caseB2aEarlyFullRest,
  caseB2bEarlyShortRest,
  caseCLateOnsetOverride,
}

class ShiftDecisionNote {
  final ShiftDecisionRule rule;
  final int shiftMinutes;
  final int deltaOversleepMinutes;
  final String note;

  const ShiftDecisionNote({
    required this.rule,
    required this.shiftMinutes,
    required this.deltaOversleepMinutes,
    required this.note,
  });

  @override
  String toString() =>
      'ShiftDecisionNote(rule: $rule, shiftMinutes: $shiftMinutes, delta: $deltaOversleepMinutes, note: "$note")';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftDecisionNote &&
          runtimeType == other.runtimeType &&
          rule == other.rule &&
          shiftMinutes == other.shiftMinutes &&
          deltaOversleepMinutes == other.deltaOversleepMinutes &&
          note == other.note;

  @override
  int get hashCode =>
      rule.hashCode ^
      shiftMinutes.hashCode ^
      deltaOversleepMinutes.hashCode ^
      note.hashCode;
}
