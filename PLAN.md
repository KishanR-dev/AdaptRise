# AdaptRise — Architecture, Technical Specifications & Project Plan

## 1. Project Goal & Overview
AdaptRise is an open-source, adaptive sleep-shift alarm designed for Android and Wear OS. The application shifts waking targets adaptively based on past sleep performance (read asynchronously from Health Connect / Samsung Health) and incorporates an active smart wake window (typically 30 minutes) using live wrist telemetry (accelerometer variance and heart rate) streamed from a Galaxy Watch 4.

The project targets a showcase release on GitHub by **Saturday, 7 November 2026**, and will be presented at the GDG Bangalore Flutter Meetup on **19 November 2026**.

* Package / Organization: `dev.kishanr.adaptrise`
* Target Phone: Samsung Galaxy S24 Ultra (Android 14+, One UI 6+, API 34/35 [VERIFY])
* Target Smartwatch: Samsung Galaxy Watch 4 (Wear OS 4+, One UI Watch 5+, API 33/34 [VERIFY])
* Development Host: Windows 11, PowerShell, VS Code

---

## 2. Architecture Diagram

```mermaid
flowchart TD
    subgraph Watch ["Samsung Galaxy Watch 4 (Wear OS 4+ Native Kotlin)"]
        W_FGS["WearSensorStreamingService\n(FGS Type: health)"]
        W_Sensors["SensorManager / Health Services\n(Accelerometer + PPG Heart Rate)"]
        W_Accumulator["EpochWindowAccumulator\n(5s Movement Variance + Mean HR)"]
        W_DataLayer["Wearable Data Layer\n(MessageClient / ChannelClient)"]
        W_AlarmUI["Custom Alarm Face UI\n(Compose for Wear OS + Gentle Haptic Ramp)"]

        W_FGS --> W_Sensors
        W_Sensors --> W_Accumulator
        W_Accumulator --> W_DataLayer
        W_DataLayer -.->|Dismiss / Snooze Sync| W_AlarmUI
    end

    subgraph Phone_Native ["Samsung Galaxy S24 Ultra (Native Android / Kotlin)"]
        P_AlarmMgr["AlarmManager\n(setExactAndAllowWhileIdle)"]
        P_HardAlarm["Guaranteed Hard Deadline Alarm\n(Scheduled At Arming)"]
        P_WindowAlarm["Wake Window Trigger Alarm\n(T_target - WakeWindowMinutes)"]
        P_FGS["WakeWindowForegroundService\n(FGS Types: connectedDevice | specialUse)"]
        P_DataLayer["PhoneWearableListenerService\n(Wear Data Layer Ingress)"]
        P_Detector["SmartWakeDetector (Native Kotlin)\n(Rolling Thresholds, Quarantine, Early Trigger)"]
        P_HC["Health Connect Bridge\n(Read Historical SleepSessionRecord & Stages)"]
        P_FSI["FullScreenAlarmActivity\n(Keyguard Dismiss, Audio Ramp & Haptics)"]
        P_Bridge["AdaptRisePigeonBridge\n(Flutter Platform Channel Bridge)"]

        P_AlarmMgr -->|At Arming: Sets Deadline| P_HardAlarm
        P_AlarmMgr -->|At Arming: Sets Window Start| P_WindowAlarm
        P_WindowAlarm -->|Triggers| P_FGS
        P_FGS <-->|Start / Stop Telemetry| P_DataLayer
        P_DataLayer -->|Sensor Epoch Packets| P_Detector
        P_Detector -->|Light Sleep Detected (Early)| P_FSI
        P_HardAlarm -->|Hard Deadline Reached| P_FSI
        P_Detector -.->|Early Trigger Cancels Hard Deadline| P_HardAlarm
        P_HC -->|Past Sessions| P_Bridge
        P_FGS -->|Window Events / Metrics Summary| P_Bridge
    end

    subgraph Phone_Flutter ["Flutter Application (Dart Showcase Layer)"]
        F_Bridge["Native Platform Bridge\n(Generated Pigeon Client)"]
        F_Engine["Adaptive Target Engine (Pure Dart)\n(Deterministic Shift Logic & Note Generator)"]
        F_Storage["Local Storage Layer\n(Drift / SQLite Database)"]
        F_UI["Obsidian & Amber Dawn UI\n(Timeline, Monitor, Permissions, Settings)"]

        F_Bridge <--> F_Engine
        F_Engine --> F_Storage
        F_Storage --> F_UI
    end

    W_DataLayer <===>|Bluetooth / Wi-Fi Wear Data Layer| P_DataLayer
```

---

## 3. Directory & Module Tree

```text
AdaptRise/
├── .github/
│   └── workflows/
│       └── ci.yml                     # Flutter analyze/test + Android/Wear Gradle build
├── android/                           # Phone native Android companion project
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml
│   │           └── kotlin/dev/kishanr/adaptrise/
│   │               ├── MainActivity.kt
│   │               ├── alarm/
│   │               │   ├── ExactAlarmScheduler.kt
│   │               │   ├── FullScreenAlarmActivity.kt
│   │               │   ├── WakeWindowReceiver.kt
│   │               │   ├── HardDeadlineReceiver.kt
│   │               │   ├── WakeWindowForegroundService.kt
│   │               │   └── detector/
│   │               │       ├── SmartWakeDetector.kt
│   │               │       ├── DetectorConfig.kt
│   │               │       └── SensorEpochSample.kt
│   │               ├── health/
│   │               │   └── HealthConnectBridge.kt
│   │               ├── wear/
│   │               │   ├── PhoneWearableListenerService.kt
│   │               │   └── WearDataLayerManager.kt
│   │               └── bridge/
│   │                   └── AdaptRisePigeonBridge.kt
│   └── build.gradle.kts
├── wear/                              # Native Wear OS Compose application
│   ├── build.gradle.kts
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml
│           └── kotlin/dev/kishanr/adaptrise/wear/
│               ├── presentation/
│               │   ├── MainActivity.kt
│               │   ├── theme/
│               │   └── alarm/
│               │       ├── AlarmScreen.kt
│               │       └── HapticRampController.kt
│               ├── service/
│               │   ├── WearSensorStreamingService.kt
│               │   └── WearDataLayerListenerService.kt
│               └── sensor/
│                   ├── SensorCollector.kt
│                   ├── RawTelemetryRecorder.kt
│                   └── EpochWindowAccumulator.kt
├── lib/                               # Flutter Phone Application
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   └── theme/
│   │       ├── obsidian_theme.dart
│   │       └── typography.dart
│   ├── domain/
│   │   ├── engine/
│   │   │   ├── adaptive_target_engine.dart
│   │   │   ├── shift_calculator.dart
│   │   │   └── sleep_target_models.dart
│   │   └── models/
│   │       ├── sleep_session.dart
│   │       ├── shift_decision_note.dart
│   │       └── detector_preferences.dart
│   ├── data/
│   │   ├── local/
│   │   │   ├── database.dart
│   │   │   └── preferences_repository.dart
│   │   └── platform/
│   │       ├── pigeon_api.g.dart
│   │       └── native_alarm_gateway.dart
│   └── presentation/
│       ├── screens/
│       │   ├── timeline/
│       │   │   ├── timeline_screen.dart
│       │   │   └── widgets/
│       │   ├── monitor/
│       │   │   ├── wake_monitor_screen.dart
│       │   │   └── widgets/
│       │   ├── onboarding/
│       │   │   └── permissions_screen.dart
│       │   └── settings/
│       │       └── settings_screen.dart
│       └── state/
├── test/
│   ├── engine/
│   │   ├── adaptive_target_engine_test.dart
│   │   └── shift_calculator_test.dart
│   ├── fixtures/
│   │   ├── sample_sleep_sessions.json
│   │   └── t1_raw_telemetry_sample.csv
│   └── presentation/
├── PLAN.md
├── CHECKLIST.md
└── DECISIONS.md
```

---

## 4. Platform-Channel API Specification (Pigeon Contract)

### Schema Definition (`pigeons/messages.dart`)

```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/data/platform/pigeon_api.g.dart',
  kotlinOut: 'android/app/src/main/kotlin/dev/kishanr/adaptrise/bridge/PigeonApi.g.kt',
  kotlinOptions: KotlinOptions(package: 'dev.kishanr.adaptrise.bridge'),
))

class HealthSleepSession {
  final String id;
  final int startTimeEpochMs;
  final int endTimeEpochMs;
  final int durationMinutes;
  final List<HealthSleepStage?> stages;
}

class HealthSleepStage {
  final int stageType; // 1: Awake, 2: Sleeping, 3: Out-of-bed, 4: Light, 5: Deep, 6: REM
  final int startTimeEpochMs;
  final int endTimeEpochMs;
}

class DetectorConfigPigeon {
  final int wakeWindowMinutes;
  final int quarantineMinutes;
  final double motionVarianceThreshold;
  final double hrSpikeRatioThreshold;
  final int consecutiveEpochsRequired;
}

class AlarmScheduleRequest {
  final int targetWakeTimeEpochMs;
  final DetectorConfigPigeon detectorConfig;
  final bool enableSystemBackupAlarm;
}

class WakeEventSummary {
  final int triggerTimestampEpochMs;
  final String triggerReason; // "EARLY_MOTION", "EARLY_HR", "EARLY_COMPOSITE", "HARD_DEADLINE", "SENSOR_OFFLINE_DEADLINE"
  final double finalMotionVariance;
  final double finalHeartRateBpm;
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
```

---

## 5. Adaptive Target Engine Rules (Pure Dart)

The target adjustment logic runs entirely in Dart (`lib/domain/engine/`). It is deterministic, isolated from UI and OS APIs, and designed for unit test coverage $\ge 90\%$.

### Parameters
* $T_{goal}$: Long-term goal wake time (e.g. 06:30).
* $T_{target, d}$: Target wake time scheduled for day $d$.
* $T_{actual, d}$: Actual wake time recorded in Health Connect for day $d$.
* $S_{onset, d}$: Actual sleep onset timestamp for day $d$.
* $D_{actual, d}$: Total actual sleep duration for day $d$ ($T_{actual, d} - S_{onset, d} - \text{awake\_intervals}$).
* $D_{min}$: Recommended minimum baseline sleep duration ($7.0\text{ hours} = 420\text{ minutes}$).
* $\Delta_{max}$: Maximum allowable daily shift adjustment (default: $30\text{ minutes}$).
* $R_{ramp}$: Daily ramp recovery rate advancing toward goal (default: $15\text{ minutes}$).
* $\epsilon_{grace}$: On-time threshold tolerance window (default: $10\text{ minutes}$).

### Wake Shift Calculation
Calculate the wake deviation:
$$\Delta_{oversleep} = T_{actual, d} - T_{target, d}$$

#### Case A: Overslept ($\Delta_{oversleep} > \epsilon_{grace}$)
The user missed their alarm or slept past target. Shift the next day's wake target later to mitigate circadian shock, capped by $\Delta_{max}$:
$$\Delta_{shift} = \min(\Delta_{oversleep}, \Delta_{max})$$
$$T_{target, d+1} = T_{target, d} + \Delta_{shift}$$
*Timeline Note*: `"Overslept by X min. Eased target wake time by +Y min to prevent circadian disruption."`

#### Case B.1: On-Time / Mild Early ($-\Delta_{max} \le \Delta_{oversleep} \le \epsilon_{grace}$)
The user woke on target or slightly early. Gently ramp the wake target earlier toward the long-term goal $T_{goal}$:
$$\text{If } T_{target, d} > T_{goal}: \quad T_{target, d+1} = \max(T_{goal}, T_{target, d} - R_{ramp})$$
$$\text{If } T_{target, d} \le T_{goal}: \quad T_{target, d+1} = T_{goal}$$
*Timeline Note*: `"Target met. Advancing wake time by -Y min toward goal of HH:mm."`

#### Case B.2: Substantial Early Awakening ($\Delta_{oversleep} < -\Delta_{max}$)
The user woke substantially earlier than their target (e.g. 45–90 minutes early). Evaluate based on actual sleep duration $D_{actual, d}$:
* **Sub-case B.2a: Sufficient Rest ($D_{actual, d} \ge D_{min}$)**
  The user had an early bedtime and achieved adequate sleep. Advance the next wake target toward their spontaneous wake time, clamped to a maximum shift of $\Delta_{max}$, but not earlier than $T_{goal}$:
  $$\Delta_{shift} = \min(|\Delta_{oversleep}|, \Delta_{max})$$
  $$T_{target, d+1} = \max(T_{goal}, T_{target, d} - \Delta_{shift})$$
  *Timeline Note*: `"Spontaneous early wake with full rest (X hrs). Advancing wake target by -Y min toward goal."`
* **Sub-case B.2b: Insufficient Rest / Disturbance ($D_{actual, d} < D_{min}$)**
  The user woke early due to sleep disruption, insomnia, or environmental disturbance. Advancing the target would entrain sleep loss. Do **not** advance by $\Delta_{max}$; apply only the standard gentle ramp $R_{ramp}$ toward $T_{goal}$:
  $$T_{target, d+1} = \max(T_{goal}, T_{target, d} - R_{ramp})$$
  *Timeline Note*: `"Early wake recorded with short sleep (<7h). Applied standard gentle ramp (-Y min) to protect sleep reserve."`

#### Case C: Delayed Sleep Onset Override
Regardless of morning waking performance, if bedtime was severely delayed such that:
$$T_{target, d+1} - S_{onset, d} < D_{min}$$
Shift the target forward to accommodate minimum sleep duration:
$$T_{target, d+1} = \min(T_{target, d+1} + \Delta_{max}, S_{onset, d} + D_{min})$$
*Timeline Note*: `"Sleep onset was late (HH:mm). Adjusted wake target to protect baseline sleep duration."`

---

## 6. Smart Wake Window Detector (Native Kotlin Layer)

The detector executes inside `WakeWindowForegroundService` on Android to ensure continuous processing when the phone is locked, Doze mode is active, or the Flutter UI process has been evicted.

### Operating Principles
1. **Guaranteed Hard Deadline Alarm**: Scheduled via `AlarmManager.setExactAndAllowWhileIdle()` at $T_{target}$ the instant the alarm is armed. It remains active as a guaranteed fail-safe.
2. **Wake Window Initiation**: A second exact alarm wakes the phone at $T_{target} - W$ (default $W = 30\text{ minutes}$).
3. **Watch Telemetry Loop**: Phone sends Data Layer message `/adapt_rise/wake_window/start` to Galaxy Watch 4. Watch starts `WearSensorStreamingService` (foreground service type `health`) and streams 5-second `SensorEpochPacket` objects.
4. **Detector Evaluation**:
   * **Quarantine Period**: First $Q$ minutes (default: 5 min `[VERIFY]`, user-configurable 0–10 min). Triggers are suppressed during quarantine to prevent firing on transient posture shifts entering the window.
   * **Motion Variance Threshold ($\tau_{motion}$)**: Default $0.18\,g$ `[VERIFY]` (user-configurable 0.05–0.50 g). Computed over 5-second epoch:
     $$Var(|a|) = \frac{1}{N}\sum (a_i - \bar{a})^2$$
   * **Heart Rate Elevation ($\tau_{hr}$)**: Default $+8\%$ over baseline `[VERIFY]` (user-configurable 3%–20%).
   * **Persistence**: Motion or composite threshold must remain elevated for $K$ consecutive epochs (default: $K = 2$, representing 10 seconds `[VERIFY]`).
5. **Early Trigger Execution**:
   * If thresholds are satisfied, the Kotlin service triggers `FullScreenAlarmActivity`, sends `/adapt_rise/alarm/fire` to watch, cancels the redundant hard deadline alarm, and stops watch telemetry.
6. **Hard Deadline Fallback**:
   * If natural stirring is not detected, or if watch telemetry disconnects, the hard deadline alarm fires at $T_{target}$ unconditionally.

---

## 7. Design Direction: "Obsidian & Amber Dawn" (ui-ux-pro-max-skill)

### Palette
* Void Background: `#08090C` (OLED true dark)
* Surface Container: `#12141A` (Elevation 1)
* Card Active: `#1C1F26` (Elevation 2)
* Primary Dawn Accent: `#FF9E3B` (Warm sunrise amber, 590nm tone)
* Secondary Dawn Accent: `#E06C38` (Horizon terracotta)
* Text High Contrast: `#F2F4F8` (Off-white, 90% opacity)
* Text Muted: `#8A91A0` (Secondary metadata, 60% opacity)
* Sync Success: `#4ECCA3` (Health Connect green)
* Alert / Hard Wake: `#FF5376` (Rose red)

### Typography
* Display & Numerics: `Space Grotesk` (Tabular clock numbers and deltas)
* Body & System UI: `Inter` (High legibility at low brightness)
* Telemetry & Logic Notes: `JetBrains Mono` (Shift parameters and variance)

---

## 8. Android & Wear OS Permissions Matrix

| Component | Permission | Type | Reason / Requirement |
| :--- | :--- | :--- | :--- |
| Phone | `android.permission.SCHEDULE_EXACT_ALARM` | System | Schedule exact wake window and hard deadline alarms |
| Phone | `android.permission.USE_EXACT_ALARM` | Normal | Fallback exact alarm scheduling |
| Phone | `android.permission.USE_FULL_SCREEN_INTENT` | Normal | Launch full-screen alarm over lock screen |
| Phone | `android.permission.FOREGROUND_SERVICE` | Normal | Run background wake-window coordination |
| Phone | `android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE` | Service | Wear Data Layer streaming during wake window |
| Phone | `android.permission.FOREGROUND_SERVICE_SPECIAL_USE` | Service | Alarm coordination fallback |
| Phone | `android.permission.WAKE_LOCK` | Normal | Hold CPU wake during alarm ringing |
| Phone | `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Special | Prevent One UI background killer from terminating FGS |
| Phone | `health.permission.READ_SLEEP` | Health Connect | Query historical sleep sessions and stages |
| Watch | `android.permission.BODY_SENSORS` | Runtime | Access photoplethysmography (PPG) heart rate sensor |
| Watch | `android.permission.FOREGROUND_SERVICE` | Normal | Run sensor streaming foreground service |
| Watch | `android.permission.FOREGROUND_SERVICE_HEALTH` | Service | Wear OS 4+ health sensor streaming with display dimmed |
| Watch | `android.permission.WAKE_LOCK` | Normal | Prevent watch CPU sleeping during 30-min wake window |
| Watch | `android.permission.VIBRATE` | Normal | Provide progressive haptic vibration ramp |

---

## 9. Day-1 Risk Spikes (Gate Criteria)

* **R1: Health Connect Ingress**
  * Read `SleepSessionRecord` on S24 Ultra; determine whether Samsung Health provides stage breakdown (`SleepSessionRecord.Stage`) or start/end bounds only.
* **R2: Wear Data Layer Streaming & Raw Telemetry Logging**
  * Stream 5-second feature packets from Galaxy Watch 4 to S24 Ultra with phone locked.
  * Concurrently record 15–30 minutes of raw accelerometer and HR data to disk to serve as the Day-2 calibration dataset.
* **R3: Exact Alarm & Full-Screen Intent Over Lock Screen**
  * Schedule exact alarm while phone is in Doze; confirm audio and full-screen UI trigger reliably over keyguard.

---

## 10. Implementation Schedule

* **Day 1 (Wed 4 Nov 2026)**: Scaffolding, Pigeon contracts, Wear OS `health` FGS scaffold, Native alarm scheduler, Risk Spikes R1, R2 (with raw data recording), R3 $\to$ **Gate T1**.
* **Day 2 (Thu 5 Nov 2026)**: Pure Dart Adaptive Engine (covering Cases A, B.1, B.2, C), Kotlin native `SmartWakeDetector`, threshold calibration from T1 recording, sample replay test suite.
* **Day 3 (Fri 6 Nov 2026)**: End-to-end integration (Dual alarm scheduling, Watch haptic ramp, Wear dismiss sync, "Obsidian Dawn" UI screens) $\to$ **Gate T2 (Overnight test)**.
* **Day 4 (Sat 7 Nov 2026)**: Fixes from T2 overnight run, UI polish, CI workflow validation, comprehensive README $\to$ **Gate T3 (Release)**.
* **15–18 Nov 2026**: Code freeze. Author presentation rehearsal for GDG Bangalore Flutter Meetup.
