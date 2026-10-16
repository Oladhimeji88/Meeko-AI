# Enhancement Roadmap

These features have **architecture hooks already in the codebase** but require
platform-native work to fully ship. Each entry notes where to start.

## Native home-screen widgets (Android) — #11
- Add the [`home_widget`](https://pub.dev/packages/home_widget) package.
- Create an `AppWidgetProvider` (or Jetpack Glance) with small/medium/large
  layouts under `android/app/src/main/res/layout/`.
- Push data from Dart: time (`clockTickerProvider`), weather
  (`weatherProvider`), next alarm (`nextAlarmProvider`).
- iOS counterpart: a WidgetKit extension target reading from a shared App Group.

## Lock-screen / Always-on display — #12
- Landscape **desk-clock mode** already works (`ClockScreen` `OrientationBuilder`).
- `wakelock_plus` keeps the screen awake on the ring screen; extend to a
  dedicated always-on screen with dimmed colors + burn-in shift.

## "Hey PixelBuddy" wake word — enhancement
- `AppSettings.wakePhraseEnabled` flag + premium gate exist.
- Integrate an on-device hotword engine (e.g. Porcupine / `flutter_porcupine`)
  in a foreground service; on detection call `VoiceService.listen`.

## iOS Live Activities / Dynamic Island — enhancement
- Add an ActivityKit widget extension; start an activity when an alarm/timer is
  armed, driven from `nextAlarmProvider` / `timerControllerProvider`.

## Wear OS / Apple Watch companions — enhancement
- Wear OS: a separate Flutter or native module showing the buddy + time, syncing
  via the Data Layer API.
- watchOS: a SwiftUI companion target sharing an App Group with the phone.

## Pixel pet evolution — enhancement
- XP/level already accumulate (`SettingsController.addXp`,
  `AppSettings.petLevel`).
- Map level thresholds to painter variations in `PixelBuddyPainter` (size,
  accessories, color shifts) for visible evolution stages.

## Mood system — partially done
- `BuddyMood` drives expression today (time, weather, alarm, AI, stopwatch).
- Extend with persistent mood that decays/improves based on interaction streaks.

## Battery-reactive animations — enhancement
- Add `battery_plus`; feed level into `PixelBuddy` to show a low-battery "tired"
  variant or a charging spark accessory.

## Daily briefing scheduling — service ready
- `NotificationService.showBriefing` exists. Schedule it daily with a
  `zonedSchedule` repeating notification combining greeting + weather + next
  alarm.
