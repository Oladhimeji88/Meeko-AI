import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/app_constants.dart';

/// Schedules alarms, the daily briefing, and reminder notifications.
///
/// Alarms use a high-importance, full-screen-intent channel so they can wake
/// the device and show the ringing screen on Android.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Called when a notification is tapped (e.g. alarm). Wired up in app.dart
  /// to route to the ringing screen.
  void Function(String? payload)? onSelect;

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (resp) => onSelect?.call(resp.payload),
    );

    await _createChannels();
  }

  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.alarmChannelId,
        AppConstants.alarmChannelName,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.generalChannelId,
        AppConstants.generalChannelName,
        importance: Importance.defaultImportance,
      ),
    );
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  AndroidNotificationDetails get _alarmAndroid =>
      const AndroidNotificationDetails(
        AppConstants.alarmChannelId,
        AppConstants.alarmChannelName,
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        ongoing: true,
        autoCancel: false,
      );

  /// Schedule a one-shot alarm at [when] with the given [id].
  Future<void> scheduleAlarm({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      NotificationDetails(android: _alarmAndroid, iOS: const DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'alarm:$id',
    );
  }

  /// Schedule a repeating alarm on a given weekday/time.
  Future<void> scheduleWeekly({
    required int id,
    required int weekday, // DateTime.monday..sunday
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextWeekdayTime(weekday, hour, minute),
      NotificationDetails(android: _alarmAndroid, iOS: const DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'alarm:$id',
    );
  }

  Future<void> showBriefing(String title, String body) async {
    await _plugin.show(
      99000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.generalChannelId,
          AppConstants.generalChannelName,
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();

  tz.TZDateTime _nextWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var d = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (d.weekday != weekday || d.isBefore(now)) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }
}

/// Lightweight TimeOfDay-ish helper used by alarm scheduling code.
@immutable
class Hm {
  final int hour;
  final int minute;
  const Hm(this.hour, this.minute);
}
