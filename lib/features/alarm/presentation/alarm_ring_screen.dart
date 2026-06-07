import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/enums.dart';
import '../../clock/presentation/widgets/pixel_buddy.dart';
import '../../settings/application/settings_controller.dart';
import '../data/alarm_model.dart';

/// Full-screen takeover shown when an alarm fires: wakes the device, plays a
/// sound, vibrates, and shows the surprised PixelBuddy. Dismiss or snooze.
class AlarmRingScreen extends ConsumerStatefulWidget {
  const AlarmRingScreen({super.key, this.alarm});
  final AlarmModel? alarm;

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startRinging();
  }

  Future<void> _startRinging() async {
    WakelockPlus.enable();
    final vibrate = widget.alarm?.vibrate ?? true;
    if (vibrate && (await Vibration.hasVibrator())) {
      Vibration.vibrate(pattern: [0, 600, 400, 600, 400], repeat: 0);
    }
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(widget.alarm?.soundAsset ?? 'sounds/alarm.mp3'));
    } catch (_) {
      // Sound asset missing in dev — vibration still fires.
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    Vibration.cancel();
    WakelockPlus.disable();
  }

  @override
  void dispose() {
    _stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsControllerProvider);
    final label = widget.alarm?.label ?? 'Alarm';
    return Scaffold(
      backgroundColor: s.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PixelBuddy(
                mood: BuddyMood.surprised,
                body: s.body,
                eye: s.eye,
                accent: s.accent,
                size: 220,
              ),
              const SizedBox(height: 24),
              Text(DateFormat('h:mm a').format(DateTime.now()),
                  style: TextStyle(fontSize: 64, color: s.text)),
              Text(label, style: TextStyle(fontSize: 28, color: s.text)),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RingButton(
                    label: 'SNOOZE',
                    color: s.accent,
                    onTap: () async {
                      await _stop();
                      if (mounted) Navigator.of(context).pop('snooze');
                    },
                  ),
                  const SizedBox(width: 24),
                  _RingButton(
                    label: 'DISMISS',
                    color: s.body,
                    onTap: () async {
                      await _stop();
                      if (mounted) Navigator.of(context).pop('dismiss');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Snooze: ${s.snoozeMinutes} min',
                  style: TextStyle(color: s.text.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingButton extends StatelessWidget {
  const _RingButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 24, color: Colors.black, letterSpacing: 1)),
      ),
    );
  }
}
