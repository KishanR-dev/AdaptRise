import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptrise/data/local/database.dart';
import 'package:adaptrise/data/platform/native_alarm_gateway.dart';
import 'package:adaptrise/data/platform/pigeon_api.g.dart';
import 'package:adaptrise/main.dart';

class FakeNativeAlarmHostApi extends NativeAlarmHostApi {
  AlarmScheduleRequest? lastRequest;

  @override
  Future<void> scheduleAdaptiveAlarm(AlarmScheduleRequest request) async {
    lastRequest = request;
  }

  @override
  Future<void> cancelScheduledAlarm() async {}

  @override
  Future<void> triggerStockBackupAlarm(int deadlineEpochMs) async {}

  @override
  Future<HealthSleepSession?> getLastSleepSession() async => null;

  @override
  Future<bool> checkPermissionsStatus() async => true;

  @override
  Future<void> requestRequiredPermissions() async {}

  @override
  Future<void> exportT1TelemetryData() async {}
}

void main() {
  testWidgets('AdaptRiseApp navigation shell smoke test', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final fakeHostApi = FakeNativeAlarmHostApi();
    final gateway = NativeAlarmGateway(fakeHostApi);

    await tester.pumpWidget(
      AdaptRiseApp(database: database, nativeGateway: gateway),
    );
    await tester.pumpAndSettle();

    // Verify TimelineScreen is visible by default
    expect(find.text('Sleep-Shift Timeline'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Monitor'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap Monitor tab
    await tester.tap(find.text('Monitor'));
    await tester.pumpAndSettle();

    expect(find.text('Wake Monitor & Diagnostics'), findsOneWidget);

    // Tap Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Stock Clock Backup Alarm'), findsOneWidget);

    // Toggle switch in settings
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(fakeHostApi.lastRequest, isNotNull);
    expect(fakeHostApi.lastRequest!.enableSystemBackupAlarm, isTrue);

    // Rapid navigation back to Timeline
    await tester.tap(find.text('Timeline'));
    await tester.pumpAndSettle();
    expect(find.text('Sleep-Shift Timeline'), findsOneWidget);

    await database.close();
  });
}
