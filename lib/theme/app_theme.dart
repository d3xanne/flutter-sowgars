import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static ThemeMode _themeMode = ThemeMode.system;
  
  // Simplified 3-Color Palette
  static const Color _primary = Color(0xFF2E7D32); // Forest Green
  static const Color _secondary = Color(0xFF4CAF50); // Light Green  
  static const Color _accent = Color(0xFF8BC34A); // Lime Green
  
  // Light Theme Colors
  static const Color _lightPrimary = _primary;
  static const Color _lightPrimaryDark = Color(0xFF1B5E20); // Darker green
  static const Color _lightSecondary = _secondary;
  static const Color _lightBackground = Color(0xFFF8F9FA); // Very light gray
  static const Color _lightSurface = Color(0xFFFFFFFF); // White
  static const Color _lightCard = Color(0xFFFFFFFF); // White
  static const Color _lightText = Color(0xFF212121); // Dark gray
  static const Color _lightTextSecondary = Color(0xFF757575); // Medium gray
  
  // Dark Theme Colors
  static const Color _darkPrimary = _secondary;
  static const Color _darkPrimaryDark = _primary;
  static const Color _darkSecondary = _accent;
  static const Color _darkBackground = Color(0xFF121212); // Dark gray
  static const Color _darkSurface = Color(0xFF1E1E1E); // Darker gray
  static const Color _darkCard = Color(0xFF2D2D2D); // Dark card
  static const Color _darkText = Color(0xFFFFFFFF); // White
  static const Color _darkTextSecondary = Color(0xFFB0B0B0); // Light gray
  
  // Feature Colors (using the 3-color palette)
  static const Color _weather = _accent;
  static const Color _insights = _secondary;
  static const Color _reports = _primary;
  static const Color _settings = _primary;
  static const Color _success = _secondary;
  static const Color _warning = _accent;
  static const Color _error = Color(0xFFD32F2F); // Red (only for errors)
  static const Color _info = _secondary;

  // Getters
  static ThemeMode get themeMode => _themeMode;
  static bool get isDarkMode => _themeMode == ThemeMode.dark;
  static bool get isLightMode => _themeMode == ThemeMode.light;
  static bool get isSystemMode => _themeMode == ThemeMode.system;

  // Theme switching
  static void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    // Save to preferences would go here
  }

  static void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        primaryContainer: _lightPrimaryDark,
        secondary: _lightSecondary,
        surface: _lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightText,
        onError: Colors.white,
        error: _error,
      ),
      scaffoldBackgroundColor: _lightBackground,
      cardColor: _lightCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _lightText, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: _lightText, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: _lightText, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: _lightText, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: _lightText, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: _lightText, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: _lightText, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: _lightText, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: _lightText, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: _lightText),
        bodyMedium: TextStyle(color: _lightText),
        bodySmall: TextStyle(color: _lightTextSecondary),
        labelLarge: TextStyle(color: _lightText, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: _lightText),
        labelSmall: TextStyle(color: _lightTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightTextSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightTextSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightTextSecondary,
        thickness: 1,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        primaryContainer: _darkPrimaryDark,
        secondary: _darkSecondary,
        surface: _darkSurface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: _darkText,
        onError: Colors.white,
        error: _error,
      ),
      scaffoldBackgroundColor: _darkBackground,
      cardColor: _darkCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkText,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: _darkText, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: _darkText, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: _darkText, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: _darkText, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: _darkText, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: _darkText, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: _darkText, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: _darkText, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: _darkText, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: _darkText),
        bodyMedium: TextStyle(color: _darkText),
        bodySmall: TextStyle(color: _darkTextSecondary),
        labelLarge: TextStyle(color: _darkText, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: _darkText),
        labelSmall: TextStyle(color: _darkTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _darkTextSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _darkTextSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _darkTextSecondary,
        thickness: 1,
      ),
    );
  }

  // Feature Colors (accessible from both themes)
  static Color getWeatherColor(BuildContext context) {
    return _weather;
  }

  static Color getInsightsColor(BuildContext context) {
    return _insights;
  }

  static Color getReportsColor(BuildContext context) {
    return _reports;
  }

  static Color getSettingsColor(BuildContext context) {
    return _settings;
  }

  static Color getAccentColor(BuildContext context) {
    return _accent;
  }

  static Color getSuccessColor(BuildContext context) {
    return _success;
  }

  static Color getWarningColor(BuildContext context) {
    return _warning;
  }

  static Color getErrorColor(BuildContext context) {
    return _error;
  }

  static Color getInfoColor(BuildContext context) {
    return _info;
  }

  // Helper methods for theme-aware colors
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }
}
