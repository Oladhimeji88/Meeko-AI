// Basic smoke test for PixelBuddy Clock.
//
// The full app needs initialized platform plugins (Hive, notifications), so
// here we verify the pixel character widget renders standalone.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelbuddy_clock/core/enums.dart';
import 'package:pixelbuddy_clock/features/clock/presentation/widgets/pixel_buddy.dart';

void main() {
  testWidgets('PixelBuddy renders without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PixelBuddy(
              mood: BuddyMood.happy,
              body: Color(0xFF6C5CE7),
              eye: Color(0xFF00E5FF),
              accent: Color(0xFFFFB142),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(PixelBuddy), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
  });
}
