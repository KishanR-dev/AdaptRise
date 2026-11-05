# AdaptRise

AdaptRise is an open-source, adaptive sleep-shift alarm engineered for Android (Samsung Galaxy S24 Ultra, API 34+) and Wear OS (Samsung Galaxy Watch 4, API 33+). The system dynamically adjusts waking targets based on past sleep duration ingested from Health Connect and monitors a 30-minute smart wake window using real-time wrist telemetry (accelerometer variance and photoplethysmography heart rate) streamed over the Google Play Services Wearable Data Layer.

---

## Architecture Overview

AdaptRise combines a Flutter presentation layer with native Android background services and a standalone Wear OS Compose application:

```mermaid
flowchart TD
    subgraph Watch ["Samsung Galaxy Watch 4 (Wear OS 4+ Native Kotlin)"]
        W_FGS["WearSensorStreamingService\n(FGS Type: health)"]
        W_Sensors["SensorManager / Health Services\n(Accelerometer + PPG Heart Rate)"]
        W_Accumulator["EpochWindowAccumulator\n(5s Movement Variance + Mean HR)"]
        W_DataLayer["Wearable Data Layer\n(MessageClient / ChannelClient)"]
        W_AlarmUI["Custom Alarm Face UI\n(Compose for Wear OS + Progressive Haptics)"]

        W_FGS --> W_Sensors
        W_Sensors --> W_Accumulator
        W_Accumulator --> W_DataLayer
        W_DataLayer -.->|Dismiss / Snooze Sync| W_AlarmUI
    end

    subgraph Phone_Native ["Samsung Galaxy S24 Ultra (Native Android / Kotlin)"]
        P_AlarmMgr["AlarmManager\n(setExactAndAllowWhileIdle)"]
        P_HardAlarm["Guaranteed Hard Deadline Alarm\n(Scheduled At Arming)"]
        P_WindowAlarm["Wake Window Trigger Alarm\n(T_target - WakeWindowMinutes)"]
        P_FGS["WakeWindowForegroundService\n(FGS Type: connectedDevice)"]
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

## Core Features & Mathematical Formulations

### 1. Pure Dart Adaptive Target Engine
Target adjustments execute deterministically in Dart (`lib/domain/engine/`) without black-box machine learning or external cloud services:

* **Goal Time ($T_{goal}$)**: Long-term target wake time (default `06:30`).
* **Target Wake Time ($T_{target, d}$)**: Scheduled wake time for day $d$.
* **Actual Wake Time ($T_{actual, d}$)**: Ingested wake timestamp from Health Connect.
* **Sleep Onset ($S_{onset, d}$)**: Initial sleep timestamp for day $d$.
* **Actual Sleep Duration ($D_{actual, d}$)**: Net sleep minutes recorded overnight.
* **Minimum Baseline Sleep ($D_{min}$)**: 420 minutes ($7.0\text{ hours}$).
* **Max Daily Adjustment ($\Delta_{max}$)**: 30 minutes.
* **Daily Recovery Ramp ($R_{ramp}$)**: 15 minutes.
* **Grace Period Window ($\epsilon_{grace}$)**: 10 minutes.

$$\Delta_{oversleep} = T_{actual, d} - T_{target, d}$$

#### Case A: Overslept ($\Delta_{oversleep} > \epsilon_{grace}$)
$$T_{target, d+1} = T_{target, d} + \min(\Delta_{oversleep}, \Delta_{max})$$
*Eases target forward to prevent abrupt circadian shock.*

#### Case B.1: On-Time / Mild Early ($-\Delta_{max} \le \Delta_{oversleep} \le \epsilon_{grace}$)
$$\text{If } T_{target, d} > T_{goal}: \quad T_{target, d+1} = \max(T_{goal}, T_{target, d} - R_{ramp})$$
$$\text{If } T_{target, d} \le T_{goal}: \quad T_{target, d+1} = T_{goal}$$
*Gently advances wake time by $R_{ramp}$ toward $T_{goal}$.*

#### Case B.2a: Substantial Early Awakening with Sufficient Rest ($\Delta_{oversleep} < -\Delta_{max}$ and $D_{actual, d} \ge D_{min}$)
$$T_{target, d+1} = \max(T_{goal}, T_{target, d} - \min(|\Delta_{oversleep}|, \Delta_{max}))$$
*Advances target toward spontaneous early wake time up to $\Delta_{max}$.*

#### Case B.2b: Substantial Early Awakening with Sleep Debt ($\Delta_{oversleep} < -\Delta_{max}$ and $D_{actual, d} < D_{min}$)
$$T_{target, d+1} = \max(T_{goal}, T_{target, d} - R_{ramp})$$
*Prevents entraining sleep deprivation; applies only the standard gentle ramp $R_{ramp}$.*

#### Case C: Delayed Sleep Onset Override ($T_{target, d+1} - S_{onset, d} < D_{min}$)
$$T_{target, d+1} = \min(T_{target, d+1} + \Delta_{max}, S_{onset, d} + D_{min})$$
*Protects the 7-hour physiological sleep reserve regardless of morning waking metrics.*

---

### 2. Smart Wake Window Heuristics (Native Kotlin)

The detector executes natively inside `WakeWindowForegroundService` on Android to survive Doze mode and lock-screen conditions:

1. **Dual Alarm Scheduling**: When armed, `AlarmManager.setExactAndAllowWhileIdle()` schedules the guaranteed hard deadline at $T_{target}$ and the wake window at $T_{target} - 30\text{ min}$.
2. **Quarantine Window**: The initial 5 minutes of the wake window are quarantined; sensor triggers are suppressed to eliminate false positives caused by posture shifting into the window.
3. **Cumulative Heart Rate Baseline**: Computes the exact cumulative average resting heart rate during quarantine, preventing exponential moving average drift.
4. **Motion Variance Threshold**: Evaluates 5-second sample motion variance:
   $$Var(|a|) = \frac{1}{N - 1} \sum_{i=1}^N (a_i - \bar{a})^2$$
   Calibrated threshold: $\tau_{motion} = 0.15\,g$.
5. **Heart Rate Spike Ratio**: Detects sympathetic autonomic arousal:
   $$\frac{HR_{epoch}}{\overline{HR}_{baseline}} \ge 1.08 \quad (+8\%)$$
6. **Persistence Gating**: Motion or composite elevations must persist across $K = 2$ consecutive epochs (10 seconds) before triggering.
7. **Fail-Safe Deadline**: Early triggering dismisses watch streaming, fires `FullScreenAlarmActivity`, and cancels the hard deadline alarm. If no stirring is detected, or if Bluetooth disconnects, the hard deadline alarm fires at $T_{target}$ unconditionally.

---

## "Obsidian & Amber Dawn" Design System

Designed for low-light bedroom environments and circadian protection:

| Token | Hex Value | Role |
| :--- | :--- | :--- |
| **Obsidian Void** | `#08090C` | True black base background for OLED power efficiency |
| **Surface Container** | `#12141A` | Elevation 1 card backgrounds |
| **Surface Card Active** | `#1C1F26` | Elevation 2 interactive and selected elements |
| **Amber Dawn Primary** | `#FF9E3B` | 590nm warm amber accent for clocks and primary actions |
| **Horizon Terracotta** | `#E06C38` | Secondary warm accent for forward shifts |
| **Text High Contrast** | `#F2F4F8` | 90% opacity off-white for primary readability |
| **Text Muted** | `#8A91A0` | Secondary metadata and labels |
| **Sync Success** | `#4ECCA3` | Health Connect and system diagnostic status indicator |
| **Alert / Hard Wake** | `#FF5376` | Critical warnings and dismiss indicators |

Typography pairs tabular numeric clock faces with clean interface typography and monospaced technical decision tags.

---

## Platform Constraints & Architectural Decisions

* **Health Connect Ingestion Model (D-003)**: Samsung Health calculates granular sleep stages asynchronously after awakening. Health Connect is queried strictly post-wake for historical timeline adaptation, never during live wake windows.
* **Samsung One UI Battery Restrictions**: Android 14+ requires setting AdaptRise's battery policy to **"Unrestricted"** in system settings to prevent One UI process termination during Doze mode.
* **System Stock Clock Backup Constraint (D-005)**: For users requiring an external fail-safe, AdaptRise can invoke `AlarmClock.ACTION_SET_ALARM`. Note that Android security policy prohibits third-party applications from canceling stock system alarms. Users waking early must dismiss stock alarms manually in Samsung Clock.
* **Local-Only Privacy (D-006)**: All sleep biometric telemetry, targets, and notes remain stored locally in SQLite via Drift. Zero cloud infrastructure or tracking SDKs are utilized.

---

## Build & Verification Guide

### Prerequisites
* Flutter SDK (3.24+ / Dart 3.5+)
* Android SDK 35 (Platform Tools, Build Tools 35.0.0)
* OpenJDK 17
* NDK `25.1.8937393`

### Project Verification Commands
```powershell
# Format check
dart format --output=none --set-exit-if-changed lib/ test/

# Static code analysis
flutter analyze

# Execute all Flutter unit and widget tests
flutter test --coverage

# Compile Android Phone application
cd android
.\gradlew.bat :app:assembleDebug :app:testDebugUnitTest

# Compile Wear OS companion application
.\gradlew.bat :wear:assembleDebug :wear:testDebugUnitTest
```

---

## License

This project is open-source software licensed under the MIT License.
