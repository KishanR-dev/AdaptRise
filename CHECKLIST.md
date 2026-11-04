# AdaptRise — Execution Checklist & Acceptance Verification

All automated tests and builds must be executed and pasted into agent reports before marking items complete.

---

## Phase 1: Day 1 Scaffold & Risk Spikes (Deadline: Wed 4 Nov 2026)

- [x] **1.1 Workspace Scaffolding & CI Baseline**
  - **Acceptance Criteria**: Flutter application initializes under package `dev.kishanr.adaptrise`; Wear OS module configured with Jetpack Compose for Wear OS; GitHub Actions workflow passes `flutter analyze` and `dart format`.
  - **PowerShell Commands**:
    ```powershell
    flutter create --org dev.kishanr.adaptrise --platforms android .
    dart format --output=none --set-exit-if-changed .
    flutter analyze
    ```

- [x] **1.2 Pigeon IPC Interface Generation**
  - **Acceptance Criteria**: `pigeons/messages.dart` generates `lib/data/platform/pigeon_api.g.dart` and `android/app/src/main/kotlin/dev/kishanr/adaptrise/bridge/PigeonApi.g.kt` without compilation errors or warnings.
  - **PowerShell Commands**:
    ```powershell
    dart run pigeon --input pigeons/messages.dart
    git status --porcelain
    ```

- [x] **1.3 Wear OS Companion Scaffold with Health FGS**
  - **Acceptance Criteria**: Wear OS project configures `WearSensorStreamingService` declaring `android:foregroundServiceType="health"` with `BODY_SENSORS` and `WAKE_LOCK` permissions; builds cleanly.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :wear:assembleDebug
    ```

- [x] **1.4 Risk Spike R1: Health Connect Ingress**
  - **Acceptance Criteria**: `HealthConnectBridge.kt` queries Health Connect on S24 Ultra. Logs verify if `SleepSessionRecord.Stage` data is returned by Samsung Health or only start/end timestamps.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :app:testDebugUnitTest --tests "*HealthConnectBridgeTest*"
    ```

- [x] **1.5 Risk Spike R2: Wear Data Layer Streaming & Raw Telemetry Logger**
  - **Acceptance Criteria**: Galaxy Watch 4 streams 5-second `SensorEpochPacket` objects across Data Layer while phone is locked; watch raw recorder outputs `t1_sensor_recording.csv` (accelerometer magnitude and HR) for Day-2 calibration.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :wear:assembleDebug
    .\gradlew.bat :app:assembleDebug
    ```

- [x] **1.6 Risk Spike R3: Dual Exact Alarm & Full-Screen Intent**
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

- [x] **2.1 Pure Dart Adaptive Target Engine**
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

- [x] **2.2 Timeline Shift Note Generator**
  - **Acceptance Criteria**: Deterministic string formatter generates human-readable explanations matching each adaptation decision with parameter tags.
  - **PowerShell Commands**:
    ```powershell
    flutter test test/engine/shift_calculator_test.dart
    ```

- [x] **2.3 Day-2 Sensor Calibration & Configurable Parameters**
  - **Acceptance Criteria**: Analyze `t1_sensor_recording.csv`; calibrate baseline resting variance and HR spike ratios; expose parameters in `DetectorConfig.kt` and `detector_preferences.dart` with defaults marked verified against sample.
  - **PowerShell Commands**:
    ```powershell
    python scripts/calibrate_thresholds.py test/fixtures/t1_raw_telemetry_sample.csv
    # Or Kotlin analysis harness
    ```

- [x] **2.4 Native Kotlin Smart Wake Window Detector**
  - **Acceptance Criteria**: `SmartWakeDetector.kt` runs inside `WakeWindowForegroundService`; enforces quarantine period `[VERIFY]`; evaluates configurable motion variance `[VERIFY]` and HR increase `[VERIFY]` across consecutive epochs; triggers early on light sleep; falls back to hard deadline.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :app:testDebugUnitTest --tests "*SmartWakeDetectorTest*"
    ```

- [x] **2.5 Recorded Sample Replay Test Suite**
  - **Acceptance Criteria**: Unit tests feed recorded epoch timeseries into `SmartWakeDetector`; verifies zero false alarms during deep sleep quiet periods and reliable triggering during wake movement epochs.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :app:testDebugUnitTest --tests "*DetectorReplayTest*"
    ```

- [x] **2.6 Drift / SQLite Local Database Layer**
  - **Acceptance Criteria**: Stores sleep targets, shift notes, history sessions, and detector settings locally. Zero cloud calls.
  - **PowerShell Commands**:
    ```powershell
    flutter test test/data/database_test.dart
    ```

---

## Phase 3: Day 3 Integration & UI Polish (Deadline: Fri 6 Nov 2026)

- [x] **3.1 Wear OS Custom Alarm Face & Progressive Haptics**
  - **Acceptance Criteria**: Compose for Wear OS alarm face displays ambient amber glow, swipe-to-dismiss, tap-to-snooze; ramps vibration smoothly from 20% to 100% over 60 seconds; syncs dismiss/snooze to phone via Data Layer.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :wear:testDebugUnitTest
    ```

- [x] **3.2 Dual-Alarm Native Scheduling Integration**
  - **Acceptance Criteria**: Native alarm manager schedules guaranteed hard deadline alarm and wake window trigger simultaneously at arming; detector early firing cancels deadline alarm; disconnection leaves deadline alarm untouched.
  - **PowerShell Commands**:
    ```powershell
    .\gradlew.bat :app:testDebugUnitTest --tests "*ExactAlarmSchedulerTest*"
    ```

- [x] **3.3 Sleep-Shift Timeline Screen ("Obsidian & Amber Dawn")**
  - **Acceptance Criteria**: High-contrast dark theme; displays Target vs. Actual cards, delta tags (`+25m`, `-15m`), and engine shift notes with tabular typography.
  - **PowerShell Commands**:
    ```powershell
    flutter test test/presentation/timeline_screen_test.dart
    ```

- [x] **3.4 Wake Monitor & Permission Diagnostics Hub**
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
