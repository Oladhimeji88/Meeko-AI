import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../services/location_service.dart';
import '../../settings/application/settings_controller.dart';
import '../data/weather_model.dart';
import '../data/weather_repository.dart';

final locationServiceProvider = Provider((ref) => LocationService());

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(
    ref.read(storageServiceProvider),
    ref.read(locationServiceProvider),
  );
});

/// Auto-refreshing weather. Re-fetches whenever the configured city changes,
/// and is invalidated on a timer by the app shell.
final weatherProvider = FutureProvider<WeatherData>((ref) async {
  final settings = ref.watch(settingsControllerProvider);
  if (!settings.weatherEnabled) return WeatherData.demo();
  final repo = ref.read(weatherRepositoryProvider);
  return repo.fetch(cityName: settings.cityName);
});
