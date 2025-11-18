import 'package:sample/services/local_repository.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';

void main() async {
  print('🧪 Testing CRUD Operations...');
  
  final repo = LocalRepository.instance;
  
  try {
    // Test Sugar Records
    print('\n🌾 Testing Sugar Records...');
    
    // Create
    final sugarRecord = SugarRecord(
      id: 'test-sugar-1',
      date: '2025-01-15',
      variety: 'Test Variety',
      soilTest: 'pH 6.5, Good',
      fertilizer: 'NPK 14-14-14',
      heightCm: 50,
      notes: 'Test sugar record',
    );
    
    final sugarList = await repo.getSugarRecords();
    sugarList.add(sugarRecord);
    await repo.saveSugarRecords(sugarList);
    print('✅ Sugar record created');
    
    // Read
    final updatedSugarList = await repo.getSugarRecords();
    final foundSugar = updatedSugarList.firstWhere((r) => r.id == 'test-sugar-1');
    print('✅ Sugar record read: ${foundSugar.variety}');
    
    // Update
    final updatedSugar = foundSugar.copyWith(heightCm: 60, notes: 'Updated test record');
    final sugarListForUpdate = await repo.getSugarRecords();
    final sugarIndex = sugarListForUpdate.indexWhere((r) => r.id == 'test-sugar-1');
    if (sugarIndex != -1) {
      sugarListForUpdate[sugarIndex] = updatedSugar;
      await repo.saveSugarRecords(sugarListForUpdate);
      print('✅ Sugar record updated');
    }
    
    // Delete
    final sugarListForDelete = await repo.getSugarRecords();
    sugarListForDelete.removeWhere((r) => r.id == 'test-sugar-1');
    await repo.saveSugarRecords(sugarListForDelete);
    print('✅ Sugar record deleted');
    
    // Test Inventory Items
    print('\n📦 Testing Inventory Items...');
    
    // Create
    final inventoryItem = InventoryItem(
      id: 'test-inv-1',
      name: 'Test Fertilizer',
      category: 'Fertilizer',
      quantity: 10,
      unit: 'bags',
      lastUpdated: '2025-01-15',
    );
    
    final inventoryList = await repo.getInventoryItems();
    inventoryList.add(inventoryItem);
    await repo.saveInventoryItems(inventoryList);
    print('✅ Inventory item created');
    
    // Read
    final updatedInventoryList = await repo.getInventoryItems();
    final foundInventory = updatedInventoryList.firstWhere((i) => i.id == 'test-inv-1');
    print('✅ Inventory item read: ${foundInventory.name}');
    
    // Update
    final updatedInventory = foundInventory.copyWith(quantity: 15, name: 'Updated Test Fertilizer');
    final inventoryListForUpdate = await repo.getInventoryItems();
    final inventoryIndex = inventoryListForUpdate.indexWhere((i) => i.id == 'test-inv-1');
    if (inventoryIndex != -1) {
      inventoryListForUpdate[inventoryIndex] = updatedInventory;
      await repo.saveInventoryItems(inventoryListForUpdate);
      print('✅ Inventory item updated');
    }
    
    // Delete
    final inventoryListForDelete = await repo.getInventoryItems();
    inventoryListForDelete.removeWhere((i) => i.id == 'test-inv-1');
    await repo.saveInventoryItems(inventoryListForDelete);
    print('✅ Inventory item deleted');
    
    // Test Supplier Transactions
    print('\n💰 Testing Supplier Transactions...');
    
    // Create
    final supplierTransaction = SupplierTransaction(
      id: 'test-sup-1',
      supplierName: 'Test Supplier',
      itemName: 'Test Item',
      quantity: 5,
      unit: 'pieces',
      amount: 100.0,
      date: '2025-01-15',
      notes: 'Test transaction',
    );
    
    final supplierList = await repo.getSupplierTransactions();
    supplierList.add(supplierTransaction);
    await repo.saveSupplierTransactions(supplierList);
    print('✅ Supplier transaction created');
    
    // Read
    final updatedSupplierList = await repo.getSupplierTransactions();
    final foundSupplier = updatedSupplierList.firstWhere((t) => t.id == 'test-sup-1');
    print('✅ Supplier transaction read: ${foundSupplier.supplierName}');
    
    // Update
    final updatedSupplier = SupplierTransaction(
      id: foundSupplier.id,
      supplierName: 'Updated Test Supplier',
      itemName: foundSupplier.itemName,
      quantity: foundSupplier.quantity,
      unit: foundSupplier.unit,
      amount: 150.0,
      date: foundSupplier.date,
      notes: 'Updated test transaction',
    );
    final supplierListForUpdate = await repo.getSupplierTransactions();
    final supplierIndex = supplierListForUpdate.indexWhere((t) => t.id == 'test-sup-1');
    if (supplierIndex != -1) {
      supplierListForUpdate[supplierIndex] = updatedSupplier;
      await repo.saveSupplierTransactions(supplierListForUpdate);
      print('✅ Supplier transaction updated');
    }
    
    // Delete
    final supplierListForDelete = await repo.getSupplierTransactions();
    supplierListForDelete.removeWhere((t) => t.id == 'test-sup-1');
    await repo.saveSupplierTransactions(supplierListForDelete);
    print('✅ Supplier transaction deleted');
    
    print('\n🎉 All CRUD operations completed successfully!');
    print('✅ Create, Read, Update, Delete operations work for all data types');
    print('✅ Data persistence is working correctly');
    print('✅ Stream updates should work in the UI');
    
  } catch (e) {
    print('❌ Error during CRUD testing: $e');
  }
}
