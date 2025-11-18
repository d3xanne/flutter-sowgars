// REPLACE THE CONTENT OF: lib/utils/preferences.dart
import 'package:sample/models/city.dart';

// A simple in-memory cache implementation
class Preferences {
  static final Map<String, dynamic> _cache = {};

  static const String _selectedCitiesKey = 'selected_cities';
  static const String _lastWeatherUpdateKey = 'last_weather_update';
  static const String _lastCityKey = 'last_city';

  // Save selected cities
  static void saveSelectedCities(List<City> cities) {
    final cityNames = cities.map((city) => city.city).toList();
    _cache[_selectedCitiesKey] = cityNames;
  }

  // Get selected cities
  static List<City> getSelectedCities() {
    final cityNames = _cache[_selectedCitiesKey] as List<String>? ?? [];

    return cityNames.map((name) {
      final city = City.findCityByName(name);
      return city?.copyWith(isSelected: true) ??
          City(city: name, isSelected: true);
    }).toList();
  }

  // Save last weather update time
  static void saveLastWeatherUpdate(DateTime time) {
    _cache[_lastWeatherUpdateKey] = time.toIso8601String();
  }

  // Get last weather update time
  static DateTime? getLastWeatherUpdate() {
    final timeString = _cache[_lastWeatherUpdateKey] as String?;
    if (timeString == null) return null;

    try {
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  // Save last selected city
  static void saveLastCity(String city) {
    _cache[_lastCityKey] = city;
  }

  // Get last selected city
  static String? getLastCity() {
    return _cache[_lastCityKey] as String?;
  }

  // Save weather data for offline use
  static void saveWeatherData(String city, Map<String, dynamic> data) {
    _cache['weather_$city'] = data;
  }

  // Get cached weather data
  static Map<String, dynamic>? getCachedWeatherData(String city) {
    return _cache['weather_$city'] as Map<String, dynamic>?;
  }
}
