import 'package:sample/services/supabase_service.dart';

void main() async {
  print('🧪 Testing Supabase Connection...');
  
  try {
    // Initialize Supabase
    await SupabaseService.initialize();
    print('✅ Supabase initialized successfully');
    
    // Test connection
    final isConnected = await SupabaseService.testConnection();
    if (isConnected) {
      print('✅ Database connection successful!');
      
      // Test fetching data
      print('📊 Testing data retrieval...');
      
      final sugarRecords = await SupabaseService.getSugarRecords();
      print('🌾 Sugar records: ${sugarRecords.length}');
      
      final inventoryItems = await SupabaseService.getInventoryItems();
      print('📦 Inventory items: ${inventoryItems.length}');
      
      final supplierTransactions = await SupabaseService.getSupplierTransactions();
      print('💰 Supplier transactions: ${supplierTransactions.length}');
      
      final alerts = await SupabaseService.getAlerts();
      print('🚨 Alerts: ${alerts.length}');
      
      final events = await SupabaseService.getEvents();
      print('📈 Events: ${events.length}');
      
      print('\n🎉 All tests passed! Your Supabase setup is working perfectly!');
    } else {
      print('❌ Database connection failed');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
