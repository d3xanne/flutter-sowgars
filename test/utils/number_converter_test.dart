import 'package:flutter_test/flutter_test.dart';
import 'package:sample/utils/number_converter.dart';

void main() {
  group('NumberConverter', () {
    test('should convert int to double', () {
      expect(NumberConverter.intToDouble(5), equals(5.0));
      expect(NumberConverter.intToDouble(0), equals(0.0));
      expect(NumberConverter.intToDouble(-10), equals(-10.0));
    });

    test('should convert num to double', () {
      expect(NumberConverter.toDouble(5), equals(5.0));
      expect(NumberConverter.toDouble(5.5), equals(5.5));
      expect(NumberConverter.toDouble(0), equals(0.0));
    });

    test('should handle null values', () {
      expect(NumberConverter.toDouble(null), equals(0.0));
    });

    test('should extract double from map', () {
      final map = {
        'value1': 10,
        'value2': 20.5,
        'value3': '30.5',
        'value4': null,
        'value5': 'invalid',
      };

      expect(NumberConverter.fromMap(map, 'value1'), equals(10.0));
      expect(NumberConverter.fromMap(map, 'value2'), equals(20.5));
      expect(NumberConverter.fromMap(map, 'value3'), equals(30.5));
      expect(NumberConverter.fromMap(map, 'value4'), equals(0.0));
      expect(NumberConverter.fromMap(map, 'value5'), equals(0.0));
    });

    test('should use default value when key not found', () {
      final map = <String, dynamic>{};
      
      expect(NumberConverter.fromMap(map, 'missing'), equals(0.0));
      expect(NumberConverter.fromMap(map, 'missing', defaultValue: 99.9), equals(99.9));
    });
  });
}

