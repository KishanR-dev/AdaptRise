import 'package:adaptrise/domain/engine/shift_calculator.dart';
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
      decisionNote = ShiftCalculator.generateCaseANote(
        deltaOversleepMinutes: deltaOversleep,
        shiftMinutes: shift,
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
        decisionNote = ShiftCalculator.generateCaseB2aNote(
          deltaOversleepMinutes: deltaOversleep,
          shiftMinutes: -actualShift,
          actualDurationMinutes: actualDurationMinutes,
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
        decisionNote = ShiftCalculator.generateCaseB2bNote(
          deltaOversleepMinutes: deltaOversleep,
          shiftMinutes: -actualShift,
          actualDurationMinutes: actualDurationMinutes,
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
        decisionNote = ShiftCalculator.generateCaseB1RampNote(
          deltaOversleepMinutes: deltaOversleep,
          shiftMinutes: -actualShift,
          goalWakeMinutesFromMidnight: goalMins,
        );
      } else {
        nextTarget = currentTargetWakeTime;
        decisionNote = ShiftCalculator.generateCaseB1GoalReachedNote(
          deltaOversleepMinutes: deltaOversleep,
          goalWakeMinutesFromMidnight: goalMins,
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

      decisionNote = ShiftCalculator.generateCaseCNote(
        deltaOversleepMinutes: deltaOversleep,
        shiftMinutes: shift,
        sleepOnsetTime: sleepOnsetTime,
        minSleepDurationMinutes: minSleepDurationMinutes,
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
}
