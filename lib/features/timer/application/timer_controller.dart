import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// One countdown timer instance.
class CountdownTimer {
  final String id;
  final String label;
  final Duration total;
  final Duration remaining;
  final bool running;

  const CountdownTimer({
    required this.id,
    required this.label,
    required this.total,
    required this.remaining,
    required this.running,
  });

  bool get finished => remaining <= Duration.zero;
  double get progress =>
      total.inSeconds == 0 ? 0 : 1 - remaining.inSeconds / total.inSeconds;

  CountdownTimer copyWith({Duration? remaining, bool? running}) =>
      CountdownTimer(
        id: id,
        label: label,
        total: total,
        remaining: remaining ?? this.remaining,
        running: running ?? this.running,
      );
}

/// Manages any number of concurrent countdown timers with a single 1s ticker.
class TimerController extends StateNotifier<List<CountdownTimer>> {
  TimerController() : super(const []);

  static const _uuid = Uuid();
  Timer? _ticker;

  /// Fired when a timer reaches zero (wired to notifications/sound by the UI).
  void Function(CountdownTimer)? onFinished;

  void add(Duration d, {String label = 'Timer'}) {
    state = [
      ...state,
      CountdownTimer(
        id: _uuid.v4(),
        label: label,
        total: d,
        remaining: d,
        running: true,
      ),
    ];
    _ensureTicker();
  }

  void pause(String id) => _mutate(id, (t) => t.copyWith(running: false));
  void resume(String id) {
    _mutate(id, (t) => t.copyWith(running: true));
    _ensureTicker();
  }

  void reset(String id) =>
      _mutate(id, (t) => t.copyWith(remaining: t.total, running: false));

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
    if (state.isEmpty) _stopTicker();
  }

  void _mutate(String id, CountdownTimer Function(CountdownTimer) f) {
    state = [for (final t in state) if (t.id == id) f(t) else t];
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    var anyRunning = false;
    state = [
      for (final t in state)
        if (t.running && !t.finished)
          () {
            anyRunning = true;
            final next = t.copyWith(
                remaining: t.remaining - const Duration(seconds: 1));
            if (next.finished) {
              onFinished?.call(next);
              return next.copyWith(running: false);
            }
            return next;
          }()
        else
          t,
    ];
    if (!anyRunning) _stopTicker();
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}

final timerControllerProvider =
    StateNotifierProvider<TimerController, List<CountdownTimer>>(
  (ref) => TimerController(),
);
