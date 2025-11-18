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
  });
}

