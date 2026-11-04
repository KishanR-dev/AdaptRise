import 'package:flutter_test/flutter_test.dart';
import 'package:adaptrise/data/platform/pigeon_api.g.dart';
import 'package:adaptrise/data/platform/native_alarm_gateway.dart';

class FakeNativeAlarmHostApi extends NativeAlarmHostApi {
  AlarmScheduleRequest? lastScheduleRequest;
  int? lastBackupDeadlineEpochMs;
  bool cancelCalled = false;
  bool permissionsStatusResult = true;
  HealthSleepSession? mockSleepSession;

  @override
  Future<void> scheduleAdaptiveAlarm(AlarmScheduleRequest request) async {
    lastScheduleRequest = request;
  }

  @override
  Future<void> cancelScheduledAlarm() async {
    cancelCalled = true;
  }

  @override
  Future<void> triggerStockBackupAlarm(int deadlineEpochMs) async {
    lastBackupDeadlineEpochMs = deadlineEpochMs;
  }

  @override
  Future<HealthSleepSession?> getLastSleepSession() async {
    return mockSleepSession;
  }

  @override
  Future<bool> checkPermissionsStatus() async {
    return permissionsStatusResult;
  }

  @override
  Future<void> requestRequiredPermissions() async {}

  @override
  Future<void> exportT1TelemetryData() async {}
}

void main() {
  group('NativeAlarmGateway Tests', () {
    late FakeNativeAlarmHostApi fakeApi;
    late NativeAlarmGateway gateway;

    setUp(() {
      fakeApi = FakeNativeAlarmHostApi();
      gateway = NativeAlarmGateway(fakeApi);
    });

    test('scheduleAdaptiveAlarm passes enableSystemBackupAlarm correctly with default false', () async {
      final config = DetectorConfigPigeon(
        wakeWindowMinutes: 30,
        quarantineMinutes: 5,
        motionVarianceThreshold: 0.15,
        hrSpikeRatioThreshold: 1.08,
        consecutiveEpochsRequired: 2,
      );

      await gateway.scheduleAdaptiveAlarm(
        targetWakeTimeEpochMs: 1772780400000,
        detectorConfig: config,
      );

      expect(fakeApi.lastScheduleRequest, isNotNull);
      expect(fakeApi.lastScheduleRequest!.enableSystemBackupAlarm, isFalse);
    });

    test('scheduleAdaptiveAlarm passes enableSystemBackupAlarm true when requested', () async {
      final config = DetectorConfigPigeon(
        wakeWindowMinutes: 30,
        quarantineMinutes: 5,
        motionVarianceThreshold: 0.15,
        hrSpikeRatioThreshold: 1.08,
        consecutiveEpochsRequired: 2,
      );

      await gateway.scheduleAdaptiveAlarm(
        targetWakeTimeEpochMs: 1772780400000,
        detectorConfig: config,
        enableSystemBackupAlarm: true,
      );

      expect(fakeApi.lastScheduleRequest!.enableSystemBackupAlarm, isTrue);
    });

    test('triggerStockBackupAlarm forwards deadline epoch ms', () async {
      await gateway.triggerStockBackupAlarm(1772780400000);
      expect(fakeApi.lastBackupDeadlineEpochMs, equals(1772780400000));
    });

    test('cancelScheduledAlarm invokes host api', () async {
      await gateway.cancelScheduledAlarm();
      expect(fakeApi.cancelCalled, isTrue);
    });

    test('checkPermissionsStatus returns status from host api', () async {
      final status = await gateway.checkPermissionsStatus();
      expect(status, isTrue);
    });

    test('getLastSleepSession returns session and null correctly', () async {
      expect(await gateway.getLastSleepSession(), isNull);

      fakeApi.mockSleepSession = HealthSleepSession(
        id: 'session_1',
        startTimeEpochMs: 1000,
        endTimeEpochMs: 2000,
        durationMinutes: 480,
        stages: [],
      );

      final session = await gateway.getLastSleepSession();
      expect(session, isNotNull);
      expect(session!.id, equals('session_1'));
      expect(session.durationMinutes, equals(480));
    });
  });
}
