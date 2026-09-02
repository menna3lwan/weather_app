class Weather {
  const Weather({
    required this.city,
    required this.country,
    required this.condition,
    required this.temperature,
    required this.high,
    required this.low,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.updatedAt,
    required this.icon,
    required this.forecast,
  });
  final String city;
  final String country;
  final String condition;
  final int temperature;
  final int high;
  final int low;
  final int humidity;
  final int windSpeed;
  final int pressure;
  final int visibility;
  final DateTime updatedAt;
  final WeatherIcon icon;
  final List<ForecastDay> forecast;
}

enum WeatherIcon { sunny, partlyCloudy, rainy, stormy }

class ForecastDay {
  const ForecastDay({
    required this.day,
    required this.condition,
    required this.high,
    required this.low,
    required this.icon,
  });
  final String day;
  final String condition;
  final int high;
  final int low;
  final WeatherIcon icon;
}
