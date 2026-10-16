import 'package:flutter/material.dart';

import '../../../../core/enums.dart';

/// Paints the PixelBuddy character on a 32x32 pixel grid.
///
/// Everything snaps to grid cells so the result is crisp pixel art at any size.
/// Animation-driven inputs ([blink], [eyeShift], [mouthOpen], [bob]) come from
/// the parent widget's controllers.
class PixelBuddyPainter extends CustomPainter {
  final Color body;
  final Color eye;
  final Color accent;
  final BuddyMood mood;

  /// 1.0 = eyes fully open, 0.0 = closed.
  final double blink;

  /// Eye pupil offset in cells (-1..1 each axis).
  final Offset eyeShift;

  /// 0..1 mouth openness for talking animation.
  final double mouthOpen;

  /// Vertical bob in cells for the breathing/idle motion.
  final double bob;

  static const int grid = 32;

  PixelBuddyPainter({
    required this.body,
    required this.eye,
    required this.accent,
    required this.mood,
    required this.blink,
    required this.eyeShift,
    required this.mouthOpen,
    required this.bob,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / grid;
    final p = Paint()..isAntiAlias = false;

    void px(int x, int y, Color c, {int w = 1, int h = 1}) {
      p.color = c;
      canvas.drawRect(
        Rect.fromLTWH(x * cell, (y + bob) * cell, w * cell, h * cell),
        p,
      );
    }

    final shade = Color.lerp(body, Colors.black, 0.25)!;
    final hi = Color.lerp(body, Colors.white, 0.25)!;

    // ---- Body / head block (rounded by trimming corners) ----
    // Main 22x20 block centered, with 2-cell corner notches for roundness.
    const left = 5, top = 5, w = 22, h = 21;
    px(left + 2, top, body, w: w - 4, h: 2); // top edge
    px(left, top + 2, body, w: w, h: h - 4); // middle
    px(left + 2, top + h - 2, body, w: w - 4, h: 2); // bottom edge
    px(left + 1, top + 1, body, w: 1, h: 1);
    px(left + w - 2, top + 1, body, w: 1, h: 1);
    px(left + 1, top + h - 2, body, w: 1, h: 1);
    px(left + w - 2, top + h - 2, body, w: 1, h: 1);

    // Shading: bottom + right rim.
    px(left + 2, top + h - 2, shade, w: w - 4, h: 2);
    px(left + w - 2, top + 2, shade, w: 2, h: h - 4);
    // Highlight: top-left rim.
    px(left + 2, top, hi, w: w - 6, h: 1);
    px(left, top + 2, hi, w: 1, h: h - 8);

    // Little antenna for the gadget look.
    px(left + w ~/ 2, top - 3, shade, w: 1, h: 3);
    px(left + w ~/ 2, top - 4, accent, w: 1, h: 1);

    _drawFace(px, left, top, w, h);
  }

  void _drawFace(
    void Function(int, int, Color, {int w, int h}) px,
    int left,
    int top,
    int w,
    int h,
  ) {
    final cx = left + w ~/ 2;
    final eyeY = top + 8;
    final lx = cx - 5; // left eye x
    final rx = cx + 2; // right eye x
    const ew = 3; // eye block width
    final dx = eyeShift.dx.clamp(-1, 1).round();
    final dy = eyeShift.dy.clamp(-1, 1).round();

    final sleepy = mood == BuddyMood.sleepy;
    final surprised = mood == BuddyMood.surprised;
    final happy = mood == BuddyMood.happy || mood == BuddyMood.cheering;

    // Open height of eyes scaled by blink (and mood).
    final baseH = surprised ? 6 : (happy ? 3 : 4);
    var eh = (baseH * blink).round();
    if (sleepy) eh = eh.clamp(0, 2);
    if (eh < 1) {
      // Closed → draw a thin lid line.
      px(lx, eyeY + 2, Color.lerp(eye, Colors.black, 0.4)!, w: ew, h: 1);
      px(rx, eyeY + 2, Color.lerp(eye, Colors.black, 0.4)!, w: ew, h: 1);
    } else {
      final eyeWhite = Color.lerp(eye, Colors.white, 0.7)!;
      // Eye sockets (white-ish backing).
      px(lx, eyeY, eyeWhite, w: ew, h: eh);
      px(rx, eyeY, eyeWhite, w: ew, h: eh);
      // Pupils track eyeShift.
      final pupY = (eyeY + (eh ~/ 2) - 1 + dy).clamp(eyeY, eyeY + eh - 1);
      px((lx + 1 + dx).clamp(lx, lx + ew - 1), pupY, eye, w: 1, h: 1);
      px((rx + 1 + dx).clamp(rx, rx + ew - 1), pupY, eye, w: 1, h: 1);
      // Sparkle highlight when happy.
      if (happy) {
        px(lx, eyeY, Colors.white, w: 1, h: 1);
        px(rx, eyeY, Colors.white, w: 1, h: 1);
      }
    }

    // ---- Mood accessories ----
    switch (mood) {
      case BuddyMood.cool:
        // Sunglasses bar across both eyes.
        final g = Colors.black;
        px(lx - 1, eyeY - 1, g, w: ew + 2, h: eh + 2);
        px(rx - 1, eyeY - 1, g, w: ew + 2, h: eh + 2);
        px(lx + ew + 1, eyeY, g, w: rx - (lx + ew) - 1, h: 1); // bridge
        break;
      case BuddyMood.rainy:
        // Umbrella above the head.
        final u = accent;
        px(left + 2, top - 6, u, w: w - 4, h: 1);
        px(left + 1, top - 5, u, w: w - 2, h: 1);
        px(cx, top - 5, Color.lerp(accent, Colors.black, 0.3)!, w: 1, h: 5);
        break;
      case BuddyMood.worried:
        // Slanted worried brows.
        final brow = Color.lerp(body, Colors.black, 0.5)!;
        px(lx, eyeY - 2, brow, w: 1, h: 1);
        px(lx + 1, eyeY - 1, brow, w: 2, h: 1);
        px(rx + 1, eyeY - 2, brow, w: 1, h: 1);
        px(rx, eyeY - 1, brow, w: 2, h: 1);
        break;
      default:
        break;
    }

    // ---- Mouth ----
    final mouthY = top + h - 6;
    final mouthColor = Color.lerp(body, Colors.black, 0.55)!;
    if (mood == BuddyMood.talking) {
      final mh = (1 + mouthOpen * 3).round();
      px(cx - 2, mouthY, mouthColor, w: 4, h: mh);
      px(cx - 1, mouthY + 1, accent, w: 2, h: (mh - 2).clamp(0, mh)); // tongue
    } else if (happy) {
      // Smile: little upward arc.
      px(cx - 3, mouthY, mouthColor, w: 1, h: 1);
      px(cx - 2, mouthY + 1, mouthColor, w: 4, h: 1);
      px(cx + 2, mouthY, mouthColor, w: 1, h: 1);
    } else if (mood == BuddyMood.surprised) {
      px(cx - 1, mouthY, mouthColor, w: 3, h: 3); // open "o"
    } else if (mood == BuddyMood.sleepy) {
      px(cx - 1, mouthY + 1, mouthColor, w: 2, h: 1); // tiny line
    } else {
      px(cx - 2, mouthY + 1, mouthColor, w: 4, h: 1); // neutral line
    }

    // Rosy cheeks when happy/cheering.
    if (happy) {
      final blush = accent.withValues(alpha: 0.6);
      px(lx - 1, mouthY - 2, blush, w: 1, h: 1);
      px(rx + ew, mouthY - 2, blush, w: 1, h: 1);
    }
  }

  @override
  bool shouldRepaint(PixelBuddyPainter old) =>
      old.blink != blink ||
      old.eyeShift != eyeShift ||
      old.mouthOpen != mouthOpen ||
      old.bob != bob ||
      old.mood != mood ||
      old.body != body ||
      old.eye != eye ||
      old.accent != accent;
}
