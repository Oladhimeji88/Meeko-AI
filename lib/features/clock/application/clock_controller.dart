import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';

/// Emits the current [DateTime] every second to drive the live clock.
final clockTickerProvider = StreamProvider<DateTime>((ref) {
  late final StreamController<DateTime> controller;
  Timer? timer;
  controller = StreamController<DateTime>(
    onListen: () {
      controller.add(DateTime.now());
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => controller.add(DateTime.now()),
      );
    },
    onCancel: () => timer?.cancel(),
  );
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Transient mood override. Features (alarm ringing, AI talking, stopwatch
/// cheering) push a value here; null falls back to the time/weather mood.
final buddyMoodOverrideProvider = StateProvider<BuddyMood?>((ref) => null);

/// Time-of-day mood when nothing else is happening.
BuddyMood moodForHour(int hour) {
  if (hour >= 22 || hour < 6) return BuddyMood.sleepy;
  if (hour >= 6 && hour < 11) return BuddyMood.happy;
  return BuddyMood.neutral;
}

/// Smart, time- and weather-aware greeting.
String greetingFor(DateTime now, {WeatherCondition? weather}) {
  final h = now.hour;
  String base;
  if (h >= 5 && h < 12) {
    base = 'Good morning! ☀️';
  } else if (h >= 12 && h < 17) {
    base = 'Ready to tackle today?';
  } else if (h >= 17 && h < 22) {
    base = 'Good evening 🌆';
  } else {
    base = "Don't stay up too late 🌙";
  }
  if (weather == WeatherCondition.rain || weather == WeatherCondition.drizzle) {
    base += ' Grab an umbrella!';
  } else if (weather == WeatherCondition.snow) {
    base += ' Bundle up — it\'s snowy!';
  } else if (weather == WeatherCondition.thunderstorm) {
    base += ' Stay safe out there.';
  }
  return base;
}
