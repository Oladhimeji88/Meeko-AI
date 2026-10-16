import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../application/alarm_controller.dart';
import '../data/alarm_model.dart';

/// Create/edit a single alarm: time, label, repeat rule, vibration.
class AlarmEditScreen extends ConsumerStatefulWidget {
  const AlarmEditScreen({super.key, required this.alarm});
  final AlarmModel alarm;

  @override
  ConsumerState<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends ConsumerState<AlarmEditScreen> {
  late AlarmModel _draft = widget.alarm;
  late final TextEditingController _label =
      TextEditingController(text: widget.alarm.label);

  static const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Alarm'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SAVE', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: TextButton(
              onPressed: _pickTime,
              child: Text(_draft.timeLabel,
                  style: const TextStyle(fontSize: 72)),
            ),
          ),
          TextField(
            controller: _label,
            decoration: const InputDecoration(labelText: 'Label'),
            onChanged: (v) => _draft = _draft.copyWith(label: v),
          ),
          const SizedBox(height: 20),
          const Text('Repeat', style: TextStyle(fontSize: 20)),
          Wrap(
            spacing: 8,
            children: AlarmRepeat.values.map((r) {
              return ChoiceChip(
                label: Text(_repeatLabel(r)),
                selected: _draft.repeat == r,
                onSelected: (_) => setState(() {
                  _draft = _draft.copyWith(repeat: r);
                }),
              );
            }).toList(),
          ),
          if (_draft.repeat == AlarmRepeat.custom) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: List.generate(7, (i) {
                final wd = i + 1; // Mon=1
                final selected = _draft.customDays.contains(wd);
                return FilterChip(
                  label: Text(_weekdayNames[i]),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    final days = [..._draft.customDays];
                    selected ? days.remove(wd) : days.add(wd);
                    _draft = _draft.copyWith(customDays: days);
                  }),
                );
              }),
            ),
          ],
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Vibrate'),
            value: _draft.vibrate,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(vibrate: v)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _draft.hour, minute: _draft.minute),
    );
    if (picked != null) {
      setState(() =>
          _draft = _draft.copyWith(hour: picked.hour, minute: picked.minute));
    }
  }

  Future<void> _save() async {
    await ref.read(alarmControllerProvider.notifier).upsert(_draft);
    if (mounted) Navigator.of(context).pop();
  }

  static String _repeatLabel(AlarmRepeat r) => switch (r) {
        AlarmRepeat.once => 'Once',
        AlarmRepeat.daily => 'Daily',
        AlarmRepeat.weekdays => 'Weekdays',
        AlarmRepeat.weekends => 'Weekends',
        AlarmRepeat.custom => 'Custom',
      };
}
