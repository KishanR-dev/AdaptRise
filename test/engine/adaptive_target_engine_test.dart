import 'package:flutter_test/flutter_test.dart';
import 'package:adaptrise/domain/engine/adaptive_target_engine.dart';
import 'package:adaptrise/domain/models/shift_decision_note.dart';

void main() {
  group('AdaptiveTargetEngine Tests', () {
    const engine = AdaptiveTargetEngine(
      goalWakeMinutesFromMidnight: 390, // 06:30
      minSleepDurationMinutes: 420, // 7 hours
      maxDailyShiftMinutes: 30,
      dailyRampMinutes: 15,
      graceThresholdMinutes: 10,
    );

    test('Case A: Overslept beyond grace period shifts wake target later (capped at Delta_max)', () {
      final currentTarget = DateTime(2026, 11, 4, 7, 0); // 07:00 AM
      final actualWake = DateTime(
        2026,
        11,
        4,
        7,
        45,
      ); // 07:45 AM (Delta = +45 min)
      final sleepOnset = DateTime(2026, 11, 3, 23, 0); // 11:00 PM

      final result = engine.calculateNextTarget(
        currentTargetWakeTime: currentTarget,
        actualWakeTime: actualWake,
        sleepOnsetTime: sleepOnset,
        actualDurationMinutes: 525,
      );

      expect(
        result.decisionNote.rule,
        equals(ShiftDecisionRule.caseAOverslept),
      );
      expect(
        result.decisionNote.shiftMinutes,
        equals(30),
      ); // Capped at maxDailyShiftMinutes (30)
      expect(result.nextTargetWakeTime.hour, equals(7));
      expect(
        result.nextTargetWakeTime.minute,
        equals(30),
      ); // 07:00 + 30m = 07:30
    });

    test(
      'Case B.1: On-time or mild early ramp shifts target earlier toward goal',
      () {
        final currentTarget = DateTime(2026, 11, 4, 7, 0); // 07:00 AM
        final actualWake = DateTime(
          2026,
          11,
          4,
          6,
          55,
        ); // 06:55 AM (Delta = -5 min, within grace)
        final sleepOnset = DateTime(2026, 11, 3, 23, 0); // 11:00 PM

        final result = engine.calculateNextTarget(
          currentTargetWakeTime: currentTarget,
          actualWakeTime: actualWake,
          sleepOnsetTime: sleepOnset,
          actualDurationMinutes: 475,
        );

        expect(
          result.decisionNote.rule,
          equals(ShiftDecisionRule.caseB1OnTimeRamp),
        );
        expect(result.decisionNote.shiftMinutes, equals(-15)); // Ramp by -15m
        expect(result.nextTargetWakeTime.hour, equals(6));
        expect(
          result.nextTargetWakeTime.minute,
          equals(45),
        ); // 07:00 - 15m = 06:45
      },
    );

    test('Case B.1: Target at or past goal maintains goal time', () {
      final currentTarget = DateTime(2026, 11, 4, 6, 30); // 06:30 AM (At goal)
      final actualWake = DateTime(2026, 11, 4, 6, 30);
      final sleepOnset = DateTime(2026, 11, 3, 23, 0);

      final result = engine.calculateNextTarget(
        currentTargetWakeTime: currentTarget,
        actualWakeTime: actualWake,
        sleepOnsetTime: sleepOnset,
        actualDurationMinutes: 450,
      );

      expect(
        result.decisionNote.rule,
        equals(ShiftDecisionRule.caseB1GoalReached),
      );
      expect(result.decisionNote.shiftMinutes, equals(0));
      expect(result.nextTargetWakeTime.hour, equals(6));
      expect(result.nextTargetWakeTime.minute, equals(30));
    });

    test('Case B.2a: Substantial early wake with sufficient rest advances toward goal', () {
      final currentTarget = DateTime(2026, 11, 4, 7, 0); // 07:00 AM
      final actualWake = DateTime(
        2026,
        11,
        4,
        6,
        0,
      ); // 06:00 AM (Delta = -60 min < -30)
      final sleepOnset = DateTime(
        2026,
        11,
        3,
        22,
        0,
      ); // 10:00 PM (8 hours rest)

      final result = engine.calculateNextTarget(
        currentTargetWakeTime: currentTarget,
        actualWakeTime: actualWake,
        sleepOnsetTime: sleepOnset,
        actualDurationMinutes: 480, // 8 hours >= 7 hours (420 min)
      );

      expect(
        result.decisionNote.rule,
        equals(ShiftDecisionRule.caseB2aEarlyFullRest),
      );
      expect(
        result.decisionNote.shiftMinutes,
        equals(-30),
      ); // Shift by maxDelta (30)
      expect(result.nextTargetWakeTime.hour, equals(6));
      expect(
        result.nextTargetWakeTime.minute,
        equals(30),
      ); // 07:00 - 30m = 06:30
    });

    test('Case B.2b: Substantial early wake with short sleep applies gentle ramp only', () {
      final currentTarget = DateTime(2026, 11, 4, 7, 0); // 07:00 AM
      final actualWake = DateTime(
        2026,
        11,
        4,
        5,
        30,
      ); // 05:30 AM (Delta = -90 min)
      final sleepOnset = DateTime(
        2026,
        11,
        3,
        23,
        0,
      ); // 11:00 PM (normal onset)

      final result = engine.calculateNextTarget(
        currentTargetWakeTime: currentTarget,
        actualWakeTime: actualWake,
        sleepOnsetTime: sleepOnset,
        actualDurationMinutes: 390, // 6.5 hours < 7 hours (420 min)
      );

      expect(
        result.decisionNote.rule,
        equals(ShiftDecisionRule.caseB2bEarlyShortRest),
      );
      expect(
        result.decisionNote.shiftMinutes,
        equals(-15),
      ); // Only dailyRampMinutes (-15)
      expect(result.nextTargetWakeTime.hour, equals(6));
      expect(
        result.nextTargetWakeTime.minute,
        equals(45),
      ); // 07:00 - 15m = 06:45
    });

    test('Case C: Delayed sleep onset override shifts target forward capped at Delta_max', () {
      final currentTarget = DateTime(2026, 11, 4, 7, 0);
      final actualWake = DateTime(2026, 11, 4, 7, 0);
      final sleepOnset = DateTime(2026, 11, 4, 1, 30); // 01:30 AM (Late onset)

      final result = engine.calculateNextTarget(
        currentTargetWakeTime: currentTarget,
        actualWakeTime: actualWake,
        sleepOnsetTime: sleepOnset,
        actualDurationMinutes: 330,
      );

      expect(
        result.decisionNote.rule,
        equals(ShiftDecisionRule.caseCLateOnsetOverride),
      );
      // Base ramp was 06:45. Capped shift is 06:45 + 30m = 07:15 AM
      expect(result.decisionNote.shiftMinutes, equals(30));
      expect(result.nextTargetWakeTime.hour, equals(7));
      expect(result.nextTargetWakeTime.minute, equals(15));
    });

    test('Case C: Mildly delayed sleep onset shifts exactly enough to protect D_min', () {
      final currentTarget = DateTime(2026, 11, 4, 7, 0);
      final actualWake = DateTime(2026, 11, 4, 7, 0);
      final sleepOnset = DateTime(
        2026,
        11,
        4,
        0,
        0,
      ); // 12:00 AM Midnight (Onset + 420m = 07:00 AM)

      final result = engine.calculateNextTarget(
        currentTargetWakeTime: currentTarget,
        actualWakeTime: actualWake,
        sleepOnsetTime: sleepOnset,
        actualDurationMinutes: 420,
      );

      expect(
        result.decisionNote.rule,
        equals(ShiftDecisionRule.caseCLateOnsetOverride),
      );
      // Base ramp was 06:45. Required for D_min is 07:00. Shift is +15m.
      expect(result.decisionNote.shiftMinutes, equals(15));
      expect(result.nextTargetWakeTime.hour, equals(7));
      expect(result.nextTargetWakeTime.minute, equals(0));
    });
  });
}
