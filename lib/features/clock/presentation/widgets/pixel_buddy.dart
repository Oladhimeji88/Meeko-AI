import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/enums.dart';
import 'pixel_buddy_painter.dart';

/// Animated PixelBuddy character.
///
/// Owns the blink timer, idle breathing bob, eye-tracking drift, and the
/// talking mouth animation. The [mood] drives accessories and expression.
class PixelBuddy extends StatefulWidget {
  final BuddyMood mood;
  final Color body;
  final Color eye;
  final Color accent;
  final double size;

  /// When true, the mouth animates as if speaking (overrides idle mouth).
  final bool speaking;

  const PixelBuddy({
    super.key,
    required this.mood,
    required this.body,
    required this.eye,
    required this.accent,
    this.size = 240,
    this.speaking = false,
  });

  @override
  State<PixelBuddy> createState() => _PixelBuddyState();
}

class _PixelBuddyState extends State<PixelBuddy>
    with TickerProviderStateMixin {
  late final AnimationController _bob;
  late final AnimationController _mouth;
  late final AnimationController _blinkCtrl;
  Timer? _blinkTimer;
  Timer? _eyeTimer;
  Offset _eyeShift = Offset.zero;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _mouth = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      value: 1,
    );

    _scheduleBlink();
    _scheduleEyeDrift();
    _syncSpeaking();
  }

  @override
  void didUpdateWidget(covariant PixelBuddy old) {
    super.didUpdateWidget(old);
    if (old.speaking != widget.speaking) _syncSpeaking();
  }

  void _syncSpeaking() {
    if (widget.speaking || widget.mood == BuddyMood.talking) {
      if (!_mouth.isAnimating) _mouth.repeat(reverse: true);
    } else {
      _mouth.stop();
      _mouth.value = 0;
    }
  }

  void _scheduleBlink() {
    // Sleepy buddies blink slower/heavier.
    final base = widget.mood == BuddyMood.sleepy ? 1200 : 2600;
    _blinkTimer = Timer(Duration(milliseconds: base + _rng.nextInt(2200)), () async {
      if (!mounted) return;
      await _blinkCtrl.reverse();
      await _blinkCtrl.forward();
      _scheduleBlink();
    });
  }

  void _scheduleEyeDrift() {
    _eyeTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!mounted) return;
      setState(() {
        _eyeShift = Offset(
          (_rng.nextInt(3) - 1).toDouble(),
          (_rng.nextInt(3) - 1).toDouble(),
        );
      });
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _eyeTimer?.cancel();
    _bob.dispose();
    _mouth.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final talking = widget.speaking || widget.mood == BuddyMood.talking;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bob, _mouth, _blinkCtrl]),
        builder: (context, _) {
          // Cheering buddies bounce more.
          final amp = widget.mood == BuddyMood.cheering ? 1.4 : 0.6;
          final bob = (math.sin(_bob.value * math.pi) - 0.5) * amp;
          return CustomPaint(
            painter: PixelBuddyPainter(
              body: widget.body,
              eye: widget.eye,
              accent: widget.accent,
              mood: talking ? BuddyMood.talking : widget.mood,
              blink: _blinkCtrl.value,
              eyeShift: _eyeShift,
              mouthOpen: _mouth.value,
              bob: bob,
            ),
          );
        },
      ),
    );
  }
}
