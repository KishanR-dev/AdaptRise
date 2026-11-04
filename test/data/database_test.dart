import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptrise/data/local/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase Drift Tests', () {
    test('SleepTargets insertion and query', () async {
      final now = DateTime(2026, 11, 4);
      await db
          .into(db.sleepTargets)
          .insert(
            SleepTargetsCompanion.insert(
              targetDate: now,
              targetWakeMinutes: 420, // 07:00
              goalWakeMinutes: 390, // 06:30
            ),
          );

      final targets = await db.select(db.sleepTargets).get();
      expect(targets.length, equals(1));
      expect(targets.first.targetWakeMinutes, equals(420));
      expect(targets.first.goalWakeMinutes, equals(390));
    });

    test('ShiftNotes insertion and query', () async {
      final targetDate = DateTime(2026, 11, 4);
      await db
          .into(db.shiftNotes)
          .insert(
            ShiftNotesCompanion.insert(
              targetDate: targetDate,
              rule: 'caseAOverslept',
              shiftMinutes: 30,
              deltaOversleepMinutes: 45,
              note: 'Overslept by 45 min. Eased target wake time by +30 min to prevent circadian disruption.',
              tagsJson: '{"rule":"CASE_A","overslept":"+45m","shift":"+30m"}',
            ),
          );

      final notes = await db.select(db.shiftNotes).get();
      expect(notes.length, equals(1));
      expect(notes.first.rule, equals('caseAOverslept'));
      expect(notes.first.shiftMinutes, equals(30));
      expect(notes.first.tagsJson, contains('CASE_A'));
    });

    test('SleepHistorySessions primary key uniqueness and query', () async {
      final start = DateTime(2026, 11, 3, 23, 0);
      final end = DateTime(2026, 11, 4, 7, 0);

      await db
          .into(db.sleepHistorySessions)
          .insert(
            SleepHistorySessionsCompanion.insert(
              id: 'session_hc_1001',
              startTime: start,
              endTime: end,
              durationMinutes: 480,
              stagesJson: '[]',
            ),
          );

      final sessions = await db.select(db.sleepHistorySessions).get();
      expect(sessions.length, equals(1));
      expect(sessions.first.id, equals('session_hc_1001'));
      expect(sessions.first.durationMinutes, equals(480));
    });

    test('DetectorSettings default and update', () async {
      final id = await db
          .into(db.detectorSettings)
          .insert(DetectorSettingsCompanion.insert());

      var settings = await (db.select(
        db.detectorSettings,
      )..where((tbl) => tbl.id.equals(id))).getSingle();
      expect(settings.wakeWindowMinutes, equals(30));
      expect(settings.quarantineMinutes, equals(5));
      expect(settings.motionVarianceThreshold, equals(0.15));
      expect(settings.hrSpikeRatioThreshold, equals(1.08));

      // Update settings
      await (db.update(
        db.detectorSettings,
      )..where((tbl) => tbl.id.equals(id))).write(
        const DetectorSettingsCompanion(
          motionVarianceThreshold: Value(0.20),
          quarantineMinutes: Value(3),
        ),
      );

      settings = await (db.select(
        db.detectorSettings,
      )..where((tbl) => tbl.id.equals(id))).getSingle();
      expect(settings.motionVarianceThreshold, equals(0.20));
      expect(settings.quarantineMinutes, equals(3));
    });
  });
}
