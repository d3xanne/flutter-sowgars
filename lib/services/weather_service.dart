import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sample/utils/number_converter.dart';

class WeatherData {
  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final DateTime lastUpdated;
  final double pressure;
  final int visibility;
  final double uvIndex;
  final String sunrise;
  final String sunset;
  final double maxTemp;

  WeatherData({
    required this.city,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.lastUpdated,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.maxTemp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'];
    final weather = json['weather'][0];
    final wind = json['wind'];
    final sys = json['sys'];
    
    return WeatherData(
      city: json['name'] ?? 'Talisay City',
      country: sys['country'] ?? 'PH',
      temperature: NumberConverter.toDouble(main['temp']),
      feelsLike: NumberConverter.toDouble(main['feels_like']),
      humidity: main['humidity'] ?? 0,
      windSpeed: NumberConverter.toDouble(wind['speed']),
      description: weather['description'] ?? 'Unknown',
      icon: weather['icon'] ?? '01d',
      lastUpdated: DateTime.now(),
      pressure: NumberConverter.toDouble(main['pressure']),
      visibility: json['visibility'] ?? 0,
      uvIndex: 0.0, // Will be calculated separately
      sunrise: _formatTime(sys['sunrise']),
      sunset: _formatTime(sys['sunset']),
      maxTemp: NumberConverter.toDouble(main['temp_max'] ?? main['temp']),
    );
  }

  static String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'description': description,
      'icon': icon,
      'lastUpdated': lastUpdated.toIso8601String(),
      'pressure': pressure,
      'visibility': visibility,
      'uvIndex': uvIndex,
      'sunrise': sunrise,
      'sunset': sunset,
      'maxTemp': maxTemp,
    };
  }
}

class WeatherService {
  // API key should be loaded from environment variables in production
  static const String _apiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: 'your_openweather_api_key', // Replace with actual API key
  );
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Talisay City coordinates
  static const double _latitude = 10.2439;
  static const double _longitude = 123.8417;

  static Future<WeatherData> getCurrentWeather() async {
    try {
      // For demo purposes, we'll use a mock API or free tier
      // In production, replace with actual OpenWeatherMap API key
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$_latitude&lon=$_longitude&appid=$_apiKey&units=metric'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Weather request timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else if (response.statusCode == 401) {
        // API key invalid, return mock data for demo
        return _getMockWeatherData();
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data if API fails
      return _getMockWeatherData();
    }
  }

  static WeatherData _getMockWeatherData() {
    // Mock data for Talisay City based on typical Philippine weather
    final now = DateTime.now();
    final hour = now.hour;
    
    // Simulate different weather based on time of day with consistent data
    String description;
    String icon;
    double temperature;
    double maxTemp;
    
    if (hour >= 6 && hour < 12) {
      description = 'Partly Cloudy';
      icon = '02d';
      temperature = 28.0 + (hour - 6) * 1.5;
      maxTemp = 33.0;
    } else if (hour >= 12 && hour < 18) {
      description = 'Sunny';
      icon = '01d';
      temperature = 32.0 + (hour - 12) * 0.5;
      maxTemp = 35.0;
    } else if (hour >= 18 && hour < 22) {
      description = 'Clear';
      icon = '01n';
      temperature = 30.0 - (hour - 18) * 1.0;
      maxTemp = 33.0;
    } else {
      description = 'Clear';
      icon = '01n';
      temperature = 26.0;
      maxTemp = 30.0;
    }

    return WeatherData(
      city: 'Talisay City',
      country: 'PH',
      temperature: temperature,
      feelsLike: temperature + 2.0,
      humidity: 69, // Fixed humidity value
      windSpeed: 7.0, // Fixed wind speed value
      description: description,
      icon: icon,
      lastUpdated: now,
      pressure: 1013.0 + (hour % 5),
      visibility: 10000,
      uvIndex: hour >= 10 && hour <= 16 ? 8.0 : 2.0,
      sunrise: '05:45',
      sunset: '18:15',
      maxTemp: maxTemp,
    );
  }

  static Future<List<WeatherData>> getForecast() async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=$_latitude&lon=$_longitude&appid=$_apiKey&units=metric'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Forecast request timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecasts = data['list'];
        
        return forecasts.take(5).map((item) => WeatherData.fromJson(item)).toList();
      } else {
        return _getMockForecast();
      }
    } catch (e) {
      return _getMockForecast();
    }
  }

  static List<WeatherData> _getMockForecast() {
    final now = DateTime.now();
    final List<WeatherData> forecast = [];
    
    // Create 5-day forecast with varied weather conditions
    final weatherConditions = [
      {'desc': 'Sunny', 'icon': '01d', 'temp': 33.0, 'humidity': 69, 'wind': 7.0},
      {'desc': 'Partly Cloudy', 'icon': '02d', 'temp': 31.0, 'humidity': 72, 'wind': 6.0},
      {'desc': 'Cloudy', 'icon': '04d', 'temp': 29.0, 'humidity': 75, 'wind': 8.0},
      {'desc': 'Light Rain', 'icon': '10d', 'temp': 27.0, 'humidity': 80, 'wind': 9.0},
      {'desc': 'Clear', 'icon': '01n', 'temp': 30.0, 'humidity': 68, 'wind': 5.0},
    ];
    
    for (int i = 0; i < 5; i++) {
      final date = now.add(Duration(days: i));
      final condition = weatherConditions[i];
      
      forecast.add(WeatherData(
        city: 'Talisay City',
        country: 'PH',
        temperature: condition['temp'] as double,
        feelsLike: (condition['temp'] as double) + 2.0,
        humidity: condition['humidity'] as int,
        windSpeed: condition['wind'] as double,
        description: condition['desc'] as String,
        icon: condition['icon'] as String,
        lastUpdated: date,
        pressure: 1013.0 + (i * 2),
        visibility: 10000 - (i * 500),
        uvIndex: i < 2 ? 8.0 : 6.0,
        sunrise: '05:45',
        sunset: '18:15',
        maxTemp: (condition['temp'] as double) + 2.0,
      ));
    }
    
    return forecast;
  }

  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  static Color getTemperatureColor(double temperature) {
    if (temperature < 20) return Colors.blue;
    if (temperature < 25) return Colors.cyan;
    if (temperature < 30) return Colors.green;
    if (temperature < 35) return Colors.orange;
    return Colors.red;
  }

  static String getWindDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'E';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SW';
    if (degrees >= 247.5 && degrees < 292.5) return 'W';
    if (degrees >= 292.5 && degrees < 337.5) return 'NW';
    return 'N';
  }
}