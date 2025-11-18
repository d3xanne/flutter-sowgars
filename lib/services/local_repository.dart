import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/models/realtime_event.dart';
import 'package:sample/models/alert.dart';
import 'package:sample/models/farming_insight.dart';
import 'package:sample/services/supabase_service.dart';
import 'package:sample/services/alert_service.dart';

class LocalRepository {
  static const String _sugarKey = 'sugar_records_v1';
  static const String _inventoryKey = 'inventory_items_v1';
  static const String _supplierKey = 'supplier_tx_v1';
  static const String _eventsKey = 'realtime_events_v1';
  static const String _alertsKey = 'alerts_v1';
  static const String _insightsKey = 'farming_insights_v1';

  // Singleton instance
  static LocalRepository? _instance;
  static LocalRepository get instance {
    _instance ??= LocalRepository._internal();
    return _instance!;
  }

  LocalRepository._internal();

  final StreamController<List<SugarRecord>> _sugarStreamController =
      StreamController<List<SugarRecord>>.broadcast();
  final StreamController<List<InventoryItem>> _inventoryStreamController =
      StreamController<List<InventoryItem>>.broadcast();
  final StreamController<List<SupplierTransaction>> _supplierStreamController =
      StreamController<List<SupplierTransaction>>.broadcast();
  final StreamController<List<RealtimeEvent>> _eventsStreamController =
      StreamController<List<RealtimeEvent>>.broadcast();
  final StreamController<List<AlertItem>> _alertsStreamController =
      StreamController<List<AlertItem>>.broadcast();
  final StreamController<List<FarmingInsight>> _insightsStreamController =
      StreamController<List<FarmingInsight>>.broadcast();

  // Real-time subscription channels
  RealtimeChannel? _sugarChannel;
  RealtimeChannel? _inventoryChannel;
  RealtimeChannel? _supplierChannel;
  RealtimeChannel? _alertsChannel;

  Stream<List<SugarRecord>> get sugarRecordsStream =>
      _sugarStreamController.stream;
  Stream<List<InventoryItem>> get inventoryItemsStream =>
      _inventoryStreamController.stream;
  Stream<List<SupplierTransaction>> get supplierTransactionsStream =>
      _supplierStreamController.stream;
  Stream<List<RealtimeEvent>> get realtimeEventsStream =>
      _eventsStreamController.stream;
  Stream<List<AlertItem>> get alertsStream => _alertsStreamController.stream;
  Stream<List<FarmingInsight>> get farmingInsightsStream =>
      _insightsStreamController.stream;

  // Check if data exists
  Future<bool> hasData() async {
    final sugar = await getSugarRecords();
    final inventory = await getInventoryItems();
    final suppliers = await getSupplierTransactions();
    final alerts = await getAlerts();
    
    return sugar.isNotEmpty || inventory.isNotEmpty || suppliers.isNotEmpty || alerts.isNotEmpty;
  }

  // Seed demo data for presentation
  Future<void> seedDemoData() async {
    // Only seed if empty
    if (await hasData()) return;
    
    final sugar = await getSugarRecords();
    final inventory = await getInventoryItems();
    final suppliers = await getSupplierTransactions();
    final alerts = await getAlerts();

    final List<SugarRecord> demoSugar = sugar.isNotEmpty ? sugar : [
      SugarRecord(
        id: 'SR-001',
        date: DateTime.now().subtract(const Duration(days: 7)).toIso8601String().split('T').first,
        variety: 'Phil 80-65',
        soilTest: 'pH 6.5',
        fertilizer: 'Urea 46%',
        heightCm: 85,
        notes: 'Healthy growth observed',
      ),
      SugarRecord(
        id: 'SR-002',
        date: DateTime.now().subtract(const Duration(days: 3)).toIso8601String().split('T').first,
        variety: 'Phil 84-77',
        soilTest: 'pH 6.3',
        fertilizer: 'Organic Mix',
        heightCm: 92,
        notes: 'Improved height after rainfall',
      ),
      SugarRecord(
        id: 'SR-003',
        date: DateTime.now().toIso8601String().split('T').first,
        variety: 'Phil 75-44',
        soilTest: 'pH 6.4',
        fertilizer: 'NPK 14-14-14',
        heightCm: 98,
        notes: 'Ready for next fertilization schedule',
      ),
    ];

    final List<InventoryItem> demoInventory = inventory.isNotEmpty ? inventory : [
      InventoryItem(id: 'INV-001', name: 'Urea 46%', category: 'Fertilizer', quantity: 5, unit: 'bags', lastUpdated: DateTime.now().toIso8601String().split('T').first),
      InventoryItem(id: 'INV-002', name: 'NPK 14-14-14', category: 'Fertilizer', quantity: 12, unit: 'bags', lastUpdated: DateTime.now().toIso8601String().split('T').first),
      InventoryItem(id: 'INV-003', name: 'Glyphosate', category: 'Pesticide', quantity: 3, unit: 'liters', lastUpdated: DateTime.now().toIso8601String().split('T').first),
    ];

    final List<SupplierTransaction> demoSuppliers = suppliers.isNotEmpty ? suppliers : [
      SupplierTransaction(
        id: 'TX-001',
        supplierName: 'Agri Supply Co.',
        itemName: 'Urea 46%',
        quantity: 10,
        unit: 'bags',
        amount: 12500.00,
        date: DateTime.now().subtract(const Duration(days: 10)).toIso8601String().split('T').first,
        notes: 'Bulk purchase discount applied',
      ),
      SupplierTransaction(
        id: 'TX-002',
        supplierName: 'FarmChem',
        itemName: 'Glyphosate',
        quantity: 5,
        unit: 'liters',
        amount: 4500.00,
        date: DateTime.now().subtract(const Duration(days: 4)).toIso8601String().split('T').first,
        notes: 'Urgent purchase due to pest outbreak',
      ),
    ];

    final List<AlertItem> demoAlerts = alerts.isNotEmpty ? alerts : [
      AlertItem(
        id: 'AL-001',
        title: 'Low Stock: Glyphosate',
        message: 'Only 3 liters remaining. Please reorder soon.',
        severity: 'high',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        read: false,
      ),
      AlertItem(
        id: 'AL-002',
        title: 'New Growth Record Added',
        message: 'Variety Phil 75-44 recorded today.',
        severity: 'low',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        read: false,
      ),
      AlertItem(
        id: 'AL-003',
        title: 'System Sync Successful',
        message: 'All data synced with Supabase.',
        severity: 'medium',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        read: false,
      ),
    ];

    await saveSugarRecords(demoSugar);
    await saveInventoryItems(demoInventory);
    await saveSupplierTransactions(demoSuppliers);
    await saveAlerts(demoAlerts);
  }

  // Clear all local data
  Future<void> clearAllData() async {
    try {
      print('🧹 Clearing all local repository data...');
      
      // Clear all data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sugarKey);
      await prefs.remove(_inventoryKey);
      await prefs.remove(_supplierKey);
      await prefs.remove(_eventsKey);
      await prefs.remove(_alertsKey);
      await prefs.remove(_insightsKey);
      
      // Clear all streams
      _sugarStreamController.add([]);
      _inventoryStreamController.add([]);
      _supplierStreamController.add([]);
      _eventsStreamController.add([]);
      _alertsStreamController.add([]);
      _insightsStreamController.add([]);
      
      print('✅ All local data cleared successfully');
    } catch (e) {
      print('❌ Error clearing local data: $e');
      rethrow;
    }
  }

  /// Ensure complete data synchronization between local and Supabase
  Future<void> syncAllData() async {
    try {
      print('🔄 Starting complete data synchronization...');
      
      if (!SupabaseService.isReady) {
        print('⚠️ Supabase not ready, skipping sync');
        return;
      }

      // Sync sugar records
      final sugarRecords = await getSugarRecords();
      if (sugarRecords.isNotEmpty) {
        await SupabaseService.saveSugarRecords(sugarRecords);
        print('✅ Sugar records synchronized');
      }

      // Sync inventory items
      final inventoryItems = await getInventoryItems();
      if (inventoryItems.isNotEmpty) {
        await SupabaseService.saveInventoryItems(inventoryItems);
        print('✅ Inventory items synchronized');
      }

      // Sync supplier transactions
      final supplierTransactions = await getSupplierTransactions();
      if (supplierTransactions.isNotEmpty) {
        await SupabaseService.saveSupplierTransactions(supplierTransactions);
        print('✅ Supplier transactions synchronized');
      }

      // Sync farming insights
      final farmingInsights = await getFarmingInsights();
      if (farmingInsights.isNotEmpty) {
        await SupabaseService.saveFarmingInsights(farmingInsights);
        print('✅ Farming insights synchronized');
      }

      // Sync alerts
      final alerts = await getAlerts();
      if (alerts.isNotEmpty) {
        await SupabaseService.saveAlerts(alerts);
        print('✅ Alerts synchronized');
      }

      print('🎉 Complete data synchronization finished!');
    } catch (e) {
      print('❌ Error during data synchronization: $e');
      rethrow;
    }
  }

  // Seed minimal clean demo data
  Future<void> seedMinimalDemoData() async {
    try {
      print('🌱 Seeding minimal clean demo data...');
      
      // Add one clean example of each type
      final List<SugarRecord> cleanSugar = [
        SugarRecord(
          id: 'SR-CLEAN-001',
          date: DateTime.now().toIso8601String().split('T').first,
          variety: 'Phil 80-65',
          soilTest: 'pH 6.5',
          fertilizer: 'Urea 46%',
          heightCm: 85,
          notes: 'Clean demo data - ready for real data',
        ),
      ];

      final List<InventoryItem> cleanInventory = [
        InventoryItem(
          id: 'INV-CLEAN-001', 
          name: 'Urea 46%', 
          category: 'Fertilizer', 
          quantity: 10, 
          unit: 'bags', 
          lastUpdated: DateTime.now().toIso8601String().split('T').first
        ),
      ];

      final List<SupplierTransaction> cleanSuppliers = [
        SupplierTransaction(
          id: 'ST-CLEAN-001',
          supplierName: 'Demo Supplier',
          itemName: 'Urea 46%',
          quantity: 10,
          unit: 'bags',
          amount: 2500.0,
          date: DateTime.now().toIso8601String().split('T').first,
          notes: 'Clean demo data - ready for real data',
          archived: false,
        ),
      ];

      final List<AlertItem> cleanAlerts = [
        AlertItem(
          id: 'AL-CLEAN-001',
          title: 'System Ready',
          message: 'Hacienda Elizabeth system is ready for use',
          severity: 'info',
          timestamp: DateTime.now(),
          read: false,
        ),
      ];

      await saveSugarRecords(cleanSugar);
      await saveInventoryItems(cleanInventory);
      await saveSupplierTransactions(cleanSuppliers);
      await saveAlerts(cleanAlerts);
      
      print('✅ Minimal clean demo data seeded');
    } catch (e) {
      print('❌ Error seeding minimal demo data: $e');
      rethrow;
    }
  }

  // Initialize real-time subscriptions (optimized)
  Future<void> initializeRealtimeSubscriptions() async {
    if (!SupabaseService.isReady) return;

    try {
      // Subscribe to sugar records changes
      _sugarChannel = SupabaseService.subscribeToSugarRecords((records) {
        _sugarStreamController.add(records);
        _saveSugarRecordsLocally(records);
      });

      // Subscribe to inventory items changes
      _inventoryChannel = SupabaseService.subscribeToInventoryItems((items) {
        _inventoryStreamController.add(items);
        _saveInventoryItemsLocally(items);
      });

      // Subscribe to supplier transactions changes
      _supplierChannel = SupabaseService.subscribeToSupplierTransactions((transactions) {
        _supplierStreamController.add(transactions);
        _saveSupplierTransactionsLocally(transactions);
      });

      // Subscribe to alerts changes
      _alertsChannel = SupabaseService.subscribeToAlerts((alerts) {
        _alertsStreamController.add(alerts);
        _saveAlertsLocally(alerts);
      });

      print('✅ Real-time subscriptions initialized');
    } catch (e) {
      print('❌ Failed to initialize real-time subscriptions: $e');
    }
  }

  // Helper methods to save data locally when received from Supabase
  Future<void> _saveSugarRecordsLocally(List<SugarRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_sugarKey, records.map((e) => e.toJson()).toList());
  }

  Future<void> _saveInventoryItemsLocally(List<InventoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_inventoryKey, items.map((e) => e.toJson()).toList());
  }

  Future<void> _saveSupplierTransactionsLocally(List<SupplierTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_supplierKey, transactions.map((e) => e.toJson()).toList());
  }

  Future<void> _saveAlertsLocally(List<AlertItem> alerts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_alertsKey, alerts.map((e) => e.toJson()).toList());
  }

  Future<List<SugarRecord>> getSugarRecords() async {
    // Use local storage directly for faster loading
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_sugarKey) ?? [];
    return raw.map((e) => SugarRecord.fromJson(e)).toList();
  }

  Future<void> saveSugarRecords(List<SugarRecord> records) async {
    // Save to Supabase if available
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.saveSugarRecords(records);
      } catch (e) {
        print('Supabase save error, saving locally: $e');
      }
    }
    
    // Always save locally as backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _sugarKey, records.map((e) => e.toJson()).toList());
    _sugarStreamController.add(await getSugarRecords());
    
    // Send notification for sugar records update
    await AlertService.addActivityAlert(
      activity: 'Sugar Records Updated',
      entity: 'Sugar Monitoring',
      details: '🌾 ${records.length} sugar records synchronized',
      severity: 'info',
    );
    
    await _appendEvent(RealtimeEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      entity: 'sugar',
      action: 'save_all',
      message: 'Sugar records updated (${records.length})',
      timestamp: DateTime.now(),
    ));
  }

  Future<void> deleteSugarRecord(String id) async {
    // Get the record before deleting for notification
    final current = await getSugarRecords();
    final recordToDelete = current.firstWhere((record) => record.id == id);
    
    // Delete from Supabase if available
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.deleteSugarRecord(id);
      } catch (e) {
        print('Supabase delete error: $e');
      }
    }
    
    // Delete from local storage
    final prefs = await SharedPreferences.getInstance();
    current.removeWhere((record) => record.id == id);
    await prefs.setStringList(_sugarKey, current.map((e) => e.toJson()).toList());
    _sugarStreamController.add(await getSugarRecords());
    
    // Send notification for sugar record deletion
    await AlertService.notifySugarRecordDeleted(recordToDelete.variety);
    
    await _appendEvent(RealtimeEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      entity: 'sugar',
      action: 'delete',
      message: 'Sugar record deleted',
      timestamp: DateTime.now(),
    ));
  }

  Future<List<InventoryItem>> getInventoryItems() async {
    // Use local storage directly for faster loading
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_inventoryKey) ?? [];
    return raw.map((e) => InventoryItem.fromJson(e)).toList();
  }

  Future<void> saveInventoryItems(List<InventoryItem> items) async {
    // Save to Supabase if available
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.saveInventoryItems(items);
      } catch (e) {
        print('Supabase save error, saving locally: $e');
      }
    }
    
    // Always save locally as backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _inventoryKey, items.map((e) => e.toJson()).toList());
    _inventoryStreamController.add(await getInventoryItems());
    
    // Send notification for inventory update
    await AlertService.addActivityAlert(
      activity: 'Inventory Updated',
      entity: 'Inventory Management',
      details: '📦 ${items.length} inventory items synchronized',
      severity: 'info',
    );
    
    // Check for low stock after inventory update
    await AlertService.checkLowStock();
    
    await _appendEvent(RealtimeEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      entity: 'inventory',
      action: 'save_all',
      message: 'Inventory items updated (${items.length})',
      timestamp: DateTime.now(),
    ));
  }

  Future<void> deleteInventoryItem(String id) async {
    // Get the item before deleting for notification
    final current = await getInventoryItems();
    final itemToDelete = current.firstWhere((item) => item.id == id);
    
    // Delete from Supabase if available
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.deleteInventoryItem(id);
      } catch (e) {
        print('Supabase delete error: $e');
      }
    }
    
    // Delete from local storage
    final prefs = await SharedPreferences.getInstance();
    current.removeWhere((item) => item.id == id);
    await prefs.setStringList(_inventoryKey, current.map((e) => e.toJson()).toList());
    _inventoryStreamController.add(await getInventoryItems());
    
    // Send notification for inventory item deletion
    await AlertService.notifyInventoryItemDeleted(itemToDelete.name);
    
    await _appendEvent(RealtimeEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      entity: 'inventory',
      action: 'delete',
      message: 'Inventory item deleted',
      timestamp: DateTime.now(),
    ));
  }

  Future<List<SupplierTransaction>> getSupplierTransactions() async {
    // Use local storage directly for faster loading
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_supplierKey) ?? [];
    return raw.map((e) => SupplierTransaction.fromJson(e)).toList();
  }

  Future<void> saveSupplierTransactions(List<SupplierTransaction> tx) async {
    // Save to Supabase if available
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.saveSupplierTransactions(tx);
      } catch (e) {
        print('Supabase save error, saving locally: $e');
      }
    }
    
    // Always save locally as backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_supplierKey, tx.map((e) => e.toJson()).toList());
    _supplierStreamController.add(await getSupplierTransactions());
    
    // Send notification for supplier transactions update
    await AlertService.addActivityAlert(
      activity: 'Transactions Updated',
      entity: 'Supplier Management',
      details: '🚚 ${tx.length} supplier transactions synchronized',
      severity: 'info',
    );
    
    await _appendEvent(RealtimeEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      entity: 'supplier',
      action: 'save_all',
      message: 'Supplier transactions updated (${tx.length})',
      timestamp: DateTime.now(),
    ));
  }

  Future<void> deleteSupplierTransaction(String id) async {
    // Delete from Supabase if available
    if (SupabaseService.isReady) {
      try {
        await SupabaseService.deleteSupplierTransaction(id);
      } catch (e) {
        print('Supabase delete error: $e');
      }
    }
    
    // Delete from local storage
    final prefs = await SharedPreferences.getInstance();
    final current = await getSupplierTransactions();
    current.removeWhere((transaction) => transaction.id == id);
    await prefs.setStringList(_supplierKey, current.map((e) => e.toJson()).toList());
    _supplierStreamController.add(await getSupplierTransactions());
    await _appendEvent(RealtimeEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      entity: 'supplier',
      action: 'delete',
      message: 'Supplier transaction deleted',
      timestamp: DateTime.now(),
    ));
  }
  
  // Archive supplier transaction instead of deleting
  Future<void> archiveSupplierTransaction(String id) async {
    final current = await getSupplierTransactions();
    final transactionIndex = current.indexWhere((tx) => tx.id == id);
    
    if (transactionIndex != -1) {
      final transaction = current[transactionIndex];
      final archivedTransaction = transaction.copyWith(
        archived: true,
        archivedAt: DateTime.now().toIso8601String(),
      );
      
      current[transactionIndex] = archivedTransaction;
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_supplierKey, current.map((e) => e.toJson()).toList());
      _supplierStreamController.add(await getSupplierTransactions());
      
      // Send notification for archiving
      await AlertService.notifySupplierTransactionArchived(transaction.supplierName, transaction.itemName);
      
      await _appendEvent(RealtimeEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        entity: 'supplier',
        action: 'archive',
        message: 'Supplier transaction archived',
        timestamp: DateTime.now(),
      ));
    }
  }
  
  // Get only active (non-archived) transactions
  Future<List<SupplierTransaction>> getActiveSupplierTransactions() async {
    final allTransactions = await getSupplierTransactions();
    return allTransactions.where((tx) => !tx.archived).toList();
  }
  
  // Get only archived transactions
  Future<List<SupplierTransaction>> getArchivedSupplierTransactions() async {
    final allTransactions = await getSupplierTransactions();
    return allTransactions.where((tx) => tx.archived).toList();
  }
  
  // Restore archived transaction
  Future<void> restoreSupplierTransaction(String id) async {
    final current = await getSupplierTransactions();
    final transactionIndex = current.indexWhere((tx) => tx.id == id);
    
    if (transactionIndex != -1) {
      final transaction = current[transactionIndex];
      final restoredTransaction = transaction.copyWith(
        archived: false,
        archivedAt: null,
      );
      
      current[transactionIndex] = restoredTransaction;
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_supplierKey, current.map((e) => e.toJson()).toList());
      _supplierStreamController.add(await getSupplierTransactions());
      
      // Send notification for restoration
      await AlertService.notifySupplierTransactionRestored(transaction.supplierName, transaction.itemName);
      
      await _appendEvent(RealtimeEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        entity: 'supplier',
        action: 'restore',
        message: 'Supplier transaction restored',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<List<RealtimeEvent>> getEvents() async {
    // Supabase disabled: fallback to local
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_eventsKey) ?? [];
    return raw.map((e) => RealtimeEvent.fromJson(e)).toList();
  }

  Future<void> _appendEvent(RealtimeEvent event) async {
    // Supabase disabled: fallback to local
    final prefs = await SharedPreferences.getInstance();
    final current = await getEvents();
    current.add(event);
    await prefs.setStringList(
        _eventsKey, current.map((e) => e.toJson()).toList());
    _eventsStreamController.add(await getEvents());
  }

  Future<List<AlertItem>> getAlerts() async {
    // Supabase disabled: fallback to local
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_alertsKey) ?? [];
    return raw.map((e) => AlertItem.fromJson(e)).toList();
  }

  Future<void> addAlert(AlertItem alert) async {
    // Supabase disabled: fallback to local
    final prefs = await SharedPreferences.getInstance();
    final current = await getAlerts();
    current.add(alert);
    await prefs.setStringList(
        _alertsKey, current.map((e) => e.toJson()).toList());
    _alertsStreamController.add(await getAlerts());
  }

  Future<void> saveAlerts(List<AlertItem> alerts) async {
    // Supabase disabled: fallback to local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _alertsKey, alerts.map((e) => e.toJson()).toList());
    _alertsStreamController.add(await getAlerts());
  }

  // Method to refresh alerts stream with current data
  Future<void> refreshAlertsStream() async {
    final alerts = await getAlerts();
    print('🔔 Refreshing alerts stream with ${alerts.length} alerts');
    _alertsStreamController.add(alerts);
  }
  
  // Method to refresh sugar records stream with current data
  Future<void> refreshSugarRecordsStream() async {
    final records = await getSugarRecords();
    print('🔍 Refreshing sugar records stream with ${records.length} records');
    _sugarStreamController.add(records);
  }
  
  // Method to refresh inventory items stream with current data
  Future<void> refreshInventoryItemsStream() async {
    final items = await getInventoryItems();
    print('🔍 Refreshing inventory items stream with ${items.length} items');
    _inventoryStreamController.add(items);
  }
  
  // Method to refresh supplier transactions stream with current data
  Future<void> refreshSupplierTransactionsStream() async {
    final transactions = await getSupplierTransactions();
    print('🔍 Refreshing supplier transactions stream with ${transactions.length} transactions');
    _supplierStreamController.add(transactions);
  }

  // Initialize all streams with current data
  Future<void> initializeStreams() async {
    final sugarRecords = await getSugarRecords();
    final inventoryItems = await getInventoryItems();
    final supplierTransactions = await getSupplierTransactions();
    final alerts = await getAlerts();
    final insights = await getFarmingInsights();
    
    _sugarStreamController.add(sugarRecords);
    _inventoryStreamController.add(inventoryItems);
    _supplierStreamController.add(supplierTransactions);
    _alertsStreamController.add(alerts);
    _insightsStreamController.add(insights);
  }

  // Farming Insights CRUD operations
  Future<List<FarmingInsight>> getFarmingInsights() async {
    // Supabase disabled: fallback to local
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_insightsKey) ?? [];
    return raw.map((e) => FarmingInsight.fromJson(e)).toList();
  }

  Future<void> addFarmingInsight(FarmingInsight insight) async {
    // Supabase disabled: fallback to local
    final prefs = await SharedPreferences.getInstance();
    final current = await getFarmingInsights();
    current.add(insight);
    await prefs.setStringList(
        _insightsKey, current.map((e) => e.toJson()).toList());
    _insightsStreamController.add(await getFarmingInsights());
    
    // Send notification for new farming insight
    await AlertService.notifyInsightGenerated(insight.title, insight.variety);
  }

  Future<void> saveFarmingInsights(List<FarmingInsight> insights) async {
    // Supabase disabled: fallback to local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _insightsKey, insights.map((e) => e.toJson()).toList());
    _insightsStreamController.add(await getFarmingInsights());
  }

  Future<void> updateFarmingInsight(FarmingInsight insight) async {
    // Supabase disabled: fallback to local
    final prefs = await SharedPreferences.getInstance();
    final current = await getFarmingInsights();
    final index = current.indexWhere((e) => e.id == insight.id);
    if (index != -1) {
      current[index] = insight;
      await prefs.setStringList(
          _insightsKey, current.map((e) => e.toJson()).toList());
      _insightsStreamController.add(await getFarmingInsights());
    }
  }

  Future<void> deleteFarmingInsight(String id) async {
    // Supabase disabled: fallback to local
    final prefs = await SharedPreferences.getInstance();
    final current = await getFarmingInsights();
    current.removeWhere((e) => e.id == id);
    await prefs.setStringList(
        _insightsKey, current.map((e) => e.toJson()).toList());
    _insightsStreamController.add(await getFarmingInsights());
  }

  // Method to refresh farming insights stream with current data
  Future<void> refreshFarmingInsightsStream() async {
    final insights = await getFarmingInsights();
    print('🔍 Refreshing farming insights stream with ${insights.length} insights');
    _insightsStreamController.add(insights);
  }

  void dispose() {
    _sugarChannel?.unsubscribe();
    _inventoryChannel?.unsubscribe();
    _supplierChannel?.unsubscribe();
    _alertsChannel?.unsubscribe();
    
    _sugarStreamController.close();
    _inventoryStreamController.close();
    _supplierStreamController.close();
    _eventsStreamController.close();
    _alertsStreamController.close();
    _insightsStreamController.close();
  }
}
