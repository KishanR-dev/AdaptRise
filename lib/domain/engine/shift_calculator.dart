import 'package:adaptrise/domain/models/shift_decision_note.dart';

class ShiftCalculator {
  const ShiftCalculator();

  /// Formats signed shift badge (e.g., "+30m", "-15m", "0m").
  static String formatShiftBadge(int shiftMinutes) {
    if (shiftMinutes > 0) {
      return '+${shiftMinutes}m';
    } else if (shiftMinutes < 0) {
      return '${shiftMinutes}m';
    }
    return '0m';
  }

  /// Formats minutes from midnight into 24-hour clock string "HH:mm".
  static String formatClockMinutes(int minutesFromMidnight) {
    final h = (minutesFromMidnight ~/ 60) % 24;
    final m = minutesFromMidnight % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// Generates a human-readable explanation and parameter tags for Case A (Overslept).
  static ShiftDecisionNote generateCaseANote({
    required int deltaOversleepMinutes,
    required int shiftMinutes,
  }) {
    final explanation =
        'Overslept by $deltaOversleepMinutes min. Eased target wake time by +$shiftMinutes min to prevent circadian disruption.';
    final tags = <String, String>{
      'rule': 'CASE_A',
      'overslept': '+${deltaOversleepMinutes}m',
      'shift': '+${shiftMinutes}m',
    };

    return ShiftDecisionNote(
      rule: ShiftDecisionRule.caseAOverslept,
      shiftMinutes: shiftMinutes,
      deltaOversleepMinutes: deltaOversleepMinutes,
      note: explanation,
      tags: tags,
    );
  }

  /// Generates note for Case B.1 when ramping toward goal.
  static ShiftDecisionNote generateCaseB1RampNote({
    required int deltaOversleepMinutes,
    required int shiftMinutes,
    required int goalWakeMinutesFromMidnight,
  }) {
    final goalFormatted = formatClockMinutes(goalWakeMinutesFromMidnight);
    final explanation =
        'Target met. Advancing wake time by ${shiftMinutes}m toward goal of $goalFormatted.';
    final tags = <String, String>{
      'rule': 'CASE_B1_RAMP',
      'delta': '${deltaOversleepMinutes}m',
      'shift': '${shiftMinutes}m',
      'goal': goalFormatted,
    };

    return ShiftDecisionNote(
      rule: ShiftDecisionRule.caseB1OnTimeRamp,
      shiftMinutes: shiftMinutes,
      deltaOversleepMinutes: deltaOversleepMinutes,
      note: explanation,
      tags: tags,
    );
  }

  /// Generates note for Case B.1 when goal is already reached.
  static ShiftDecisionNote generateCaseB1GoalReachedNote({
    required int deltaOversleepMinutes,
    required int goalWakeMinutesFromMidnight,
  }) {
    final goalFormatted = formatClockMinutes(goalWakeMinutesFromMidnight);
    final explanation =
        'Goal wake time already reached and maintained at $goalFormatted.';
    final tags = <String, String>{
      'rule': 'CASE_B1_MAINTAINED',
      'delta': '${deltaOversleepMinutes}m',
      'shift': '0m',
      'goal': goalFormatted,
    };

    return ShiftDecisionNote(
      rule: ShiftDecisionRule.caseB1GoalReached,
      shiftMinutes: 0,
      deltaOversleepMinutes: deltaOversleepMinutes,
      note: explanation,
      tags: tags,
    );
  }

  /// Generates note for Case B.2a (Spontaneous early wake with full rest).
  static ShiftDecisionNote generateCaseB2aNote({
    required int deltaOversleepMinutes,
    required int shiftMinutes,
    required int actualDurationMinutes,
  }) {
    final hoursRest = (actualDurationMinutes / 60.0).toStringAsFixed(1);
    final explanation =
        'Spontaneous early wake with full rest ($hoursRest hrs). Advancing wake target by ${shiftMinutes}m toward goal.';
    final tags = <String, String>{
      'rule': 'CASE_B2A',
      'delta': '${deltaOversleepMinutes}m',
      'rest': '${hoursRest}h',
      'shift': '${shiftMinutes}m',
    };

    return ShiftDecisionNote(
      rule: ShiftDecisionRule.caseB2aEarlyFullRest,
      shiftMinutes: shiftMinutes,
      deltaOversleepMinutes: deltaOversleepMinutes,
      note: explanation,
      tags: tags,
    );
  }

  /// Generates note for Case B.2b (Early wake with short rest/disturbance).
  static ShiftDecisionNote generateCaseB2bNote({
    required int deltaOversleepMinutes,
    required int shiftMinutes,
    required int actualDurationMinutes,
  }) {
    final explanation =
        'Early wake recorded with short sleep (<7h). Applied standard gentle ramp (${shiftMinutes}m) to protect sleep reserve.';
    final tags = <String, String>{
      'rule': 'CASE_B2B',
      'delta': '${deltaOversleepMinutes}m',
      'duration': '${actualDurationMinutes}m',
      'shift': '${shiftMinutes}m',
    };

    return ShiftDecisionNote(
      rule: ShiftDecisionRule.caseB2bEarlyShortRest,
      shiftMinutes: shiftMinutes,
      deltaOversleepMinutes: deltaOversleepMinutes,
      note: explanation,
      tags: tags,
    );
  }

  /// Generates note for Case C (Delayed sleep onset override).
  static ShiftDecisionNote generateCaseCNote({
    required int deltaOversleepMinutes,
    required int shiftMinutes,
    required DateTime sleepOnsetTime,
    required int minSleepDurationMinutes,
  }) {
    final onsetFormatted =
        '${sleepOnsetTime.hour.toString().padLeft(2, '0')}:${sleepOnsetTime.minute.toString().padLeft(2, '0')}';
    final explanation =
        'Sleep onset was late ($onsetFormatted). Adjusted wake target by +${shiftMinutes}m to protect baseline sleep duration.';
    final tags = <String, String>{
      'rule': 'CASE_C',
      'onset': onsetFormatted,
      'shift': '+${shiftMinutes}m',
      'min_duration': '${minSleepDurationMinutes}m',
    };

    return ShiftDecisionNote(
      rule: ShiftDecisionRule.caseCLateOnsetOverride,
      shiftMinutes: shiftMinutes,
      deltaOversleepMinutes: deltaOversleepMinutes,
      note: explanation,
      tags: tags,
    );
  }
}
