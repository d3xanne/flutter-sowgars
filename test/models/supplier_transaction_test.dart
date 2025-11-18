import 'package:flutter_test/flutter_test.dart';
import 'package:sample/models/supplier_transaction.dart';

void main() {
  group('SupplierTransaction', () {
    test('should create from map correctly', () {
      final map = {
        'id': 'test-id',
        'supplier_name': 'Test Supplier',
        'item_name': 'Test Item',
        'quantity': 10,
        'unit': 'kg',
        'amount': 1000.0,
        'date': '2024-01-01',
        'notes': 'Test notes',
        'archived': false,
      };

      final transaction = SupplierTransaction.fromMap(map);

      expect(transaction.id, equals('test-id'));
      expect(transaction.supplierName, equals('Test Supplier'));
      expect(transaction.itemName, equals('Test Item'));
      expect(transaction.quantity, equals(10));
      expect(transaction.amount, equals(1000.0));
    });

    test('should convert to map correctly', () {
      final transaction = SupplierTransaction(
        id: 'test-id',
        supplierName: 'Test Supplier',
        itemName: 'Test Item',
        quantity: 10,
        unit: 'kg',
        amount: 1000.0,
        date: '2024-01-01',
        notes: 'Test notes',
        archived: false,
      );

      final map = transaction.toMap();

      expect(map['id'], equals('test-id'));
      expect(map['supplier_name'], equals('Test Supplier'));
      expect(map['amount'], equals(1000.0));
    });
  });
}

