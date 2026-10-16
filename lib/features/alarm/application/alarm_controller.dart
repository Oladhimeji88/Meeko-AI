import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../services/notification_service.dart';
import '../data/alarm_model.dart';
import '../data/alarm_repository.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>(
  (ref) => AlarmRepository(ref.read(storageServiceProvider)),
);

/// Owns the list of alarms and keeps the OS notification schedule in sync.
class AlarmController extends StateNotifier<List<AlarmModel>> {
  AlarmController(this._repo, this._notifications) : super(_repo.all());

  final AlarmRepository _repo;
  final NotificationService _notifications;
  static const _uuid = Uuid();

  Future<void> _refresh() async => state = _repo.all();

  Future<AlarmModel> create({
    required int hour,
    required int minute,
  }) async {
    final alarm = AlarmModel(id: _uuid.v4(), hour: hour, minute: minute);
    await _repo.save(alarm);
    await _reschedule(alarm);
    await _refresh();
    return alarm;
  }

  Future<void> upsert(AlarmModel alarm) async {
    await _repo.save(alarm);
    await _reschedule(alarm);
    await _refresh();
  }

  Future<void> toggle(AlarmModel alarm, bool enabled) async {
    await upsert(alarm.copyWith(enabled: enabled));
  }

  Future<void> delete(AlarmModel alarm) async {
    await _notifications.cancel(alarm.notificationId);
    await _repo.delete(alarm.id);
    await _refresh();
  }

  /// Compute and return the next time any alarm will fire (for widgets/lock).
  DateTime? nextTrigger() {
    final now = DateTime.now();
    DateTime? best;
    for (final a in state.where((a) => a.enabled)) {
      final candidate = _nextFor(a, now);
      if (candidate != null && (best == null || candidate.isBefore(best))) {
        best = candidate;
      }
    }
    return best;
  }

  DateTime? _nextFor(AlarmModel a, DateTime now) {
    if (a.activeWeekdays.isEmpty) {
      var d = DateTime(now.year, now.month, now.day, a.hour, a.minute);
      if (!d.isAfter(now)) d = d.add(const Duration(days: 1));
      return d;
    }
    for (var i = 0; i < 8; i++) {
      final day = now.add(Duration(days: i));
      if (a.activeWeekdays.contains(day.weekday)) {
        final d = DateTime(day.year, day.month, day.day, a.hour, a.minute);
        if (d.isAfter(now)) return d;
      }
    }
    return null;
  }

  Future<void> _reschedule(AlarmModel a) async {
    await _notifications.cancel(a.notificationId);
    if (!a.enabled) return;

    if (a.activeWeekdays.isEmpty) {
      final when = _nextFor(a, DateTime.now());
      if (when != null) {
        await _notifications.scheduleAlarm(
          id: a.notificationId,
          when: when,
          title: '⏰ ${a.label}',
          body: 'PixelBuddy says it\'s time!',
        );
      }
    } else {
      // One weekly schedule per active weekday (offset id to stay unique).
      for (final wd in a.activeWeekdays) {
        await _notifications.scheduleWeekly(
          id: a.notificationId + wd,
          weekday: wd,
          hour: a.hour,
          minute: a.minute,
          title: '⏰ ${a.label}',
          body: 'PixelBuddy says it\'s time!',
        );
      }
    }
  }
}

final alarmControllerProvider =
    StateNotifierProvider<AlarmController, List<AlarmModel>>(
  (ref) => AlarmController(
    ref.read(alarmRepositoryProvider),
    ref.read(notificationServiceProvider),
  ),
);

/// The next upcoming alarm time, recomputed whenever alarms change.
final nextAlarmProvider = Provider<DateTime?>((ref) {
  ref.watch(alarmControllerProvider);
  return ref.read(alarmControllerProvider.notifier).nextTrigger();
});
