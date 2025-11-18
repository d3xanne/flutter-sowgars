import 'package:flutter_test/flutter_test.dart';
import 'package:sample/utils/number_converter.dart';

void main() {
  group('NumberConverter Extended Tests', () {
    test('should handle string conversion in fromMap', () {
      final map = {'value': '123.45'};
      final result = NumberConverter.fromMap(map, 'value');
      expect(result, equals(123.45));
    });

    test('should handle invalid string in fromMap', () {
      final map = {'value': 'invalid'};
      final result = NumberConverter.fromMap(map, 'value');
      expect(result, equals(0.0));
    });

    test('should use custom default value', () {
      final map = <String, dynamic>{};
      final result = NumberConverter.fromMap(map, 'missing', defaultValue: 99.9);
      expect(result, equals(99.9));
    });

    test('should handle double values', () {
      expect(NumberConverter.toDouble(3.14), equals(3.14));
    });

    test('should handle large numbers', () {
      expect(NumberConverter.intToDouble(999999), equals(999999.0));
    });

    test('should handle all conversion paths', () {
      // Test null path
      expect(NumberConverter.toDouble(null), equals(0.0));
      
      // Test int path
      expect(NumberConverter.toDouble(42), equals(42.0));
      
      // Test double path
      expect(NumberConverter.toDouble(42.5), equals(42.5));
      
      // Test num path in fromMap
      final map1 = {'value': 100};
      expect(NumberConverter.fromMap(map1, 'value'), equals(100.0));
      
      // Test String path in fromMap
      final map2 = {'value': '200.5'};
      expect(NumberConverter.fromMap(map2, 'value'), equals(200.5));
      
      // Test null path in fromMap
      final map3 = <String, dynamic>{'value': null};
      expect(NumberConverter.fromMap(map3, 'value'), equals(0.0));
      
      // Test invalid type path in fromMap
      final map4 = {'value': <String>[]};
      expect(NumberConverter.fromMap(map4, 'value'), equals(0.0));
    });
  });
}

