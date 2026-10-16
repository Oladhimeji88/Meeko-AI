import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/enums.dart';
import '../../settings/application/settings_controller.dart';
import '../../weather/application/weather_controller.dart';
import '../application/clock_controller.dart';
import 'widgets/pixel_buddy.dart';

/// The home screen: live pixel clock + character + greeting + weather chip.
/// Supports portrait and a desk-clock landscape layout.
class ClockScreen extends ConsumerWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final tick = ref.watch(clockTickerProvider).valueOrNull ?? DateTime.now();
    final weather = ref.watch(weatherProvider).valueOrNull;
    final override = ref.watch(buddyMoodOverrideProvider);

    final mood = override ??
        (settings.weatherEnabled && weather != null
            ? weather.condition.buddyMood
            : moodForHour(tick.hour));

    final timeFmt = settings.use24HourFormat ? 'HH:mm' : 'h:mm';
    final timeStr = DateFormat(timeFmt).format(tick);
    final secStr = DateFormat('ss').format(tick);
    final ampm = settings.use24HourFormat ? '' : DateFormat('a').format(tick);
    final dateStr = DateFormat('EEEE, MMM d').format(tick);

    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final landscape = orientation == Orientation.landscape;
            final buddy = PixelBuddy(
              mood: mood,
              body: settings.body,
              eye: settings.eye,
              accent: settings.accent,
              size: landscape ? 180 : 240,
            );
            final info = _ClockInfo(
              greeting: greetingFor(tick, weather: weather?.condition),
              timeStr: timeStr,
              secStr: secStr,
              ampm: ampm,
              dateStr: dateStr,
              settings: settings,
              weatherChip: weather == null
                  ? null
                  : _WeatherChip(
                      text:
                          '${weather.condition.emoji}  ${weather.temperatureC.round()}°C · ${weather.description}',
                      color: settings.text,
                    ),
            );

            if (landscape) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Center(child: buddy)),
                  Expanded(child: Center(child: info)),
                ],
              );
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buddy,
                const SizedBox(height: 24),
                info,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ClockInfo extends StatelessWidget {
  const _ClockInfo({
    required this.greeting,
    required this.timeStr,
    required this.secStr,
    required this.ampm,
    required this.dateStr,
    required this.settings,
    required this.weatherChip,
  });

  final String greeting;
  final String timeStr;
  final String secStr;
  final String ampm;
  final String dateStr;
  final dynamic settings;
  final Widget? weatherChip;

  @override
  Widget build(BuildContext context) {
    final color = settings.text as Color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(greeting,
            style: TextStyle(fontSize: 22, color: color.withValues(alpha: 0.85))),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 96,
                height: 1,
                color: color,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                      color: (settings.accent as Color).withValues(alpha: 0.5),
                      blurRadius: 16)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 4),
              child: Text(':$secStr $ampm',
                  style: TextStyle(
                      fontSize: 28, color: color.withValues(alpha: 0.7))),
            ),
          ],
        ),
        Text(dateStr, style: TextStyle(fontSize: 24, color: color.withValues(alpha: 0.8))),
        if (weatherChip != null) ...[
          const SizedBox(height: 16),
          weatherChip!,
        ],
      ],
    );
  }
}

class _WeatherChip extends StatelessWidget {
  const _WeatherChip({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(text, style: TextStyle(fontSize: 18, color: color)),
    );
  }
}

/// Keep the screen awake on the clock (always-on display friendly).
class KeepAwake {
  static void enable() => SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
}
