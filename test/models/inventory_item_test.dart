import 'package:flutter_test/flutter_test.dart';
import 'package:sample/models/inventory_item.dart';

void main() {
  group('InventoryItem', () {
    test('should create from map correctly', () {
      final map = {
        'id': 'test-id',
        'name': 'Test Item',
        'category': 'Fertilizer',
        'quantity': 100,
        'unit': 'kg',
        'last_updated': '2024-01-01',
      };

      final item = InventoryItem.fromMap(map);

      expect(item.id, equals('test-id'));
      expect(item.name, equals('Test Item'));
      expect(item.quantity, equals(100));
      expect(item.category, equals('Fertilizer'));
      expect(item.unit, equals('kg'));
    });

    test('should convert to map correctly', () {
      final item = InventoryItem(
        id: 'test-id',
        name: 'Test Item',
        category: 'Fertilizer',
        quantity: 100,
        unit: 'kg',
        lastUpdated: '2024-01-01',
      );

      final map = item.toMap();

      expect(map['id'], equals('test-id'));
      expect(map['name'], equals('Test Item'));
      expect(map['quantity'], equals(100));
      expect(map['category'], equals('Fertilizer'));
    });

    test('should create copy with modified values', () {
      final item = InventoryItem(
        id: 'test-id',
        name: 'Test Item',
        category: 'Fertilizer',
        quantity: 100,
        unit: 'kg',
        lastUpdated: '2024-01-01',
      );

      final copy = item.copyWith(quantity: 200);

      expect(copy.id, equals('test-id'));
      expect(copy.quantity, equals(200));
      expect(copy.name, equals('Test Item'));
    });
  });
}

