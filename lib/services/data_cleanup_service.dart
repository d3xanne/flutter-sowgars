import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/alert_service.dart';
import 'package:sample/services/supabase_service.dart';

class DataCleanupService {
  static final DataCleanupService _instance = DataCleanupService._internal();
  factory DataCleanupService() => _instance;
  DataCleanupService._internal();

  /// Clear all local storage data
  Future<void> clearAllLocalData() async {
    try {
      print('🧹 Starting local data cleanup...');
      
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
      
      print('🎉 Local data cleanup completed successfully!');
    } catch (e) {
      print('❌ Error during local data cleanup: $e');
      rethrow;
    }
  }

  /// Clear all Supabase database data
  Future<void> clearAllSupabaseData() async {
    try {
      print('🧹 Starting Supabase database cleanup...');
      
      // Clear all tables in Supabase with better error handling
      try {
        await SupabaseService.client
            .from('sugar_records')
            .delete()
            .neq('id', 'dummy');
        print('✅ Sugar records cleared from Supabase');
      } catch (e) {
        print('⚠️ Warning: Could not clear sugar_records: $e');
      }

      try {
        await SupabaseService.client
            .from('inventory_items')
            .delete()
            .neq('id', 'dummy');
        print('✅ Inventory items cleared from Supabase');
      } catch (e) {
        print('⚠️ Warning: Could not clear inventory_items: $e');
      }

      try {
        await SupabaseService.client
            .from('supplier_transactions')
            .delete()
            .neq('id', 'dummy');
        print('✅ Supplier transactions cleared from Supabase');
      } catch (e) {
        print('⚠️ Warning: Could not clear supplier_transactions: $e');
      }

      try {
        await SupabaseService.client
            .from('farming_insights')
            .delete()
            .neq('id', 'dummy');
        print('✅ Farming insights cleared from Supabase');
      } catch (e) {
        print('⚠️ Warning: Could not clear farming_insights: $e');
      }

      try {
        await SupabaseService.client
            .from('alerts')
            .delete()
            .neq('id', 'dummy');
        print('✅ Alerts cleared from Supabase');
      } catch (e) {
        print('⚠️ Warning: Could not clear alerts: $e');
      }

      print('🎉 Supabase database cleanup completed successfully!');
    } catch (e) {
      print('❌ Error during Supabase cleanup: $e');
      // Don't rethrow - continue with local cleanup even if Supabase fails
    }
  }

  /// Perform complete system cleanup
  Future<void> performCompleteCleanup() async {
    try {
      print('🚀 Starting complete system cleanup...');
      
      // Clear local data first
      await clearAllLocalData();
      
      // Clear Supabase data
      await clearAllSupabaseData();
      
      // Reset local repository streams
      final repo = LocalRepository.instance;
      await repo.initializeStreams();
      
      print('🎉 Complete system cleanup finished!');
      print('📝 System is now clean and ready for fresh data');
      
    } catch (e) {
      print('❌ Error during complete cleanup: $e');
      rethrow;
    }
  }

  /// Reset to clean demo data (optional)
  Future<void> resetToCleanDemoData() async {
    try {
      print('🔄 Resetting to clean demo data...');
      
      // Perform complete cleanup first
      await performCompleteCleanup();
      
      // Add minimal clean demo data
      final repo = LocalRepository.instance;
      await repo.seedMinimalDemoData();
      
      print('✅ System reset to clean demo data');
      
    } catch (e) {
      print('❌ Error resetting to demo data: $e');
      rethrow;
    }
  }
}
