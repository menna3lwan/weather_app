import 'package:flutter/foundation.dart';
import 'package:weather_app/data/weather_repository.dart';
import 'package:weather_app/domain/weather.dart';

enum WeatherStatus { empty, loading, success, error }

class WeatherController extends ChangeNotifier {
  WeatherController(this._repository);
  final WeatherRepository _repository;
  WeatherStatus status = WeatherStatus.empty;
  Weather? weather;
  String? errorMessage;

  Future<void> search(String city) async {
    status = WeatherStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      weather = await _repository.fetchWeather(city);
      status = WeatherStatus.success;
    } on WeatherException catch (error) {
      weather = null;
      errorMessage = error.message;
      status = WeatherStatus.error;
    }
    notifyListeners();
  }
}
