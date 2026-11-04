import 'package:flutter/material.dart';
import 'package:adaptrise/data/local/database.dart';
import 'package:adaptrise/data/platform/diagnostics_service.dart';
import 'package:adaptrise/data/platform/native_alarm_gateway.dart';
import 'package:adaptrise/data/platform/pigeon_api.g.dart';
import 'package:adaptrise/domain/models/shift_decision_note.dart';
import 'package:adaptrise/presentation/screens/monitor/wake_monitor_screen.dart';
import 'package:adaptrise/presentation/screens/settings/settings_screen.dart';
import 'package:adaptrise/presentation/screens/timeline/timeline_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final nativeGateway = NativeAlarmGateway();

  runApp(AdaptRiseApp(database: database, nativeGateway: nativeGateway));
}

class AdaptRiseApp extends StatelessWidget {
  final AppDatabase database;
  final NativeAlarmGateway nativeGateway;

  const AdaptRiseApp({
    super.key,
    required this.database,
    required this.nativeGateway,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdaptRise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08090C), // Obsidian void
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF9E3B), // Amber Dawn accent
          secondary: Color(0xFFE06C38),
          surface: Color(0xFF12141A),
        ),
        useMaterial3: true,
      ),
      home: MainNavigationShell(
        database: database,
        nativeGateway: nativeGateway,
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AppDatabase database;
  final NativeAlarmGateway nativeGateway;

  const MainNavigationShell({
    super.key,
    required this.database,
    required this.nativeGateway,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _backupAlarmEnabled = false;

  void _handleLaunchIntent(String action) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Launching system intent: $action')));
  }

  void _handleBackupAlarmChanged(bool enabled) {
    setState(() {
      _backupAlarmEnabled = enabled;
    });
    widget.nativeGateway.scheduleAdaptiveAlarm(
      targetWakeTimeEpochMs: DateTime.now().millisecondsSinceEpoch + 3600000,
      detectorConfig: DetectorConfigPigeon(
        wakeWindowMinutes: 30,
        quarantineMinutes: 5,
        motionVarianceThreshold: 0.15,
        hrSpikeRatioThreshold: 1.08,
        consecutiveEpochsRequired: 2,
      ),
      enableSystemBackupAlarm: enabled,
    );
  }

  List<TimelineItemData> _getSampleTimelineItems() {
    final now = DateTime.now();
    return [
      TimelineItemData(
        targetDate: now.subtract(const Duration(days: 1)),
        scheduledTarget: DateTime(now.year, now.month, now.day - 1, 7, 0),
        actualWake: DateTime(now.year, now.month, now.day - 1, 7, 45),
        decisionNote: const ShiftDecisionNote(
          rule: ShiftDecisionRule.caseAOverslept,
          shiftMinutes: 30,
          deltaOversleepMinutes: 45,
          note: 'Overslept by 45 min. Eased target wake time by +30 min to prevent circadian disruption.',
          tags: {'rule': 'CASE_A', 'overslept': '+45m', 'shift': '+30m'},
        ),
      ),
      TimelineItemData(
        targetDate: now,
        scheduledTarget: DateTime(now.year, now.month, now.day, 7, 0),
        actualWake: DateTime(now.year, now.month, now.day, 6, 50),
        decisionNote: const ShiftDecisionNote(
          rule: ShiftDecisionRule.caseB1OnTimeRamp,
          shiftMinutes: -15,
          deltaOversleepMinutes: -10,
          note: 'Target met. Advancing wake time by -15 min toward goal of 06:30.',
          tags: {'rule': 'CASE_B1_RAMP', 'shift': '-15m', 'goal': '06:30'},
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final diagnostics = DiagnosticsService.buildDiagnosticItems(
      isHealthConnectGranted: true,
      isExactAlarmGranted: true,
      isBatteryOptimizationIgnored: false,
      isWatchConnected: true,
      onLaunchIntent: _handleLaunchIntent,
    );

    final screens = [
      TimelineScreen(items: _getSampleTimelineItems()),
      WakeMonitorScreen(
        diagnostics: diagnostics,
        monitorState: WakeMonitorState.armed,
        currentWakeTargetStr: '06:30',
      ),
      SettingsScreen(
        initialBackupAlarmEnabled: _backupAlarmEnabled,
        onBackupAlarmChanged: _handleBackupAlarmChanged,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF12141A),
        indicatorColor: const Color(0xFFFF9E3B).withValues(alpha: 0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timeline, color: Color(0xFF8A91A0)),
            selectedIcon: Icon(Icons.timeline, color: Color(0xFFFF9E3B)),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined, color: Color(0xFF8A91A0)),
            selectedIcon: Icon(Icons.monitor_heart, color: Color(0xFFFF9E3B)),
            label: 'Monitor',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: Color(0xFF8A91A0)),
            selectedIcon: Icon(Icons.settings, color: Color(0xFFFF9E3B)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
