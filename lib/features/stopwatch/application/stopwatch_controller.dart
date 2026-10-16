import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class StopwatchState {
  final Duration elapsed;
  final bool running;
  final List<Duration> laps;

  const StopwatchState({
    this.elapsed = Duration.zero,
    this.running = false,
    this.laps = const [],
  });

  StopwatchState copyWith(
          {Duration? elapsed, bool? running, List<Duration>? laps}) =>
      StopwatchState(
        elapsed: elapsed ?? this.elapsed,
        running: running ?? this.running,
        laps: laps ?? this.laps,
      );
}

class StopwatchController extends StateNotifier<StopwatchState> {
  StopwatchController() : super(const StopwatchState());

  final Stopwatch _sw = Stopwatch();
  Timer? _ticker;

  /// Fires once when the user starts the stopwatch (buddy cheers).
  void Function()? onStart;

  void start() {
    if (state.running) return;
    _sw.start();
    onStart?.call();
    _ticker = Timer.periodic(const Duration(milliseconds: 30),
        (_) => state = state.copyWith(elapsed: _sw.elapsed));
    state = state.copyWith(running: true);
  }

  void pause() {
    _sw.stop();
    _ticker?.cancel();
    state = state.copyWith(running: false, elapsed: _sw.elapsed);
  }

  void lap() {
    if (!state.running) return;
    state = state.copyWith(laps: [_sw.elapsed, ...state.laps]);
  }

  void reset() {
    _sw
      ..stop()
      ..reset();
    _ticker?.cancel();
    state = const StopwatchState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final stopwatchControllerProvider =
    StateNotifierProvider<StopwatchController, StopwatchState>(
  (ref) => StopwatchController(),
);
