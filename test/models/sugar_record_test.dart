import 'package:flutter_test/flutter_test.dart';
import 'package:sample/models/sugar_record.dart';

void main() {
  group('SugarRecord', () {
    test('should create from map correctly', () {
      final map = {
        'id': 'test-id',
        'date': '2024-01-01',
        'variety': 'Phil 2009',
        'soil_test': 'Loam',
        'fertilizer': 'NPK',
        'height_cm': 150,
        'notes': 'Test notes',
      };

      final record = SugarRecord.fromMap(map);

      expect(record.id, equals('test-id'));
      expect(record.variety, equals('Phil 2009'));
      expect(record.heightCm, equals(150));
    });

    test('should convert to map correctly', () {
      final record = SugarRecord(
        id: 'test-id',
        date: '2024-01-01',
        variety: 'Phil 2009',
        soilTest: 'Loam',
        fertilizer: 'NPK',
        heightCm: 150,
        notes: 'Test notes',
      );

      final map = record.toMap();

      expect(map['id'], equals('test-id'));
      expect(map['variety'], equals('Phil 2009'));
      expect(map['height_cm'], equals(150));
    });
  });
}

