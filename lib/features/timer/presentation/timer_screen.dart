import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/timer_controller.dart';

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  static const _presets = <(String, Duration)>[
    ('5 min', Duration(minutes: 5)),
    ('10 min', Duration(minutes: 10)),
    ('Pomodoro', Duration(minutes: 25)),
    ('1 hour', Duration(hours: 1)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.watch(timerControllerProvider);
    final controller = ref.read(timerControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Timers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (label, d) in _presets)
                  ActionChip(
                    label: Text(label),
                    onPressed: () => controller.add(d, label: label),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Custom'),
                  onPressed: () => _addCustom(context, controller),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: timers.isEmpty
                ? const Center(child: Text('Pick a preset to start a timer.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: timers.length,
                    itemBuilder: (context, i) =>
                        _TimerTile(timer: timers[i], controller: controller),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCustom(
      BuildContext context, TimerController controller) async {
    final picked = await showDialog<Duration>(
      context: context,
      builder: (_) => const _CustomTimerDialog(),
    );
    if (picked != null && picked > Duration.zero) {
      controller.add(picked, label: 'Custom');
    }
  }
}

class _TimerTile extends StatelessWidget {
  const _TimerTile({required this.timer, required this.controller});
  final CountdownTimer timer;
  final TimerController controller;

  @override
  Widget build(BuildContext context) {
    final done = timer.finished;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(timer.label, style: const TextStyle(fontSize: 22)),
                Text(
                  done ? "TIME'S UP!" : formatDuration(timer.remaining),
                  style: TextStyle(
                    fontSize: 40,
                    color: done ? Theme.of(context).colorScheme.error : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: timer.progress),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!done)
                  IconButton(
                    icon: Icon(timer.running ? Icons.pause : Icons.play_arrow),
                    onPressed: () => timer.running
                        ? controller.pause(timer.id)
                        : controller.resume(timer.id),
                  ),
                IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: () => controller.reset(timer.id),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.remove(timer.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTimerDialog extends StatefulWidget {
  const _CustomTimerDialog();
  @override
  State<_CustomTimerDialog> createState() => _CustomTimerDialogState();
}

class _CustomTimerDialogState extends State<_CustomTimerDialog> {
  int _minutes = 15;
  int _seconds = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Timer'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Stepper(
              label: 'min',
              value: _minutes,
              onChanged: (v) => setState(() => _minutes = v.clamp(0, 180))),
          const Text(':', style: TextStyle(fontSize: 28)),
          _Stepper(
              label: 'sec',
              value: _seconds,
              onChanged: (v) => setState(() => _seconds = v.clamp(0, 59))),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
              context, Duration(minutes: _minutes, seconds: _seconds)),
          child: const Text('Start'),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper(
      {required this.label, required this.value, required this.onChanged});
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: () => onChanged(value + 1)),
        Text(value.toString().padLeft(2, '0'),
            style: const TextStyle(fontSize: 32)),
        Text(label),
        IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => onChanged(value - 1)),
      ],
    );
  }
}
