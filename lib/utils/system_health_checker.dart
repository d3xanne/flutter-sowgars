import 'dart:async';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/alert_service.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';

class SystemHealthChecker {
  static Future<Map<String, dynamic>> runFullSystemCheck() async {
    final results = <String, dynamic>{};
    final repo = LocalRepository.instance;
    
    try {
      // Test 1: Database Connectivity
      results['database_connectivity'] = await _testDatabaseConnectivity();
      
      // Test 2: Sugar Records CRUD
      results['sugar_records_crud'] = await _testSugarRecordsCRUD(repo);
      
      // Test 3: Inventory CRUD
      results['inventory_crud'] = await _testInventoryCRUD(repo);
      
      // Test 4: Suppliers CRUD
      results['suppliers_crud'] = await _testSuppliersCRUD(repo);
      
      // Test 5: Notification System
      results['notification_system'] = await _testNotificationSystem(repo);
      
      // Test 6: Real-time Updates
      results['realtime_updates'] = await _testRealtimeUpdates(repo);
      
      // Calculate overall health score
      final scores = results.values.where((v) => v is bool).cast<bool>();
      final healthScore = scores.isNotEmpty ? (scores.where((s) => s).length / scores.length * 100).round() : 0;
      results['overall_health_score'] = healthScore;
      results['system_status'] = healthScore >= 80 ? 'HEALTHY' : healthScore >= 60 ? 'WARNING' : 'CRITICAL';
      
    } catch (e) {
      results['error'] = e.toString();
      results['system_status'] = 'ERROR';
    }
    
    return results;
  }
  
  static Future<bool> _testDatabaseConnectivity() async {
    try {
      final repo = LocalRepository.instance;
      await repo.getSugarRecords();
      return true;
    } catch (e) {
      print('Database connectivity test failed: $e');
      return false;
    }
  }
  
  static Future<bool> _testSugarRecordsCRUD(LocalRepository repo) async {
    try {
      // Test Create
      final testRecord = SugarRecord(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        date: '2024-01-01',
        variety: 'Test Variety',
        soilTest: 'Test Soil',
        fertilizer: 'Test Fertilizer',
        heightCm: 100,
        notes: 'Test Record',
      );
      
      final records = await repo.getSugarRecords();
      records.add(testRecord);
      await repo.saveSugarRecords(records);
      
      // Test Read
      final updatedRecords = await repo.getSugarRecords();
      final found = updatedRecords.any((r) => r.id == testRecord.id);
      
      // Test Update
      if (found) {
        final index = updatedRecords.indexWhere((r) => r.id == testRecord.id);
        updatedRecords[index] = testRecord.copyWith(heightCm: 150);
        await repo.saveSugarRecords(updatedRecords);
      }
      
      // Test Delete
      final finalRecords = await repo.getSugarRecords();
      final filteredRecords = finalRecords.where((r) => r.id != testRecord.id).toList();
      await repo.saveSugarRecords(filteredRecords);
      
      return true;
    } catch (e) {
      print('Sugar Records CRUD test failed: $e');
      return false;
    }
  }
  
  static Future<bool> _testInventoryCRUD(LocalRepository repo) async {
    try {
      // Test Create
      final testItem = InventoryItem(
        id: 'test_inv_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Item',
        category: 'Test Category',
        quantity: 10,
        unit: 'pieces',
        lastUpdated: '2024-01-01',
      );
      
      final items = await repo.getInventoryItems();
      items.add(testItem);
      await repo.saveInventoryItems(items);
      
      // Test Read
      final updatedItems = await repo.getInventoryItems();
      final found = updatedItems.any((i) => i.id == testItem.id);
      
      // Test Update
      if (found) {
        final index = updatedItems.indexWhere((i) => i.id == testItem.id);
        updatedItems[index] = testItem.copyWith(quantity: 20);
        await repo.saveInventoryItems(updatedItems);
      }
      
      // Test Delete
      final finalItems = await repo.getInventoryItems();
      final filteredItems = finalItems.where((i) => i.id != testItem.id).toList();
      await repo.saveInventoryItems(filteredItems);
      
      return true;
    } catch (e) {
      print('Inventory CRUD test failed: $e');
      return false;
    }
  }
  
  static Future<bool> _testSuppliersCRUD(LocalRepository repo) async {
    try {
      // Test Create
      final testTransaction = SupplierTransaction(
        id: 'test_sup_${DateTime.now().millisecondsSinceEpoch}',
        supplierName: 'Test Supplier',
        itemName: 'Test Item',
        quantity: 5,
        unit: 'pieces',
        amount: 100.0,
        date: '2024-01-01',
        notes: 'Test Transaction',
      );
      
      final transactions = await repo.getSupplierTransactions();
      transactions.add(testTransaction);
      await repo.saveSupplierTransactions(transactions);
      
      // Test Read
      final updatedTransactions = await repo.getSupplierTransactions();
      final found = updatedTransactions.any((t) => t.id == testTransaction.id);
      
      // Test Update
      if (found) {
        final index = updatedTransactions.indexWhere((t) => t.id == testTransaction.id);
        updatedTransactions[index] = SupplierTransaction(
          id: testTransaction.id,
          supplierName: testTransaction.supplierName,
          itemName: testTransaction.itemName,
          quantity: testTransaction.quantity,
          unit: testTransaction.unit,
          amount: 150.0, // Updated amount
          date: testTransaction.date,
          notes: testTransaction.notes,
        );
        await repo.saveSupplierTransactions(updatedTransactions);
      }
      
      // Test Delete
      final finalTransactions = await repo.getSupplierTransactions();
      final filteredTransactions = finalTransactions.where((t) => t.id != testTransaction.id).toList();
      await repo.saveSupplierTransactions(filteredTransactions);
      
      return true;
    } catch (e) {
      print('Suppliers CRUD test failed: $e');
      return false;
    }
  }
  
  static Future<bool> _testNotificationSystem(LocalRepository repo) async {
    try {
      // Test creating an alert
      await AlertService.alertSystemActivity(
        activity: 'Test',
        details: 'System health check notification test',
      );
      
      // Test retrieving alerts
      final alerts = await repo.getAlerts();
      final testAlert = alerts.any((a) => a.message.contains('System health check'));
      
      return testAlert;
    } catch (e) {
      print('Notification system test failed: $e');
      return false;
    }
  }
  
  static Future<bool> _testRealtimeUpdates(LocalRepository repo) async {
    try {
      final streams = [
        repo.sugarRecordsStream,
        repo.inventoryItemsStream,
        repo.supplierTransactionsStream,
        repo.alertsStream,
      ];

      final subscriptions = <StreamSubscription>[];
      for (final stream in streams) {
        subscriptions.add(stream.listen((_) {}));
      }

      for (final sub in subscriptions) {
        await sub.cancel();
      }

      return true;
    } catch (e) {
      print('Realtime updates test failed: $e');
      return false;
    }
  }
}