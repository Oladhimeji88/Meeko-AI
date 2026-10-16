# Build Guide

## Prerequisites

- Flutter 3.6+ / Dart 3.6+ (`flutter doctor` should be all green).
- **Android:** Android Studio + SDK, a device or emulator (API 23+).
- **iOS:** macOS, Xcode 15+, CocoaPods, an Apple Developer account for device installs.

## First run

```bash
flutter pub get
flutter run            # picks the connected device
```

## Android — debug APK

```bash
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## Android — release APK

```bash
flutter build apk --release
# Universal APK at:
#   build/app/outputs/flutter-apk/app-release.apk

# Smaller, per-architecture APKs:
flutter build apk --split-per-abi --release
```

> The template `release` build type is signed with the **debug** keystore so it
> installs on real devices out of the box. Configure a real keystore before
> publishing (see DEPLOYMENT.md).

### Core library desugaring
`android/app/build.gradle.kts` enables `isCoreLibraryDesugaringEnabled` and adds
`desugar_jdk_libs` — required by `flutter_local_notifications`. `minSdk` is
raised to 23 for secure storage + notifications.

## Android — Play Store bundle

```bash
flutter build appbundle --release
# build/app/outputs/bundle/release/app-release.aab
```

## iOS — device / IPA

```bash
cd ios && pod install && cd ..
open ios/Runner.xcworkspace        # set Signing Team in Xcode → Runner target
flutter build ipa --release
# build/ios/ipa/*.ipa
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Could not resolve desugar_jdk_libs` | Ensure Google Maven; bump version in `build.gradle.kts`. |
| Notifications don't fire | Grant "Alarms & reminders" + notification permission in system settings. |
| TTS/STT silent | Confirm microphone permission and a system TTS/recognition engine is installed. |
| Weather shows "Demo City" | No weather API key set, or location/network unavailable. |
| iOS Pod errors | `cd ios && pod repo update && pod install`. |
