import 'package:flutter_test/flutter_test.dart';
import 'package:sample/services/weather_service.dart';

void main() {
  group('WeatherData', () {
    test('should parse weather data from JSON', () {
      final json = {
        'name': 'Talisay City',
        'sys': {'country': 'PH', 'sunrise': 1234567890, 'sunset': 1234567890},
        'main': {
          'temp': 28.5,
          'feels_like': 30.0,
          'humidity': 75,
          'pressure': 1013,
          'temp_max': 32.0,
        },
        'wind': {'speed': 5.5},
        'weather': [
          {'description': 'clear sky', 'icon': '01d'}
        ],
      };

      final weatherData = WeatherData.fromJson(json);

      expect(weatherData.city, equals('Talisay City'));
      expect(weatherData.country, equals('PH'));
      expect(weatherData.temperature, equals(28.5));
      expect(weatherData.humidity, equals(75));
    });

    test('should handle missing data gracefully', () {
      final json = {
        'name': 'Test City',
        'sys': {'sunrise': 1234567890, 'sunset': 1234567890},
        'main': {},
        'wind': {},
        'weather': [{'description': 'unknown', 'icon': '01d'}],
      };

      final weatherData = WeatherData.fromJson(json);

      expect(weatherData.city, equals('Test City'));
      expect(weatherData.temperature, equals(0.0));
      expect(weatherData.humidity, equals(0));
    });
  });
}

