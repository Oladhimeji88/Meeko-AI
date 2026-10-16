import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../clock/application/clock_controller.dart';
import '../../clock/presentation/widgets/pixel_buddy.dart';
import '../../settings/application/settings_controller.dart';
import '../application/stopwatch_controller.dart';

String formatStopwatch(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final cs = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
  return '$m:$s.$cs';
}

class StopwatchScreen extends ConsumerWidget {
  const StopwatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stopwatchControllerProvider);
    final controller = ref.read(stopwatchControllerProvider.notifier);
    final s = ref.watch(settingsControllerProvider);

    // Buddy cheers for a moment when the stopwatch starts.
    controller.onStart = () {
      ref.read(buddyMoodOverrideProvider.notifier).state = BuddyMood.cheering;
      Future.delayed(const Duration(seconds: 3), () {
        if (ref.read(buddyMoodOverrideProvider) == BuddyMood.cheering) {
          ref.read(buddyMoodOverrideProvider.notifier).state = null;
        }
      });
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          PixelBuddy(
            mood: state.running ? BuddyMood.cheering : BuddyMood.neutral,
            body: s.body,
            eye: s.eye,
            accent: s.accent,
            size: 120,
          ),
          Text(formatStopwatch(state.elapsed),
              style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: state.running ? controller.pause : controller.start,
                child: Text(state.running ? 'PAUSE' : 'START'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: state.running ? controller.lap : controller.reset,
                child: Text(state.running ? 'LAP' : 'RESET'),
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: state.laps.length,
              itemBuilder: (context, i) {
                final lapNum = state.laps.length - i;
                return ListTile(
                  dense: true,
                  leading: Text('Lap $lapNum'),
                  trailing: Text(formatStopwatch(state.laps[i]),
                      style: const TextStyle(fontSize: 20)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
