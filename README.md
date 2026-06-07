# 🎮 PixelBuddy Clock

A modern **pixel-art smart clock companion** built with Flutter. PixelBuddy is a
cute HD pixel character with expressive block eyes that react to the time,
weather, alarms, your interactions, and AI conversations.

> Retro pixel art × Smart alarm clock × Weather station × AI assistant × Productivity companion.

---

## ✨ What's in this build

This repository is a **complete, compiling Flutter foundation** with clean
architecture (Riverpod + Repository + MVVM + DI). The core experience is fully
functional; advanced platform integrations are scaffolded with clear extension
points (see the [status table](#feature-status)).

The PixelBuddy character is drawn **programmatically with a `CustomPainter`** on
a 32×32 pixel grid — so it's true, crisp HD pixel art at any resolution with
**zero binary image assets** to ship or scale.

### Feature status

| # | Feature | Status |
|---|---------|--------|
| 1 | Pixel clock face (blink, eye-tracking, moods, talking) | ✅ Implemented |
| 2 | Custom themes (background/body/eyes/text/accent + HEX picker, persisted) | ✅ Implemented |
| 3 | Weather system (OpenWeatherMap + reactive buddy + demo fallback) | ✅ Implemented |
| 4 | Alarm clock (CRUD, repeat rules, full-screen ring, vibrate, snooze) | ✅ Implemented |
| 5 | Timer (presets + custom, multiple concurrent, pause/resume/reset) | ✅ Implemented |
| 6 | Stopwatch (start/pause/lap/reset + buddy cheer) | ✅ Implemented |
| 7 | AI companion (chat, jokes, advice, feature help) | ✅ Implemented |
| 8 | AI voice (TTS + STT, mouth animation) | ✅ Implemented |
| 9 | AI personality modes (Friendly / Motivator / Chill / Retro Gamer) | ✅ Implemented |
| 10 | AI provider abstraction (OpenAI / Claude / Gemini / Local) | ✅ Implemented |
| 11 | Home-screen widgets (Android) | 🟡 Architected — see roadmap |
| 12 | Lock-screen / always-on data | 🟡 Partial (wakelock + landscape desk mode) |
| 13 | Smart greetings (time + weather aware) | ✅ Implemented |
| 14 | Notifications (daily briefing + reminders) | ✅ Service implemented |
| 15 | Data storage (Hive + secure storage for keys) | ✅ Implemented |
| 16 | Clean architecture (Riverpod/Repo/DI/MVVM) | ✅ Implemented |
| 17 | UI (dark/light, pixel aesthetic, responsive, landscape) | ✅ Implemented |
| 18 | Premium-ready architecture (no payment gateway) | ✅ Flags + gating |
| 19 | Pixel pet XP/level + mood system | ✅ Implemented |

**Roadmap / scaffolded enhancements** (hooks present, native work outlined in
[`docs/ROADMAP.md`](docs/ROADMAP.md)): native home-screen widgets, "Hey
PixelBuddy" wake-word, iOS Live Activities / Dynamic Island, Wear OS / Apple
Watch companions, pet evolution stages, battery-reactive animations.

---

## 🏗 Architecture

```
lib/
├── main.dart                # bootstrap: init services, ProviderScope overrides
├── app.dart                 # MaterialApp, theme binding, notification routing
├── core/
│   ├── constants/           # keys, channel ids, endpoints
│   ├── di/                  # Riverpod provider container
│   ├── enums.dart           # BuddyMood, WeatherCondition, AiProviderType, ...
│   └── theme/               # AppTheme.fromSettings()
├── services/                # storage (Hive+secure), notifications, voice, location
├── features/
│   ├── clock/               # ticker, greetings, pixel character + painter
│   ├── weather/             # model, repository, controller (Riverpod)
│   ├── alarm/               # model, repository, controller, list/edit/ring UI
│   ├── timer/               # multi-timer controller + UI
│   ├── stopwatch/           # stopwatch controller + UI
│   ├── ai/                  # provider abstraction, 4 providers, repo, chat UI
│   └── settings/            # settings model controller + screen
├── shared/models/           # AppSettings (immutable + JSON)
└── widgets/                 # HomeShell (bottom navigation)
```

**Patterns used**
- **State management & DI:** Riverpod (`StateNotifier`, `Provider`, `FutureProvider`).
- **Repository pattern:** each feature has a `data/` repository over storage/HTTP.
- **MVVM:** `*_controller.dart` are view-models; `presentation/` are views.
- **Strategy:** `AiProvider` interface with swappable concrete back-ends.
- **Persistence:** Hive for structured data; `flutter_secure_storage` for API keys.

---

## 🚀 Setup

```bash
# 1. Install Flutter 3.6+ (Dart 3.6+). Verify:
flutter doctor

# 2. Fetch dependencies
flutter pub get

# 3. Run on a connected device / emulator
flutter run
```

The app runs immediately with **no API keys** — weather shows demo data and the
**Local** AI provider answers offline.

### Add your own keys (Settings → AI / Weather)
Keys are stored in the platform keychain/keystore via `flutter_secure_storage`,
never in plain storage:
- **Weather:** [OpenWeatherMap](https://openweathermap.org/api) free key.
- **AI:** paste an OpenAI, Claude, or Gemini key and pick the provider in Settings.

---

## 📦 Build instructions

### Android APK
```bash
flutter build apk --release            # universal APK
# or split per ABI (smaller installs):
flutter build apk --split-per-abi --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

Install on a device:
```bash
flutter install                        # or: adb install <path-to-apk>
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
# build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA
```bash
flutter build ipa --release            # requires macOS + Xcode + Apple Developer account
# build/ios/ipa/*.ipa
```
Open `ios/Runner.xcworkspace` in Xcode to set your signing team first.

See [`docs/BUILD.md`](docs/BUILD.md) and [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md)
for signing, release config, and store submission.

---

## 🔐 Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`): INTERNET,
POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM/USE_EXACT_ALARM,
USE_FULL_SCREEN_INTENT, WAKE_LOCK, VIBRATE, ACCESS_FINE/COARSE_LOCATION,
RECORD_AUDIO, RECEIVE_BOOT_COMPLETED.

**iOS** (`ios/Runner/Info.plist`): location, microphone, and speech-recognition
usage strings + background audio/fetch/remote-notification modes.

---

## 🎨 App icon

A placeholder launcher icon ships from `flutter create`. To generate branded
pixel icons, drop a 1024×1024 PNG and use
[`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons), or
replace the `android/app/src/main/res/mipmap-*` and
`ios/Runner/Assets.xcassets/AppIcon.appiconset` images. See `docs/ASSETS.md`.

---

## 🧪 Tests
```bash
flutter test
flutter analyze
```

---

## 📄 License
MIT — add your own `LICENSE` file before publishing.
