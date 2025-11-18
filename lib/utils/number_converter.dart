/// Utility class for number conversions to reduce code duplication
class NumberConverter {
  /// Safely converts a number to double
  /// Returns 0.0 if conversion fails
  static double toDouble(num? value) {
    if (value == null) return 0.0;
    return value.toDouble();
  }

  /// Converts an integer to double
  static double intToDouble(int value) {
    return value.toDouble();
  }

  /// Safely converts a map value to double
  static double fromMap(Map<String, dynamic> map, String key, {double defaultValue = 0.0}) {
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
}

