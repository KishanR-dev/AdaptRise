import 'package:adaptrise/data/platform/pigeon_api.g.dart';

class NativeAlarmGateway {
  final NativeAlarmHostApi _hostApi;

  NativeAlarmGateway([NativeAlarmHostApi? hostApi])
    : _hostApi = hostApi ?? NativeAlarmHostApi();

  Future<void> scheduleAdaptiveAlarm({
    required int targetWakeTimeEpochMs,
    required DetectorConfigPigeon detectorConfig,
    bool enableSystemBackupAlarm = false,
  }) {
    final request = AlarmScheduleRequest(
      targetWakeTimeEpochMs: targetWakeTimeEpochMs,
      detectorConfig: detectorConfig,
      enableSystemBackupAlarm: enableSystemBackupAlarm,
    );
    return _hostApi.scheduleAdaptiveAlarm(request);
  }

  Future<void> cancelScheduledAlarm() {
    return _hostApi.cancelScheduledAlarm();
  }

  Future<void> triggerStockBackupAlarm(int deadlineEpochMs) {
    return _hostApi.triggerStockBackupAlarm(deadlineEpochMs);
  }

  Future<HealthSleepSession?> getLastSleepSession() {
    return _hostApi.getLastSleepSession();
  }

  Future<bool> checkPermissionsStatus() {
    return _hostApi.checkPermissionsStatus();
  }
}
