/// App-wide constants and storage keys.
class AppConstants {
  AppConstants._();

  static const String appName = 'PixelBuddy Clock';

  // Hive box names
  static const String settingsBox = 'settings_box';
  static const String alarmsBox = 'alarms_box';
  static const String aiBox = 'ai_box';

  // Settings keys (stored inside settingsBox)
  static const String kSettings = 'app_settings';

  // Secure storage keys (API keys live here, never in Hive)
  static const String kOpenAiKey = 'openai_api_key';
  static const String kClaudeKey = 'claude_api_key';
  static const String kGeminiKey = 'gemini_api_key';
  static const String kWeatherKey = 'weather_api_key';

  // Weather
  static const String openWeatherBase =
      'https://api.openweathermap.org/data/2.5/weather';

  // Notifications
  static const String alarmChannelId = 'pixelbuddy_alarms';
  static const String alarmChannelName = 'Alarms';
  static const String generalChannelId = 'pixelbuddy_general';
  static const String generalChannelName = 'Daily Briefing & Reminders';
}
