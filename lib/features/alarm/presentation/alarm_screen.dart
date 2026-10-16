import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../application/alarm_controller.dart';
import '../data/alarm_model.dart';
import 'alarm_edit_screen.dart';

/// List of alarms with quick enable/disable, edit, and delete.
class AlarmScreen extends ConsumerWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmControllerProvider);
    final controller = ref.read(alarmControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Alarm'),
        onPressed: () => _addAlarm(context, ref),
      ),
      body: alarms.isEmpty
          ? const Center(child: Text('No alarms yet. Tap + to add one.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: alarms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = alarms[i];
                return Dismissible(
                  key: ValueKey(a.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.withValues(alpha: 0.7),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => controller.delete(a),
                  child: Card(
                    child: ListTile(
                      onTap: () => _editAlarm(context, ref, a),
                      title: Text(a.timeLabel,
                          style: const TextStyle(fontSize: 40)),
                      subtitle: Text('${a.label} · ${_repeatLabel(a.repeat)}'),
                      trailing: Switch(
                        value: a.enabled,
                        onChanged: (v) => controller.toggle(a, v),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _addAlarm(BuildContext context, WidgetRef ref) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked == null) return;
    final created = await ref
        .read(alarmControllerProvider.notifier)
        .create(hour: picked.hour, minute: picked.minute);
    if (context.mounted) _editAlarm(context, ref, created);
  }

  void _editAlarm(BuildContext context, WidgetRef ref, AlarmModel a) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AlarmEditScreen(alarm: a)),
    );
  }

  static String _repeatLabel(AlarmRepeat r) => switch (r) {
        AlarmRepeat.once => 'Once',
        AlarmRepeat.daily => 'Daily',
        AlarmRepeat.weekdays => 'Weekdays',
        AlarmRepeat.weekends => 'Weekends',
        AlarmRepeat.custom => 'Custom',
      };
}
