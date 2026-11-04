import 'package:adaptrise/presentation/screens/monitor/wake_monitor_screen.dart';

class DiagnosticsService {
  const DiagnosticsService();

  /// One UI deep-link intent action constants
  static const String actionHealthConnectSettings =
      'androidx.health.ACTION_HEALTH_CONNECT_SETTINGS';
  static const String actionExactAlarmSettings =
      'android.settings.REQUEST_SCHEDULE_EXACT_ALARM';
  static const String actionBatteryOptimization =
      'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS';
  static const String actionBluetoothSettings =
      'android.settings.BLUETOOTH_SETTINGS';

  static List<DiagnosticItem> buildDiagnosticItems({
    required bool isHealthConnectGranted,
    required bool isExactAlarmGranted,
    required bool isBatteryOptimizationIgnored,
    required bool isWatchConnected,
    required void Function(String action) onLaunchIntent,
  }) {
    return [
      DiagnosticItem(
        title: 'Health Connect Sync',
        description: isHealthConnectGranted
            ? 'Sleep sessions and granular stages synchronized from Samsung Health.'
            : 'Required to read historical sleep data for target adaptation.',
        status: isHealthConnectGranted
            ? DiagnosticStatus.granted
            : DiagnosticStatus.warning,
        actionLabel: 'Open Health Connect',
        onAction: () => onLaunchIntent(actionHealthConnectSettings),
      ),
      DiagnosticItem(
        title: 'Exact Alarm Scheduling',
        description: isExactAlarmGranted
            ? 'Exact alarm permission granted for wake window and deadline triggers.'
            : 'Critical permission required to wake the device in Doze mode.',
        status: isExactAlarmGranted
            ? DiagnosticStatus.granted
            : DiagnosticStatus.denied,
        actionLabel: 'Grant Exact Alarm',
        onAction: () => onLaunchIntent(actionExactAlarmSettings),
      ),
      DiagnosticItem(
        title: 'Samsung Battery Optimization',
        description: isBatteryOptimizationIgnored
            ? 'Unrestricted background battery mode enabled for AdaptRise.'
            : 'Samsung One UI background killer may terminate wake window service.',
        status: isBatteryOptimizationIgnored
            ? DiagnosticStatus.granted
            : DiagnosticStatus.warning,
        actionLabel: 'Disable Optimization',
        onAction: () => onLaunchIntent(actionBatteryOptimization),
      ),
      DiagnosticItem(
        title: 'Galaxy Watch 4 Pairing',
        description: isWatchConnected
            ? 'Connected via Wearable Data Layer for live wrist telemetry.'
            : 'Watch disconnected or Bluetooth turned off.',
        status: isWatchConnected
            ? DiagnosticStatus.granted
            : DiagnosticStatus.warning,
        actionLabel: 'Open Bluetooth',
        onAction: () => onLaunchIntent(actionBluetoothSettings),
      ),
    ];
  }
}
