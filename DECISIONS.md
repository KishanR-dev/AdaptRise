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
