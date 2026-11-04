import 'package:adaptrise/domain/models/shift_decision_note.dart';

class EngineResult {
  final DateTime nextTargetWakeTime;
  final ShiftDecisionNote decisionNote;

  const EngineResult({
    required this.nextTargetWakeTime,
    required this.decisionNote,
  });
}

class AdaptiveTargetEngine {
  final int goalWakeMinutesFromMidnight; // e.g. 390 for 06:30
  final int minSleepDurationMinutes; // 420 (7 hours)
  final int maxDailyShiftMinutes; // 30 (Delta_max)
  final int dailyRampMinutes; // 15 (R_ramp)
  final int graceThresholdMinutes; // 10 (epsilon_grace)

  const AdaptiveTargetEngine({
    this.goalWakeMinutesFromMidnight = 390, // 06:30 AM
    this.minSleepDurationMinutes = 420, // 7 hours
    this.maxDailyShiftMinutes = 30, // 30 min
    this.dailyRampMinutes = 15, // 15 min
    this.graceThresholdMinutes = 10, // 10 min
  });

  /// Calculates the next day's wake target and explanation note based on session performance.
  EngineResult calculateNextTarget({
    required DateTime currentTargetWakeTime,
    required DateTime actualWakeTime,
    required DateTime sleepOnsetTime,
    required int actualDurationMinutes,
  }) {
    final targetMinutesFromMidnight =
        currentTargetWakeTime.hour * 60 + currentTargetWakeTime.minute;
    final actualMinutesFromMidnight =
        actualWakeTime.hour * 60 + actualWakeTime.minute;

    final deltaOversleep =
        actualMinutesFromMidnight - targetMinutesFromMidnight;

    DateTime nextTarget;
    ShiftDecisionNote decisionNote;

    // --- CASE A: Overslept (Delta > epsilon_grace) ---
    if (deltaOversleep > graceThresholdMinutes) {
      final shift = deltaOversleep < maxDailyShiftMinutes
          ? deltaOversleep
          : maxDailyShiftMinutes;
      nextTarget = currentTargetWakeTime.add(Duration(minutes: shift));
      decisionNote = ShiftDecisionNote(
        rule: ShiftDecisionRule.caseAOverslept,
        shiftMinutes: shift,
        deltaOversleepMinutes: deltaOversleep,
        note:
            'Overslept by $deltaOversleep min. Eased target wake time by +$shift min to prevent circadian disruption.',
      );
    }
    // --- CASE B.2: Substantial Early Awakening (Delta < -maxDailyShiftMinutes) ---
    else if (deltaOversleep < -maxDailyShiftMinutes) {
      if (actualDurationMinutes >= minSleepDurationMinutes) {
        // Case B.2a: Sufficient Rest (D_actual >= D_min)
        final absDelta = -deltaOversleep;
        final shift = absDelta < maxDailyShiftMinutes
            ? absDelta
            : maxDailyShiftMinutes;

        final proposedMinutes = targetMinutesFromMidnight - shift;
        final goalMinutes = goalWakeMinutesFromMidnight;

        final finalMinutes = proposedMinutes > goalMinutes
            ? proposedMinutes
            : goalMinutes;
        final actualShift = targetMinutesFromMidnight - finalMinutes;

        nextTarget = _dateTimeWithMinutes(currentTargetWakeTime, finalMinutes);

        final hoursRest = (actualDurationMinutes / 60.0).toStringAsFixed(1);
        decisionNote = ShiftDecisionNote(
          rule: ShiftDecisionRule.caseB2aEarlyFullRest,
          shiftMinutes: -actualShift,
          deltaOversleepMinutes: deltaOversleep,
          note:
              'Spontaneous early wake with full rest ($hoursRest hrs). Advancing wake target by -$actualShift min toward goal.',
        );
      } else {
        // Case B.2b: Insufficient Rest / Disturbance (D_actual < D_min)
        final proposedMinutes = targetMinutesFromMidnight - dailyRampMinutes;
        final goalMinutes = goalWakeMinutesFromMidnight;
        final finalMinutes = proposedMinutes > goalMinutes
            ? proposedMinutes
            : goalMinutes;
        final actualShift = targetMinutesFromMidnight - finalMinutes;

        nextTarget = _dateTimeWithMinutes(currentTargetWakeTime, finalMinutes);
        decisionNote = ShiftDecisionNote(
          rule: ShiftDecisionRule.caseB2bEarlyShortRest,
          shiftMinutes: -actualShift,
          deltaOversleepMinutes: deltaOversleep,
          note:
              'Early wake recorded with short sleep (<7h). Applied standard gentle ramp (-$actualShift min) to protect sleep reserve.',
        );
      }
    }
    // --- CASE B.1: On-Time / Mild Early (-maxDailyShiftMinutes <= Delta <= graceThresholdMinutes) ---
    else {
      final targetMins = targetMinutesFromMidnight;
      final goalMins = goalWakeMinutesFromMidnight;

      if (targetMins > goalMins) {
        final proposedMinutes = targetMins - dailyRampMinutes;
        final finalMinutes = proposedMinutes > goalMins
            ? proposedMinutes
            : goalMins;
        final actualShift = targetMins - finalMinutes;

        nextTarget = _dateTimeWithMinutes(currentTargetWakeTime, finalMinutes);
        final goalFormatted = _formatMinutes(goalMins);
        decisionNote = ShiftDecisionNote(
          rule: ShiftDecisionRule.caseB1OnTimeRamp,
          shiftMinutes: -actualShift,
          deltaOversleepMinutes: deltaOversleep,
          note:
              'Target met. Advancing wake time by -$actualShift min toward goal of $goalFormatted.',
        );
      } else {
        nextTarget = currentTargetWakeTime;
        decisionNote = ShiftDecisionNote(
          rule: ShiftDecisionRule.caseB1GoalReached,
          shiftMinutes: 0,
          deltaOversleepMinutes: deltaOversleep,
          note: 'Goal wake time already reached and maintained.',
        );
      }
    }

    // --- CASE C: Delayed Sleep Onset Override ---
    final sleepOnsetMinutes = sleepOnsetTime.hour * 60 + sleepOnsetTime.minute;
    final nextTargetMinutes = nextTarget.hour * 60 + nextTarget.minute;

    int onsetToWakeMinutes = nextTargetMinutes - sleepOnsetMinutes;
    if (onsetToWakeMinutes < 0) {
      onsetToWakeMinutes += 24 * 60;
    }

    if (onsetToWakeMinutes < minSleepDurationMinutes) {
      final requiredWakeMinutes = sleepOnsetMinutes + minSleepDurationMinutes;
      final maxShiftedMinutes = nextTargetMinutes + maxDailyShiftMinutes;

      final finalTargetMinutes = requiredWakeMinutes < maxShiftedMinutes
          ? requiredWakeMinutes
          : maxShiftedMinutes;
      final shift = finalTargetMinutes - nextTargetMinutes;

      nextTarget = _dateTimeWithMinutes(
        nextTarget,
        finalTargetMinutes % (24 * 60),
      );

      final onsetFormatted =
          '${sleepOnsetTime.hour.toString().padLeft(2, '0')}:${sleepOnsetTime.minute.toString().padLeft(2, '0')}';
      decisionNote = ShiftDecisionNote(
        rule: ShiftDecisionRule.caseCLateOnsetOverride,
        shiftMinutes: shift,
        deltaOversleepMinutes: deltaOversleep,
        note:
            'Sleep onset was late ($onsetFormatted). Adjusted wake target to protect baseline sleep duration.',
      );
    }

    return EngineResult(
      nextTargetWakeTime: nextTarget,
      decisionNote: decisionNote,
    );
  }

  DateTime _dateTimeWithMinutes(DateTime baseDate, int minutesFromMidnight) {
    final hours = (minutesFromMidnight ~/ 60) % 24;
    final mins = minutesFromMidnight % 60;
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day + (minutesFromMidnight >= 24 * 60 ? 1 : 0),
      hours,
      mins,
    );
  }

  String _formatMinutes(int minutesFromMidnight) {
    final hours = (minutesFromMidnight ~/ 60) % 24;
    final mins = minutesFromMidnight % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
}
