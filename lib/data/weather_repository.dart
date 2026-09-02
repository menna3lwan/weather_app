import 'package:weather_app/domain/weather.dart';

class WeatherException implements Exception {
  const WeatherException(this.message);
  final String message;
}

class WeatherRepository {
  Future<Weather> fetchWeather(String city) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final normalizedCity = city.trim().toLowerCase();
    if (normalizedCity.isEmpty) {
      throw const WeatherException('Enter a city name to search.');
    }
    if (normalizedCity == 'offline') {
      throw const WeatherException(
        'No internet connection. Check your network and try again.',
      );
    }
    if (normalizedCity == 'error') {
      throw const WeatherException('Weather service is unavailable right now.');
    }
    final weather = _cities[normalizedCity];
    if (weather == null) {
      throw const WeatherException(
        'We could not find that city. Check the spelling and try again.',
      );
    }
    return weather;
  }

  static final Map<String, Weather> _cities = {
    'alexandria': _weather(
      'Alexandria',
      'Egypt',
      'Light rain',
      17,
      24,
      16,
      68,
      14,
      1012,
      8,
      WeatherIcon.rainy,
    ),
    'cairo': _weather(
      'Cairo',
      'Egypt',
      'Partly cloudy',
      23,
      28,
      18,
      42,
      11,
      1015,
      10,
      WeatherIcon.partlyCloudy,
    ),
    'london': _weather(
      'London',
      'United Kingdom',
      'Cloudy',
      12,
      15,
      8,
      79,
      18,
      1008,
      7,
      WeatherIcon.partlyCloudy,
    ),
  };

  static Weather _weather(
    String city,
    String country,
    String condition,
    int temperature,
    int high,
    int low,
    int humidity,
    int windSpeed,
    int pressure,
    int visibility,
    WeatherIcon icon,
  ) => Weather(
    city: city,
    country: country,
    condition: condition,
    temperature: temperature,
    high: high,
    low: low,
    humidity: humidity,
    windSpeed: windSpeed,
    pressure: pressure,
    visibility: visibility,
    updatedAt: DateTime(2026, 9, 2, 9, 30),
    icon: icon,
    forecast: const [
      ForecastDay(
        day: 'Today',
        condition: 'Light rain',
        high: 24,
        low: 16,
        icon: WeatherIcon.rainy,
      ),
      ForecastDay(
        day: 'Tomorrow',
        condition: 'Cloudy',
        high: 25,
        low: 17,
        icon: WeatherIcon.partlyCloudy,
      ),
      ForecastDay(
        day: 'Fri',
        condition: 'Sunny',
        high: 27,
        low: 18,
        icon: WeatherIcon.sunny,
      ),
      ForecastDay(
        day: 'Sat',
        condition: 'Sunny',
        high: 26,
        low: 17,
        icon: WeatherIcon.sunny,
      ),
      ForecastDay(
        day: 'Sun',
        condition: 'Stormy',
        high: 22,
        low: 15,
        icon: WeatherIcon.stormy,
      ),
    ],
  );
}
