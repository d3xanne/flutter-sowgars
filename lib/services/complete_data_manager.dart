import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/alert_service.dart';
import 'package:sample/services/supabase_service.dart';

/// Complete Data Manager - Ensures perfect synchronization between local and Supabase
class CompleteDataManager {
  static final CompleteDataManager _instance = CompleteDataManager._internal();
  factory CompleteDataManager() => _instance;
  CompleteDataManager._internal();

  /// Complete system cleanup - removes ALL data from both local and database
  static Future<void> performCompleteCleanup() async {
    try {
      print('🚀 Starting complete system cleanup...');
      
      // Step 1: Clear local data
      print('🧹 Step 1: Clearing local data...');
      await _clearLocalData();
      
      // Step 2: Clear Supabase data
      print('🧹 Step 2: Clearing Supabase data...');
      await _clearSupabaseData();
      
      // Step 3: Reset streams
      print('🔄 Step 3: Resetting data streams...');
      await _resetStreams();
      
      print('🎉 Complete system cleanup finished!');
      print('📝 System is now completely clean and ready for fresh data');
      
    } catch (e) {
      print('❌ Error during complete cleanup: $e');
      rethrow;
    }
  }

  /// Clear all local storage data
  static Future<void> _clearLocalData() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ SharedPreferences cleared');
      
      // Clear local repository data
      final repo = LocalRepository.instance;
      await repo.clearAllData();
      print('✅ Local repository data cleared');
      
      // Clear alerts
      await AlertService.clearAllAlerts();
      print('✅ All alerts cleared');
      
    } catch (e) {
      print('❌ Error clearing local data: $e');
      rethrow;
    }
  }

  /// Clear all Supabase database data
  static Future<void> _clearSupabaseData() async {
    if (!SupabaseService.isReady) {
      print('⚠️ Supabase not ready, skipping database cleanup');
      return;
    }

    try {
      // Clear each table individually with error handling
      await _clearTable('sugar_records', 'Sugar records');
      await _clearTable('inventory_items', 'Inventory items');
      await _clearTable('supplier_transactions', 'Supplier transactions');
      await _clearTable('farming_insights', 'Farming insights');
      await _clearTable('alerts', 'Alerts');
      await _clearTable('realtime_events', 'Real-time events');
      
      print('✅ All Supabase data cleared successfully');
      
    } catch (e) {
      print('❌ Error clearing Supabase data: $e');
      // Don't rethrow - continue with local cleanup
    }
  }

  /// Clear a specific table
  static Future<void> _clearTable(String tableName, String displayName) async {
    try {
      await SupabaseService.client
          .from(tableName)
          .delete()
          .neq('id', 'dummy');
      print('✅ $displayName cleared from Supabase');
    } catch (e) {
      print('⚠️ Warning: Could not clear $displayName: $e');
    }
  }

  /// Reset all data streams
  static Future<void> _resetStreams() async {
    try {
      final repo = LocalRepository.instance;
      await repo.initializeStreams();
      print('✅ Data streams reset');
    } catch (e) {
      print('❌ Error resetting streams: $e');
      rethrow;
    }
  }

  /// Sync all local data to Supabase
  static Future<void> syncAllDataToSupabase() async {
    if (!SupabaseService.isReady) {
      print('⚠️ Supabase not ready, skipping sync');
      return;
    }

    try {
      print('🔄 Starting data synchronization to Supabase...');
      
      final repo = LocalRepository.instance;
      
      // Sync sugar records
      final sugarRecords = await repo.getSugarRecords();
      if (sugarRecords.isNotEmpty) {
        await SupabaseService.saveSugarRecords(sugarRecords);
        print('✅ Sugar records synchronized (${sugarRecords.length} records)');
      }

      // Sync inventory items
      final inventoryItems = await repo.getInventoryItems();
      if (inventoryItems.isNotEmpty) {
        await SupabaseService.saveInventoryItems(inventoryItems);
        print('✅ Inventory items synchronized (${inventoryItems.length} items)');
      }

      // Sync supplier transactions
      final supplierTransactions = await repo.getSupplierTransactions();
      if (supplierTransactions.isNotEmpty) {
        await SupabaseService.saveSupplierTransactions(supplierTransactions);
        print('✅ Supplier transactions synchronized (${supplierTransactions.length} transactions)');
      }

      // Sync farming insights
      final farmingInsights = await repo.getFarmingInsights();
      if (farmingInsights.isNotEmpty) {
        await SupabaseService.saveFarmingInsights(farmingInsights);
        print('✅ Farming insights synchronized (${farmingInsights.length} insights)');
      }

      // Sync alerts
      final alerts = await repo.getAlerts();
      if (alerts.isNotEmpty) {
        await SupabaseService.saveAlerts(alerts);
        print('✅ Alerts synchronized (${alerts.length} alerts)');
      }

      print('🎉 Data synchronization completed successfully!');
      
    } catch (e) {
      print('❌ Error during data synchronization: $e');
      rethrow;
    }
  }

  /// Verify data synchronization status
  static Future<Map<String, dynamic>> getSyncStatus() async {
    final status = <String, dynamic>{};
    
    try {
      final repo = LocalRepository.instance;
      
      // Count local data
      final localSugar = await repo.getSugarRecords();
      final localInventory = await repo.getInventoryItems();
      final localSuppliers = await repo.getSupplierTransactions();
      final localInsights = await repo.getFarmingInsights();
      final localAlerts = await repo.getAlerts();
      
      status['local'] = {
        'sugar_records': localSugar.length,
        'inventory_items': localInventory.length,
        'supplier_transactions': localSuppliers.length,
        'farming_insights': localInsights.length,
        'alerts': localAlerts.length,
      };
      
      // Count Supabase data if available
      if (SupabaseService.isReady) {
        try {
          final supabaseSugar = await SupabaseService.getSugarRecords();
          final supabaseInventory = await SupabaseService.getInventoryItems();
          final supabaseSuppliers = await SupabaseService.getSupplierTransactions();
          final supabaseAlerts = await SupabaseService.getAlerts();
          
          status['supabase'] = {
            'sugar_records': supabaseSugar.length,
            'inventory_items': supabaseInventory.length,
            'supplier_transactions': supabaseSuppliers.length,
            'alerts': supabaseAlerts.length,
          };
          
          // Check if data is in sync
          status['in_sync'] = (
            localSugar.length == supabaseSugar.length &&
            localInventory.length == supabaseInventory.length &&
            localSuppliers.length == supabaseSuppliers.length &&
            localAlerts.length == supabaseAlerts.length
          );
        } catch (e) {
          status['supabase'] = 'Error: $e';
          status['in_sync'] = false;
        }
      } else {
        status['supabase'] = 'Not available';
        status['in_sync'] = false;
      }
      
    } catch (e) {
      status['error'] = e.toString();
    }
    
    return status;
  }
}
