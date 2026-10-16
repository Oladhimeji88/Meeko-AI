import 'package:flutter/material.dart';

import '../../core/enums.dart';

/// Immutable snapshot of all user-customizable settings.
/// Serialized to JSON and stored in Hive (no code-gen required).
@immutable
class AppSettings {
  final bool use24HourFormat;
  final bool darkMode;

  // Theme colors (stored as ARGB int)
  final int backgroundColor;
  final int bodyColor;
  final int eyeColor;
  final int textColor;
  final int accentColor;

  // Weather
  final bool weatherEnabled;
  final String? cityName; // null => use device location

  // AI
  final AiProviderType aiProvider;
  final AiPersonality aiPersonality;
  final bool voiceEnabled;
  final bool wakePhraseEnabled; // "Hey PixelBuddy"

  // Alarm defaults
  final int snoozeMinutes;

  // Premium (architecture only — no payment gateway yet)
  final bool isPremium;

  // Pixel pet progression
  final int petXp;
  final int petLevel;

  const AppSettings({
    this.use24HourFormat = false,
    this.darkMode = true,
    this.backgroundColor = 0xFF12101F,
    this.bodyColor = 0xFF6C5CE7,
    this.eyeColor = 0xFF00E5FF,
    this.textColor = 0xFFFFFFFF,
    this.accentColor = 0xFFFFB142,
    this.weatherEnabled = true,
    this.cityName,
    this.aiProvider = AiProviderType.local,
    this.aiPersonality = AiPersonality.friendly,
    this.voiceEnabled = true,
    this.wakePhraseEnabled = false,
    this.snoozeMinutes = 5,
    this.isPremium = false,
    this.petXp = 0,
    this.petLevel = 1,
  });

  // Convenience color getters
  Color get background => Color(backgroundColor);
  Color get body => Color(bodyColor);
  Color get eye => Color(eyeColor);
  Color get text => Color(textColor);
  Color get accent => Color(accentColor);

  AppSettings copyWith({
    bool? use24HourFormat,
    bool? darkMode,
    int? backgroundColor,
    int? bodyColor,
    int? eyeColor,
    int? textColor,
    int? accentColor,
    bool? weatherEnabled,
    String? cityName,
    bool clearCity = false,
    AiProviderType? aiProvider,
    AiPersonality? aiPersonality,
    bool? voiceEnabled,
    bool? wakePhraseEnabled,
    int? snoozeMinutes,
    bool? isPremium,
    int? petXp,
    int? petLevel,
  }) {
    return AppSettings(
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      darkMode: darkMode ?? this.darkMode,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      bodyColor: bodyColor ?? this.bodyColor,
      eyeColor: eyeColor ?? this.eyeColor,
      textColor: textColor ?? this.textColor,
      accentColor: accentColor ?? this.accentColor,
      weatherEnabled: weatherEnabled ?? this.weatherEnabled,
      cityName: clearCity ? null : (cityName ?? this.cityName),
      aiProvider: aiProvider ?? this.aiProvider,
      aiPersonality: aiPersonality ?? this.aiPersonality,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      wakePhraseEnabled: wakePhraseEnabled ?? this.wakePhraseEnabled,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      isPremium: isPremium ?? this.isPremium,
      petXp: petXp ?? this.petXp,
      petLevel: petLevel ?? this.petLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'use24HourFormat': use24HourFormat,
        'darkMode': darkMode,
        'backgroundColor': backgroundColor,
        'bodyColor': bodyColor,
        'eyeColor': eyeColor,
        'textColor': textColor,
        'accentColor': accentColor,
        'weatherEnabled': weatherEnabled,
        'cityName': cityName,
        'aiProvider': aiProvider.name,
        'aiPersonality': aiPersonality.name,
        'voiceEnabled': voiceEnabled,
        'wakePhraseEnabled': wakePhraseEnabled,
        'snoozeMinutes': snoozeMinutes,
        'isPremium': isPremium,
        'petXp': petXp,
        'petLevel': petLevel,
      };

  factory AppSettings.fromJson(Map<dynamic, dynamic> json) {
    T pick<T>(String key, T fallback) =>
        json[key] is T ? json[key] as T : fallback;
    return AppSettings(
      use24HourFormat: pick('use24HourFormat', false),
      darkMode: pick('darkMode', true),
      backgroundColor: pick('backgroundColor', 0xFF12101F),
      bodyColor: pick('bodyColor', 0xFF6C5CE7),
      eyeColor: pick('eyeColor', 0xFF00E5FF),
      textColor: pick('textColor', 0xFFFFFFFF),
      accentColor: pick('accentColor', 0xFFFFB142),
      weatherEnabled: pick('weatherEnabled', true),
      cityName: json['cityName'] as String?,
      aiProvider: AiProviderType.values.firstWhere(
        (e) => e.name == json['aiProvider'],
        orElse: () => AiProviderType.local,
      ),
      aiPersonality: AiPersonality.values.firstWhere(
        (e) => e.name == json['aiPersonality'],
        orElse: () => AiPersonality.friendly,
      ),
      voiceEnabled: pick('voiceEnabled', true),
      wakePhraseEnabled: pick('wakePhraseEnabled', false),
      snoozeMinutes: pick('snoozeMinutes', 5),
      isPremium: pick('isPremium', false),
      petXp: pick('petXp', 0),
      petLevel: pick('petLevel', 1),
    );
  }
}
