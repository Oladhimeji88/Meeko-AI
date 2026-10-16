import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/di/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/alarm/application/alarm_controller.dart';
import 'features/alarm/presentation/alarm_ring_screen.dart';
import 'features/settings/application/settings_controller.dart';
import 'widgets/home_shell.dart';

/// Global navigator key so notification taps can push the ring screen from
/// outside the widget tree.
final navigatorKey = GlobalKey<NavigatorState>();

/// Root app. Rebuilds the theme whenever settings change.
class PixelBuddyApp extends ConsumerStatefulWidget {
  const PixelBuddyApp({super.key});

  @override
  ConsumerState<PixelBuddyApp> createState() => _PixelBuddyAppState();
}

class _PixelBuddyAppState extends ConsumerState<PixelBuddyApp> {
  @override
  void initState() {
    super.initState();
    // Route alarm notification taps to the full-screen ring experience.
    ref.read(notificationServiceProvider).onSelect = _handlePayload;
  }

  void _handlePayload(String? payload) {
    if (payload == null || !payload.startsWith('alarm:')) return;
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    Navigator.of(ctx)
        .push(MaterialPageRoute(builder: (_) => const AlarmRingScreen()))
        .then((result) => _afterRing(result));
  }

  void _afterRing(Object? result) {
    if (result == 'snooze') {
      final mins = ref.read(settingsControllerProvider).snoozeMinutes;
      final when = DateTime.now().add(Duration(minutes: mins));
      ref.read(notificationServiceProvider).scheduleAlarm(
            id: when.millisecondsSinceEpoch ~/ 1000,
            when: when,
            title: '⏰ Snoozed alarm',
            body: 'Back again! Rise and shine.',
          );
    }
    // Touch the alarm controller so nextAlarmProvider recomputes.
    ref.read(alarmControllerProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.fromSettings(settings),
      home: const HomeShell(),
    );
  }
}
