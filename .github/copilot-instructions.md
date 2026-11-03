# AdaptRise Copilot Instructions

## Project Overview
AdaptRise is an open-source, adaptive sleep-shift alarm for Android (Samsung Galaxy S24 Ultra) and Wear OS (Samsung Galaxy Watch 4).

## Architecture & Conventions
- **Flutter Phone App (`lib/`)**: Obsidian & Amber Dawn UI (`#08090C` void, `#FF9E3B` amber), pure Dart adaptive target engine (`lib/domain/engine/`, $\ge 90\%$ test coverage), local SQLite/Drift storage.
- **Android Companion (`android/app`)**: Native Kotlin layer handling `AlarmManager` exact scheduling, `WakeWindowForegroundService`, `HealthConnectBridge`, and Wear Data Layer ingress (`play-services-wearable`). Application ID: `dev.kishanr.adaptrise`.
- **Wear OS Companion (`android/wear`)**: Native Kotlin module in `android/` using Jetpack Compose for Wear OS, `WearSensorStreamingService` (foreground service type `health`), sensor collection, and haptic ramp controller. Shares `applicationId = "dev.kishanr.adaptrise"` and signing key with the phone app.
- **Privacy**: Local-only architecture; zero cloud calls, zero analytics.

## PowerShell Validation Commands
- **Flutter Format Check**: `dart format --output=none --set-exit-if-changed .`
- **Flutter Analysis**: `flutter analyze`
- **Flutter Tests with Coverage**: `flutter test --coverage`
- **Android Phone Gradle Build & Unit Tests**: `cd android; .\gradlew.bat :app:assembleDebug; .\gradlew.bat :app:testDebugUnitTest`
- **Wear OS Gradle Build & Unit Tests**: `cd android; .\gradlew.bat :wear:assembleDebug; .\gradlew.bat :wear:testDebugUnitTest`
- **Kotlin Lint / Analysis**: `cd android; .\gradlew.bat ktlintCheck detekt`
