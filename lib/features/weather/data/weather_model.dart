import '../../../core/enums.dart';

/// Normalized weather snapshot shown by the clock + AI.
class WeatherData {
  final double temperatureC;
  final WeatherCondition condition;
  final String description;
  final int humidity; // %
  final double windSpeed; // m/s
  final String location;

  const WeatherData({
    required this.temperatureC,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.location,
  });

  double get temperatureF => temperatureC * 9 / 5 + 32;

  factory WeatherData.fromOpenWeather(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? const {};
    return WeatherData(
      temperatureC: (main['temp'] as num).toDouble(),
      condition: WeatherConditionX.fromOpenWeather(weather['main'] as String),
      description: (weather['description'] as String?) ?? '',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      location: (json['name'] as String?) ?? 'Unknown',
    );
  }

  /// Offline/demo data used when no API key is configured.
  factory WeatherData.demo() => const WeatherData(
        temperatureC: 22,
        condition: WeatherCondition.clear,
        description: 'clear sky (demo)',
        humidity: 48,
        windSpeed: 3.2,
        location: 'Demo City',
      );
}
