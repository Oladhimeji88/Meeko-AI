import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../services/location_service.dart';
import '../../../services/storage_service.dart';
import 'weather_model.dart';

/// Fetches weather from OpenWeatherMap. Falls back to demo data when no API key
/// is set so the app is fully functional out-of-the-box.
class WeatherRepository {
  WeatherRepository(this._storage, this._location, {Dio? dio})
      : _dio = dio ?? Dio();

  final StorageService _storage;
  final LocationService _location;
  final Dio _dio;

  Future<WeatherData> fetch({String? cityName}) async {
    final key = await _storage.readSecret(AppConstants.kWeatherKey);
    if (key == null || key.isEmpty) return WeatherData.demo();

    final params = <String, dynamic>{'appid': key, 'units': 'metric'};
    if (cityName != null && cityName.isNotEmpty) {
      params['q'] = cityName;
    } else {
      final pos = await _location.current();
      if (pos == null) return WeatherData.demo();
      params['lat'] = pos.latitude;
      params['lon'] = pos.longitude;
    }

    try {
      final res =
          await _dio.get(AppConstants.openWeatherBase, queryParameters: params);
      return WeatherData.fromOpenWeather(res.data as Map<String, dynamic>);
    } on DioException {
      return WeatherData.demo();
    }
  }
}
