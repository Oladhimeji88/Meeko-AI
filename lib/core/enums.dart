/// Shared enums used across PixelBuddy Clock.
library;

/// The emotional/animation state of the pixel character.
enum BuddyMood {
  happy,
  neutral,
  sleepy,
  surprised, // alarm ringing
  talking, // AI speaking
  cheering, // stopwatch start / celebration
  worried, // storm weather
  cool, // sunny — sunglasses
  rainy, // rain — umbrella
}

/// Normalized weather condition independent of the API provider.
enum WeatherCondition {
  clear,
  clouds,
  rain,
  drizzle,
  thunderstorm,
  snow,
  mist,
  unknown,
}

/// Supported AI back-ends. Each maps to a concrete [AiProvider].
enum AiProviderType { openai, claude, gemini, local }

/// AI personality presets that shape the system prompt + voice.
enum AiPersonality { friendly, motivator, chill, retroGamer }

/// How an alarm repeats.
enum AlarmRepeat { once, daily, weekdays, weekends, custom }

extension AiPersonalityX on AiPersonality {
  String get label => switch (this) {
        AiPersonality.friendly => 'Friendly',
        AiPersonality.motivator => 'Motivator',
        AiPersonality.chill => 'Chill',
        AiPersonality.retroGamer => 'Retro Gamer',
      };

  /// System prompt fragment that defines tone for the LLM.
  String get systemPrompt => switch (this) {
        AiPersonality.friendly =>
          'You are PixelBuddy, a warm, friendly pixel-art clock companion. '
              'Be kind, concise, and helpful.',
        AiPersonality.motivator =>
          'You are PixelBuddy, an encouraging productivity motivator. '
              'Pump the user up, keep them focused, and celebrate small wins.',
        AiPersonality.chill =>
          'You are PixelBuddy, a relaxed, chill companion. '
              'Keep things calm, easygoing, and low-pressure.',
        AiPersonality.retroGamer =>
          'You are PixelBuddy, a retro-game-inspired pixel companion. '
              'Sprinkle in playful 8-bit / arcade references. Keep it fun and short.',
      };
}

extension WeatherConditionX on WeatherCondition {
  BuddyMood get buddyMood => switch (this) {
        WeatherCondition.clear => BuddyMood.cool,
        WeatherCondition.clouds || WeatherCondition.mist => BuddyMood.neutral,
        WeatherCondition.rain || WeatherCondition.drizzle => BuddyMood.rainy,
        WeatherCondition.thunderstorm => BuddyMood.worried,
        WeatherCondition.snow => BuddyMood.happy,
        WeatherCondition.unknown => BuddyMood.neutral,
      };

  String get emoji => switch (this) {
        WeatherCondition.clear => '☀️',
        WeatherCondition.clouds => '☁️',
        WeatherCondition.rain => '🌧️',
        WeatherCondition.drizzle => '🌦️',
        WeatherCondition.thunderstorm => '⛈️',
        WeatherCondition.snow => '❄️',
        WeatherCondition.mist => '🌫️',
        WeatherCondition.unknown => '🌡️',
      };

  static WeatherCondition fromOpenWeather(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return WeatherCondition.clear;
      case 'clouds':
        return WeatherCondition.clouds;
      case 'rain':
        return WeatherCondition.rain;
      case 'drizzle':
        return WeatherCondition.drizzle;
      case 'thunderstorm':
        return WeatherCondition.thunderstorm;
      case 'snow':
        return WeatherCondition.snow;
      case 'mist':
      case 'fog':
      case 'haze':
        return WeatherCondition.mist;
      default:
        return WeatherCondition.unknown;
    }
  }
}
