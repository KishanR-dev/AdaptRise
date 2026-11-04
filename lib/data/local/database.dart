import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class SleepTargets extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get targetDate => dateTime()();
  IntColumn get targetWakeMinutes => integer()();
  IntColumn get goalWakeMinutes => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ShiftNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get targetDate => dateTime()();
  TextColumn get rule => text()();
  IntColumn get shiftMinutes => integer()();
  IntColumn get deltaOversleepMinutes => integer()();
  TextColumn get note => text()();
  TextColumn get tagsJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SleepHistorySessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get durationMinutes => integer()();
  TextColumn get stagesJson => text()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class DetectorSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wakeWindowMinutes =>
      integer().withDefault(const Constant(30))();
  IntColumn get quarantineMinutes => integer().withDefault(const Constant(5))();
  RealColumn get motionVarianceThreshold =>
      real().withDefault(const Constant(0.15))();
  RealColumn get hrSpikeRatioThreshold =>
      real().withDefault(const Constant(1.08))();
  IntColumn get consecutiveEpochsRequired =>
      integer().withDefault(const Constant(2))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [SleepTargets, ShiftNotes, SleepHistorySessions, DetectorSettings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
    : super(e ?? driftDatabase(name: 'adaptrise_local'));

  @override
  int get schemaVersion => 1;
}
