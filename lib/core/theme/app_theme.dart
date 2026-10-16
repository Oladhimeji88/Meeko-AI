import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/models/app_settings.dart';

/// Builds Material themes derived from the user's [AppSettings].
/// Uses a pixel-friendly monospace display font (Vт323 / PressStart-ish via
/// Google Fonts "VT323") for the retro aesthetic while keeping body text legible.
class AppTheme {
  AppTheme._();

  static ThemeData fromSettings(AppSettings s) {
    final brightness = s.darkMode ? Brightness.dark : Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: s.accent,
      brightness: brightness,
    ).copyWith(
      surface: s.background,
      primary: s.body,
      secondary: s.accent,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: s.background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.vt323TextTheme(base.textTheme).apply(
        bodyColor: s.text,
        displayColor: s.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: s.text,
        titleTextStyle: GoogleFonts.vt323(fontSize: 28, color: s.text),
      ),
      cardTheme: CardThemeData(
        color: Color.alphaBlend(Colors.white.withValues(alpha: 0.06), s.background),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            Color.alphaBlend(Colors.white.withValues(alpha: 0.04), s.background),
        indicatorColor: s.accent.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.vt323(fontSize: 16, color: s.text),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: s.accent,
        foregroundColor: Colors.black,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? s.accent : null,
        ),
      ),
    );
  }

  /// A handful of preset background swatches surfaced in Settings.
  static const List<int> presetBackgrounds = [
    0xFF12101F, // deep purple-black
    0xFF000000, // black
    0xFFFFFFFF, // white
    0xFF2D132C, // plum
    0xFF0B3D91, // blue
    0xFF1B4332, // green
    0xFFE76F00, // orange
  ];
}
