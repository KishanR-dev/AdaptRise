import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/data/platform/pigeon_api.g.dart',
    kotlinOut: 'android/app/src/main/kotlin/dev/kishanr/adaptrise/bridge/PigeonApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'dev.kishanr.adaptrise.bridge'),
  ),
)
class HealthSleepSession {
  late String id;
  late int startTimeEpochMs;
  late int endTimeEpochMs;
  late int durationMinutes;
  late List<HealthSleepStage?> stages;
}

class HealthSleepStage {
  late int
  stageType; // 1: Awake, 2: Sleeping, 3: Out-of-bed, 4: Light, 5: Deep, 6: REM
  late int startTimeEpochMs;
  late int endTimeEpochMs;
}

class DetectorConfigPigeon {
  late int wakeWindowMinutes;
  late int quarantineMinutes;
  late double motionVarianceThreshold;
  late double hrSpikeRatioThreshold;
  late int consecutiveEpochsRequired;
}

class AlarmScheduleRequest {
  late int targetWakeTimeEpochMs;
  late DetectorConfigPigeon detectorConfig;
  late bool enableSystemBackupAlarm;
}

class WakeEventSummary {
  late int triggerTimestampEpochMs;
  late String triggerReason; // "EARLY_MOTION", "EARLY_HR", "EARLY_COMPOSITE", "HARD_DEADLINE", "SENSOR_OFFLINE_DEADLINE"
  late double finalMotionVariance;
  late double finalHeartRateBpm;
}

@HostApi()
abstract class NativeAlarmHostApi {
  void scheduleAdaptiveAlarm(AlarmScheduleRequest request);
  void cancelScheduledAlarm();
  void triggerStockBackupAlarm(int deadlineEpochMs);
  HealthSleepSession? getLastSleepSession();
  bool checkPermissionsStatus();
  void requestRequiredPermissions();
  void exportT1TelemetryData();
}

@FlutterApi()
abstract class FlutterAlarmClientApi {
  void onWakeWindowArmed(int targetWakeTimeEpochMs, int windowStartEpochMs);
  void onWakeEventCompleted(WakeEventSummary summary);
  void onAlarmDismissed();
  void onAlarmSnoozed();
}
