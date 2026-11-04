import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptrise/data/platform/diagnostics_service.dart';
import 'package:adaptrise/presentation/screens/monitor/wake_monitor_screen.dart';

void main() {
  group('WakeMonitorScreen Widget Tests', () {
    testWidgets('Renders active state and diagnostics cards', (tester) async {
      bool warningActionCalled = false;
      bool deniedActionCalled = false;

      final diagnostics = [
        DiagnosticItem(
          title: 'Health Connect Sync',
          description: 'Access past sleep session records and stages.',
          status: DiagnosticStatus.warning,
          actionLabel: 'Grant Access',
          onAction: () {
            warningActionCalled = true;
          },
        ),
        DiagnosticItem(
          title: 'Exact Alarm Permission',
          description: 'Required for precise wake window timing.',
          status: DiagnosticStatus.granted,
          actionLabel: 'Settings',
          onAction: () {},
        ),
        DiagnosticItem(
          title: 'Samsung Battery Optimization',
          description: 'Prevent background killing.',
          status: DiagnosticStatus.denied,
          actionLabel: 'Disable Optimization',
          onAction: () {
            deniedActionCalled = true;
          },
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: WakeMonitorScreen(
            diagnostics: diagnostics,
            monitorState: WakeMonitorState.active,
            currentWakeTargetStr: '06:30',
          ),
        ),
      );

      // Verify title & monitor state
      expect(find.text('Wake Monitor & Diagnostics'), findsOneWidget);
      expect(find.text('06:30'), findsOneWidget);
      expect(find.text('WAKE WINDOW ACTIVE'), findsOneWidget);

      // Verify diagnostics items and statuses
      expect(find.text('Health Connect Sync'), findsOneWidget);
      expect(find.text('ACTION NEEDED'), findsOneWidget);
      expect(find.text('Exact Alarm Permission'), findsOneWidget);
      expect(find.text('READY'), findsOneWidget);
      expect(find.text('Samsung Battery Optimization'), findsOneWidget);
      expect(find.text('REQUIRED'), findsOneWidget);

      // Verify action button is hidden for granted item
      expect(find.text('Settings'), findsNothing);

      // Test warning action button
      await tester.tap(find.text('Grant Access'));
      expect(warningActionCalled, isTrue);

      // Scroll to make denied action button visible
      await tester.scrollUntilVisible(find.text('Disable Optimization'), 200.0);
      await tester.pumpAndSettle();

      // Test denied action button
      await tester.tap(find.text('Disable Optimization'));
      expect(deniedActionCalled, isTrue);
    });

    testWidgets('Renders armed and disabled states correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WakeMonitorScreen(
            diagnostics: [],
            monitorState: WakeMonitorState.armed,
            currentWakeTargetStr: '07:00',
          ),
        ),
      );
      expect(find.text('ALARM ARMED'), findsOneWidget);
      expect(
        find.text('Guaranteed hard deadline and wake window scheduled.'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: WakeMonitorScreen(
            diagnostics: [],
            monitorState: WakeMonitorState.disabled,
            currentWakeTargetStr: '--:--',
          ),
        ),
      );
      expect(find.text('ALARM DISABLED'), findsOneWidget);
      expect(
        find.text('No alarm currently scheduled. Tap to configure.'),
        findsOneWidget,
      );
    });
  });

  group('DiagnosticsService Unit Tests', () {
    test('buildDiagnosticItems maps platform states to deep link actions', () {
      final launchedActions = <String>[];
      final items = DiagnosticsService.buildDiagnosticItems(
        isHealthConnectGranted: false,
        isExactAlarmGranted: true,
        isBatteryOptimizationIgnored: false,
        isWatchConnected: true,
        onLaunchIntent: (action) {
          launchedActions.add(action);
        },
      );

      expect(items.length, equals(4));

      // Health connect is warning
      expect(items[0].status, equals(DiagnosticStatus.warning));
      items[0].onAction();
      expect(
        launchedActions.last,
        equals(DiagnosticsService.actionHealthConnectSettings),
      );

      // Exact alarm is granted
      expect(items[1].status, equals(DiagnosticStatus.granted));

      // Battery optimization is warning
      expect(items[2].status, equals(DiagnosticStatus.warning));
      items[2].onAction();
      expect(
        launchedActions.last,
        equals(DiagnosticsService.actionBatteryOptimization),
      );

      // Watch is granted
      expect(items[3].status, equals(DiagnosticStatus.granted));
    });
  });
}
