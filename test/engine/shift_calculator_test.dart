import 'package:flutter_test/flutter_test.dart';
import 'package:adaptrise/domain/engine/shift_calculator.dart';
import 'package:adaptrise/domain/models/shift_decision_note.dart';

void main() {
  group('ShiftCalculator Tests', () {
    test(
      'formatShiftBadge formats positive, negative, and zero shifts correctly',
      () {
        expect(ShiftCalculator.formatShiftBadge(30), equals('+30m'));
        expect(ShiftCalculator.formatShiftBadge(-15), equals('-15m'));
        expect(ShiftCalculator.formatShiftBadge(0), equals('0m'));
      },
    );

    test('formatClockMinutes formats minutes from midnight to HH:mm', () {
      expect(ShiftCalculator.formatClockMinutes(390), equals('06:30'));
      expect(ShiftCalculator.formatClockMinutes(0), equals('00:00'));
      expect(ShiftCalculator.formatClockMinutes(1439), equals('23:59'));
    });

    test('generateCaseANote creates correct explanation and tags', () {
      final note = ShiftCalculator.generateCaseANote(
        deltaOversleepMinutes: 45,
        shiftMinutes: 30,
      );

      expect(note.rule, equals(ShiftDecisionRule.caseAOverslept));
      expect(note.shiftMinutes, equals(30));
      expect(note.direction, equals(ShiftDirection.forward));
      expect(note.tags['rule'], equals('CASE_A'));
      expect(note.tags['overslept'], equals('+45m'));
      expect(note.tags['shift'], equals('+30m'));
      expect(note.note, contains('Overslept by 45 min'));
    });

    test('generateCaseB1RampNote creates correct explanation and tags', () {
      final note = ShiftCalculator.generateCaseB1RampNote(
        deltaOversleepMinutes: -5,
        shiftMinutes: -15,
        goalWakeMinutesFromMidnight: 390,
      );

      expect(note.rule, equals(ShiftDecisionRule.caseB1OnTimeRamp));
      expect(note.shiftMinutes, equals(-15));
      expect(note.direction, equals(ShiftDirection.backward));
      expect(note.tags['goal'], equals('06:30'));
      expect(note.tags['shift'], equals('-15m'));
      expect(note.note, contains('goal of 06:30'));
    });

    test('generateCaseB1GoalReachedNote creates correct explanation and zero direction', () {
      final note = ShiftCalculator.generateCaseB1GoalReachedNote(
        deltaOversleepMinutes: 0,
        goalWakeMinutesFromMidnight: 390,
      );

      expect(note.rule, equals(ShiftDecisionRule.caseB1GoalReached));
      expect(note.shiftMinutes, equals(0));
      expect(note.direction, equals(ShiftDirection.neutral));
      expect(note.tags['goal'], equals('06:30'));
      expect(note.note, contains('already reached and maintained'));
    });

    test('generateCaseB2aNote creates correct explanation and tags', () {
      final note = ShiftCalculator.generateCaseB2aNote(
        deltaOversleepMinutes: -60,
        shiftMinutes: -30,
        actualDurationMinutes: 480,
      );

      expect(note.rule, equals(ShiftDecisionRule.caseB2aEarlyFullRest));
      expect(note.tags['rest'], equals('8.0h'));
      expect(
        note.note,
        contains('Spontaneous early wake with full rest (8.0 hrs)'),
      );
    });

    test('generateCaseB2bNote creates correct explanation and tags', () {
      final note = ShiftCalculator.generateCaseB2bNote(
        deltaOversleepMinutes: -90,
        shiftMinutes: -15,
        actualDurationMinutes: 360,
      );

      expect(note.rule, equals(ShiftDecisionRule.caseB2bEarlyShortRest));
      expect(note.tags['duration'], equals('360m'));
      expect(note.note, contains('short sleep'));
    });

    test('generateCaseCNote creates correct explanation and tags', () {
      final sleepOnset = DateTime(2026, 11, 4, 1, 30);
      final note = ShiftCalculator.generateCaseCNote(
        deltaOversleepMinutes: 0,
        shiftMinutes: 30,
        sleepOnsetTime: sleepOnset,
        minSleepDurationMinutes: 420,
      );

      expect(note.rule, equals(ShiftDecisionRule.caseCLateOnsetOverride));
      expect(note.tags['onset'], equals('01:30'));
      expect(note.tags['min_duration'], equals('420m'));
      expect(note.note, contains('Sleep onset was late (01:30)'));
    });
  });
}
