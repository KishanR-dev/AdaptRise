### Revised Documentation Files

---

### File 1: `PLAN.md`

```markdown
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
```

---

### File 2: `CHECKLIST.md`

```markdown
# AdaptRise — Execution Checklist & Acceptance Verification

All automated tests and builds must be executed and pasted into agent reports before marking items complete.

---

## Phase 1: Day 1 Scaffold & Risk Spikes (Deadline: Wed 4 Nov 2026)

- [ ] **1.1 Workspace Scaffolding & CI Baseline**
  - **Acceptance Criteria**: Flutter application initializes under package `dev.kishanr.adaptrise`; Wear OS module configured with Jetpack Compose for Wear OS; GitHub Actions workflow passes `flutter analyze` and `dart format`.
  - **PowerShell Commands**:
    ```powershell
    flutter create --org dev.kishanr.adaptrise --platforms android .
    dart format --output=none --set-exit-if-changed .
    flutter analyze
    ```

- [ ] **1.2 Pigeon IPC Interface Generation**
  - **Acceptance Criteria**: `pigeons/messages.dart` generates `lib/data/platform/pigeon_api.g.dart` and `android/app/src/main/kotlin/dev/kishanr/adaptrise/bridge/PigeonApi.g.kt` without compilation errors or warnings.
  - **PowerShell Commands**:
    ```powershell
    dart run pigeon --input pigeons/messages.dart
    git status --porcelain
    ```

- [ ] **1.3 Wear OS Companion Scaffold with Health FGS**
  - **Acceptance Criteria**: Wear OS project configures `WearSensorStreamingService` declaring `android:foregroundServiceType="health"` with `BODY_SENSORS` and `WAKE_LOCK` permissions; builds cleanly.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :wear:assembleDebug
    ```

- [ ] **1.4 Risk Spike R1: Health Connect Ingress**
  - **Acceptance Criteria**: `HealthConnectBridge.kt` queries Health Connect on S24 Ultra. Logs verify if `SleepSessionRecord.Stage` data is returned by Samsung Health or only start/end timestamps.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :app:testDebugUnitTest --tests "*HealthConnectBridgeTest*"
    ```

- [ ] **1.5 Risk Spike R2: Wear Data Layer Streaming & Raw Telemetry Logger**
  - **Acceptance Criteria**: Galaxy Watch 4 streams 5-second `SensorEpochPacket` objects across Data Layer while phone is locked; watch raw recorder outputs `t1_sensor_recording.csv` (accelerometer magnitude and HR) for Day-2 calibration.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :wear:assembleDebug
    .\gradlew.bat :app:assembleDebug
    ```

- [ ] **1.6 Risk Spike R3: Dual Exact Alarm & Full-Screen Intent**
  - **Acceptance Criteria**: `AlarmManager.setExactAndAllowWhileIdle()` schedules both wake window trigger and hard deadline; `FullScreenAlarmActivity` turns screen on over keyguard with ringtone in Doze mode.
  - **PowerShell Commands**:
    ```powershell
    adb shell dumpsys deviceidle force-idle
    # Trigger test alarm via ADB harness
    ```

### Gate T1: Real-Device Spike Verification (End of Day 1)
*Must be verified on physical Galaxy S24 Ultra + Galaxy Watch 4 before proceeding to Phase 2.*
- [ ] Connect S24 Ultra and Galaxy Watch 4 via ADB.
- [ ] **T1.1**: Open app $\to$ Grant Health Connect permissions $\to$ Verify past sleep session queries; document whether stages sync.
- [ ] **T1.2**: Arm 15-minute sensor test $\to$ Lock phone screen $\to$ Verify watch streams 5-second epochs for 15 minutes without drops while watch display dims.
- [ ] **T1.3**: Confirm raw telemetry dataset `t1_sensor_recording.csv` is saved to device storage and pulled via ADB for Day-2 calibration.
- [ ] **T1.4**: Schedule test alarm 2 minutes out $\to$ Lock phone in Doze $\to$ Confirm full-screen alarm fires over lock screen and sounds audio.

---

## Phase 2: Day 2 Core Engine, Kotlin Detector & Calibration (Deadline: Thu 5 Nov 2026)

- [ ] **2.1 Pure Dart Adaptive Target Engine**
  - **Acceptance Criteria**: Implementation in `lib/domain/engine/adaptive_target_engine.dart` handles:
    - Case A: Overslept ($\Delta > \epsilon_{grace}$) $\to$ shift $+ \min(\Delta, \Delta_{max})$
    - Case B.1: On-time / mild early $\to$ ramp $- R_{ramp}$ toward $T_{goal}$
    - Case B.2a: Early wake ($\Delta < -\Delta_{max}$) with $D_{actual} \ge D_{min}$ $\to$ advance up to $\Delta_{max}$ toward $T_{goal}$
    - Case B.2b: Early wake ($\Delta < -\Delta_{max}$) with $D_{actual} < D_{min}$ $\to$ ramp only $- R_{ramp}$
    - Case C: Late sleep onset $\to$ preserve $D_{min}$ baseline
    - Zero Flutter UI or native imports; unit test coverage $\ge 90\%$.
  - **PowerShell Commands**:
    ```powershell
    flutter test test/engine/adaptive_target_engine_test.dart --coverage
    ```

- [ ] **2.2 Timeline Shift Note Generator**
  - **Acceptance Criteria**: Deterministic string formatter generates human-readable explanations matching each adaptation decision with parameter tags.
  - **PowerShell Commands**:
    ```powershell
    flutter test test/engine/shift_calculator_test.dart
    ```

- [ ] **2.3 Day-2 Sensor Calibration & Configurable Parameters**
  - **Acceptance Criteria**: Analyze `t1_sensor_recording.csv`; calibrate baseline resting variance and HR spike ratios; expose parameters in `DetectorConfig.kt` and `detector_preferences.dart` with defaults marked verified against sample.
  - **PowerShell Commands**:
    ```powershell
    python scripts/calibrate_thresholds.py test/fixtures/t1_raw_telemetry_sample.csv
    # Or Kotlin analysis harness
    ```

- [ ] **2.4 Native Kotlin Smart Wake Window Detector**
  - **Acceptance Criteria**: `SmartWakeDetector.kt` runs inside `WakeWindowForegroundService`; enforces quarantine period `[VERIFY]`; evaluates configurable motion variance `[VERIFY]` and HR increase `[VERIFY]` across consecutive epochs; triggers early on light sleep; falls back to hard deadline.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :app:testDebugUnitTest --tests "*SmartWakeDetectorTest*"
    ```

- [ ] **2.5 Recorded Sample Replay Test Suite**
  - **Acceptance Criteria**: Unit tests feed recorded epoch timeseries into `SmartWakeDetector`; verifies zero false alarms during deep sleep quiet periods and reliable triggering during wake movement epochs.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :app:testDebugUnitTest --tests "*DetectorReplayTest*"
    ```

- [ ] **2.6 Drift / SQLite Local Database Layer**
  - **Acceptance Criteria**: Stores sleep targets, shift notes, history sessions, and detector settings locally. Zero cloud calls.
  - **PowerShell Commands**:
    ```powershell
    flutter test test/data/database_test.dart
    ```

---

## Phase 3: Day 3 Integration & UI Polish (Deadline: Fri 6 Nov 2026)

- [ ] **3.1 Wear OS Custom Alarm Face & Progressive Haptics**
  - **Acceptance Criteria**: Compose for Wear OS alarm face displays ambient amber glow, swipe-to-dismiss, tap-to-snooze; ramps vibration smoothly from 20% to 100% over 60 seconds; syncs dismiss/snooze to phone via Data Layer.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :wear:testDebugUnitTest
    ```

- [ ] **3.2 Dual-Alarm Native Scheduling Integration**
  - **Acceptance Criteria**: Native alarm manager schedules guaranteed hard deadline alarm and wake window trigger simultaneously at arming; detector early firing cancels deadline alarm; disconnection leaves deadline alarm untouched.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :app:testDebugUnitTest --tests "*ExactAlarmSchedulerTest*"
    ```

- [ ] **3.3 Sleep-Shift Timeline Screen ("Obsidian & Amber Dawn")**
  - **Acceptance Criteria**: High-contrast dark theme; displays Target vs. Actual cards, delta tags (`+25m`, `-15m`), and engine shift notes with tabular typography.
  - **PowerShell Commands**:
    ```powershell
    flutter test test/presentation/timeline_screen_test.dart
    ```

- [ ] **3.4 Wake Monitor & Permission Diagnostics Hub**
  - **Acceptance Criteria**: Live status of Health Connect, Exact Alarm, Samsung Battery Optimization, and Wear pairing with direct deep links to One UI system settings.
  - **PowerShell Commands**:
    ```powershell
    flutter analyze
    ```

- [ ] **3.5 Stock Clock Backup Alarm Trigger**
  - **Acceptance Criteria**: Triggers `AlarmClock.ACTION_SET_ALARM` intent for deadline wake time if user opted in; UI clearly notes manual cancellation requirement.
  - **PowerShell Commands**:
    ```powershell
    flutter test test/data/native_alarm_gateway_test.dart
    ```

### Gate T2: Full Real-Night Device Test (Night of Fri 6 Nov 2026)
*Must be conducted overnight by author with S24 Ultra and Galaxy Watch 4 on wrist.*
- [ ] Set morning target with 30-minute wake window and stock backup alarm enabled.
- [ ] Confirm watch app indicates armed status.
- [ ] Lock phone, wear watch, and sleep normally.
- [ ] **T2.1**: Verify smart wake alarm triggers during wake window upon natural stirring (or at hard deadline).
- [ ] **T2.2**: Verify watch alarm face activates with gentle progressive haptics.
- [ ] **T2.3**: Dismiss alarm on watch $\to$ Confirm phone alarm dismisses simultaneously.
- [ ] **T2.4**: Open app 15 minutes post-wake $\to$ Verify Samsung Health synced to Health Connect $\to$ Verify adaptive engine calculated next day target and rendered explanation note on timeline.

---

## Phase 4: Day 4 Release, CI & Documentation (Deadline: Sat 7 Nov 2026)

- [ ] **4.1 T2 Overnight Anomaly Fixes**
  - **Acceptance Criteria**: Address any timing, synchronization, or sensitivity quirks identified during T2 overnight run.
  - **PowerShell Commands**:
    ```powershell
    flutter test
    .\gradlew.bat test
    ```

- [ ] **4.2 Comprehensive Project README**
  - **Acceptance Criteria**: Contains architecture Mermaid diagram, "Obsidian Dawn" UI walkthrough, documented detector heuristic and calibration notes, honest limitations (backup alarm manual cancel, Samsung Health sync latency), and zero AI attribution.
  - **PowerShell Commands**:
    ```powershell
    Test-Path README.md
    ```

- [ ] **4.3 GitHub Actions CI Workflow**
  - **Acceptance Criteria**: GitHub Actions workflow builds debug APK, runs Flutter analyzer, executes Dart unit tests with coverage, and compiles Wear OS module on `ubuntu-latest`.
  - **PowerShell Commands**:
    ```powershell
    git diff .github/workflows/ci.yml
    ```

### Gate T3: Final Release Build Verification (Sat 7 Nov 2026)
- [ ] Build release APKs:
  ```powershell
  flutter build apk --release
  .\gradlew.bat :wear:assembleRelease
  ```
- [ ] Perform clean install on S24 Ultra and Galaxy Watch 4.
- [ ] Complete onboarding flow, simulate a 1-day shift, and verify UI responsiveness.
- [ ] Push to public GitHub repository.

---

## Phase 5: Code Freeze & Presentation Preparation (15–18 Nov 2026)
*Strict feature freeze. Author reviews codebase and prepares presentation for GDG Bangalore Flutter Meetup.*
```

---

### File 3: `DECISIONS.md`

```markdown
# AdaptRise — Architecture Decision Records (ADRs)

---

### D-001: Native Wear OS Companion App & Health Foreground Service
* **Date**: 2026-11-04
* **Context**: The app requires streaming real-time accelerometer and PPG heart rate data from the Galaxy Watch 4 during the wake window and rendering a custom alarm face with progressive haptics.
* **Decision**: Build the Wear OS app as a native Kotlin module using Jetpack Compose for Wear OS. Run sensor collection within a foreground service declaring `android:foregroundServiceType="health"` with `BODY_SENSORS` and `WAKE_LOCK` permissions.
* **Consequences**:
  * Positive: Full access to Health Services / SensorManager; sensor collection continues uninterrupted when the watch display dims into ambient mode; low memory overhead.
  * Negative: Multi-module Gradle build (Flutter Android app + Kotlin Wear OS module).

---

### D-002: Pure Dart Deterministic Adaptive Target Engine
* **Date**: 2026-11-04
* **Context**: Core target adaptation logic must be reliable, explainable, and testable without black-box machine learning or hallucination risks.
* **Decision**: Implement the adaptive engine as a pure Dart library (`lib/domain/engine/`) with zero Flutter UI or native platform dependencies. Require $\ge 90\%$ automated unit test coverage.
* **Consequences**:
  * Positive: Fast headless unit tests; completely reproducible behavior; clear math suitable for meetup presentation.
  * Negative: Algorithmic tuning must be done manually via defined parameters.

---

### D-003: Health Connect as Historical Ingress (Post-Sleep Sync Model)
* **Date**: 2026-11-04
* **Context**: Samsung Health aggregates raw sleep stages overnight and syncs to Health Connect asynchronously after the user wakes up.
* **Decision**: Use Health Connect strictly for historical sleep ingestion after waking. Never rely on Health Connect for real-time wake window detection. If Samsung Health does not provide sleep stages (`SleepSessionRecord.Stage`), fall back to session start and end boundaries.
* **Consequences**:
  * Positive: Resilient against background sync latency; zero impact on alarm reliability.
  * Negative: Morning timeline updates require Samsung Health to complete its post-wake processing.

---

### D-004: Guaranteed Deadline Alarm & Dual-Alarm Scheduling
* **Date**: 2026-11-04
* **Context**: If the watch disconnects, the phone battery runs low, or sensor streaming fails during the wake window, the user must still wake up at their hard deadline.
* **Decision**: When arming an alarm, schedule two alarms simultaneously via `AlarmManager.setExactAndAllowWhileIdle()`:
  1. The Guaranteed Hard Deadline Alarm at $T_{target}$.
  2. The Wake Window Trigger Alarm at $T_{target} - W$.
  If the detector fires early, it cancels the hard deadline alarm. If the watch disconnects or no movement is detected, the hard deadline alarm remains intact and fires at $T_{target}$.
* **Consequences**:
  * Positive: Fail-safe reliability; impossible to oversleep due to Bluetooth dropped packets or service termination.
  * Negative: Requires managing cancellation of the pending deadline alarm upon early trigger.

---

### D-005: Stock Clock Backup Alarm Constraints (`ACTION_SET_ALARM`)
* **Date**: 2026-11-04
* **Context**: Users need fail-safe assurance against OEM aggressive process termination.
* **Decision**: Provide an opt-in setting to create a system alarm via `AlarmClock.ACTION_SET_ALARM` targeting the hard deadline. Explicitly document in the UI that Android does not allow third-party apps to cancel or edit stock alarms, so users must manually cancel it if woken early.
* **Consequences**:
  * Positive: Failsafe rings even if the phone OS terminates AdaptRise.
  * Negative: User must dismiss the backup alarm manually in Samsung Clock if woken early.

---

### D-006: Local-Only Privacy Architecture
* **Date**: 2026-11-04
* **Context**: Biometric heart rate and sleep patterns represent sensitive personal data.
* **Decision**: All application data is stored locally in SQLite/Drift databases. No remote user accounts, cloud endpoints, or external analytics SDKs are incorporated.
* **Consequences**:
  * Positive: Complete privacy; zero server infrastructure or maintenance costs; fully functional offline.
  * Negative: No cloud sync or automatic backup across device wipes.

---

### D-007: Strict 3-Gate Real-Device Testing Policy & T1 Telemetry Recording
* **Date**: 2026-11-04
* **Context**: Manual physical device testing (S24 Ultra + Watch 4) must be minimized to avoid developer fatigue, while algorithm tuning requires authentic sensor data.
* **Decision**: Real-device manual testing is restricted strictly to three milestone gates (T1, T2, T3). During Gate T1, the author records 15–30 minutes of real raw sensor data to disk (`t1_sensor_recording.csv`). Day-2 algorithm calibration and replay unit tests use this recorded dataset.
* **Consequences**:
  * Positive: Avoids ad-hoc physical testing interruptions; grounds detector thresholds in real hardware data.
  * Negative: Sensor anomalies unique to overnight sleep must wait for Gate T2.

---

### D-008: Review Tooling & Fallback Reviewer Policy
* **Date**: 2026-11-04
* **Context**: Automated reviews use `codex exec -m kr-codegen-claude --sandbox read-only` scoped to git diffs. Claude reviewer quota ends on 18 November 2026.
* **Decision**: Limit review iterations to a maximum of 6 per checklist item. If the same error repeats twice, halt and isolate root cause. Post-18 November, review tooling automatically falls back to `gemini-3.8-flash` [VERIFY]. OmniRoute configuration remains untouched.
* **Consequences**:
  * Positive: Efficient review loop with bounded resource usage.
  * Negative: Model behavior change on 18 November requires strict adherence to lint rules.

---

### D-009: Design System Direction — "Obsidian & Amber Dawn"
* **Date**: 2026-11-04
* **Context**: The app is viewed in dark environments before sleep and upon waking. Blue light and blinding white screens disrupt circadian recovery.
* **Decision**: Adopt the "Obsidian & Amber Dawn" visual identity:
  * Void background: `#08090C` with dark containers `#12141A` and `#1C1F26`.
  * Dawn accents: Warm amber `#FF9E3B` (590nm) and horizon terracotta `#E06C38`.
  * Typography: Tabular `Space Grotesk` for numbers, `Inter` for UI, `JetBrains Mono` for shift logic notes.
* **Consequences**:
  * Positive: Eye-friendly in dark rooms; visually distinctive for portfolio and meetup presentations.
  * Negative: Requires custom styling across all Flutter and Wear OS components.

---

### D-010: Android 14+ Foreground Service Architecture
* **Date**: 2026-11-04
* **Context**: Android 14 (API 34) strictly enforces foreground service types and restricts starting foreground services from the background.
* **Decision**:
  1. Trigger `WakeWindowForegroundService` from a BroadcastReceiver triggered by `AlarmManager.setExactAndAllowWhileIdle()`.
  2. Declare `foregroundServiceType="connectedDevice"` and `foregroundServiceType="specialUse"` in the phone manifest.
  3. Declare `foregroundServiceType="health"` in the Wear OS companion manifest.
  4. Provide in-app diagnostics directing users to exempt AdaptRise from One UI battery optimizations.
* **Consequences**:
  * Positive: Guaranteed background execution during the 30-minute window without OS killing.
  * Negative: Requires explicit permission onboarding screens and handling for permission denial states.

---

### D-011: Strict Zero AI / Assistant Attribution Policy
* **Date**: 2026-11-04
* **Context**: The repository is a public showcase for developer community presentation and must reflect professional human engineering standards.
* **Decision**: Absolutely zero references to AI tools, LLMs, prompts, assistant identities, or automated code generators shall appear in commit messages, source code comments, documentation, pull requests, or project notes.
* **Consequences**:
  * Positive: Clean, production-grade repository history.
  * Negative: Requires automated verification to prevent boilerplate leakage.

---

### D-012: Watch Disconnection Handling & Deadline Invariance
* **Date**: 2026-11-04
* **Context**: Wearable Bluetooth connections may disconnect during the night due to distance or battery drain.
* **Decision**: If telemetry ceases for $>60\text{ seconds}$ inside the wake window, the Kotlin detector enters `SENSOR_OFFLINE` state. It does not trigger immediately; instead, it allows the guaranteed hard deadline alarm to fire at $T_{target}$. If telemetry recovers before $T_{target}$, smart detection resumes.
* **Consequences**:
  * Positive: Prevents abrupt, false early alarms caused by transient radio interference.
  * Negative: Misses the light-sleep waking window if Bluetooth drops while stirring.

---

### D-013: Sample Replay Testing for Smart Wake Detector
* **Date**: 2026-11-04
* **Context**: Real-time wake window testing takes 30 minutes per iteration, which is infeasible for rapid development and CI workflows.
* **Decision**: Implement a recorded-epoch replay harness (`SampleReplayTest`) that feeds pre-recorded sensor timeseries into the detector faster than real-time.
* **Consequences**:
  * Positive: Rapid, deterministic regression testing in milliseconds.
  * Negative: Requires recording and maintaining representative telemetry fixture datasets.

---

### D-014: Configurable Detector Thresholds & Day-2 Calibration from T1 Recording
* **Date**: 2026-11-04
* **Context**: Hardcoded detector thresholds ($0.18\,g$ motion variance, $+8\%$ HR elevation, 5-minute quarantine) are unmeasured hypotheses prior to hardware testing.
* **Decision**: Mark initial thresholds as `[VERIFY]`, make all parameters user-configurable via settings, record raw sensor data during Gate T1, and calibrate default values on Day 2 against that empirical dataset.
* **Consequences**:
  * Positive: Eliminates ungrounded guesswork; ensures detector defaults align with real Galaxy Watch 4 sensor characteristics.
  * Negative: Final threshold defaults cannot be locked until Day 2.

---

### D-015: Native Kotlin Wake-Window Detector Execution (Background Survivability)
* **Date**: 2026-11-04
* **Context**: When the phone is locked for hours, Android Doze mode and OEM battery managers may suspend or terminate the Flutter Dart VM to conserve power.
* **Decision**: Execute the real-time wake window detector (`SmartWakeDetector.kt`) inside the native Android Kotlin layer (`WakeWindowForegroundService`), rather than in Dart. Keep the adaptive target engine, timeline notes, settings, and historical reporting in Dart.
* **Consequences**:
  * Positive: Highly robust against background process termination; detector evaluates incoming Wear OS packets instantly with native wake locks.
  * Negative: Wake detection logic exists in Kotlin, while schedule adaptation logic exists in Dart.

---

### D-016: Engine Response to Extreme Early Awakening (Case B.2)
* **Date**: 2026-11-04
* **Context**: A user may wake up substantially earlier than their target (deviation $\Delta_{oversleep} < -\Delta_{max}$). This may indicate either an intentional early schedule shift or accidental early awakening with sleep deficit.
* **Decision**:
  * If actual sleep duration $D_{actual} \ge D_{min}$ (went to bed early and achieved adequate rest), advance the next target toward actual wake time up to $\Delta_{max}$.
  * If actual sleep duration $D_{actual} < D_{min}$ (premature awakening with sleep debt), do **not** advance aggressively; apply only the standard gentle ramp $R_{ramp}$ toward $T_{goal}$ to protect baseline rest.
* **Consequences**:
  * Positive: Prevents compounding sleep deprivation from sleep disruptions while supporting genuine early rhythm shifts.
  * Negative: Requires accurate duration data from Health Connect.
```

---

E:\Projects\VSCode\PostOmniroute\AdaptRise\PLAN.md
E:\Projects\VSCode\PostOmniroute\AdaptRise\CHECKLIST.md
E:\Projects\VSCode\PostOmniroute\AdaptRise\DECISIONS.md