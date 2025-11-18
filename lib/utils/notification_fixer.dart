import 'package:sample/models/alert.dart';
import 'package:sample/services/local_repository.dart';

class NotificationFixer {
  static Future<void> createTestNotifications() async {
    try {
      print('🔔 Creating test notifications directly...');
      
      final repo = LocalRepository.instance;
      
      // Create farm-specific alerts and save them
      final testAlerts = [
        AlertItem(
          id: 'farm-1',
          title: '🌾 Sugar Growth Update',
          message: 'Phil 2009 variety: Height 120cm recorded in Field A-1. Excellent growth rate!',
          severity: 'info',
          timestamp: DateTime.now(),
        ),
        AlertItem(
          id: 'farm-2',
          title: '⚠️ Low Stock Alert',
          message: 'NPK Fertilizer: Only 5 bags remaining. Please restock soon to avoid delays.',
          severity: 'warning',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        AlertItem(
          id: 'farm-3',
          title: '🚚 Supplier Delivery',
          message: 'AgriSupply Co.: 50 bags of premium seeds delivered. Quality: Excellent.',
          severity: 'info',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        AlertItem(
          id: 'farm-4',
          title: '✅ Harvest Ready',
          message: 'Field B-2 sugarcane is ready for harvest. Estimated yield: 15 tons.',
          severity: 'success',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        AlertItem(
          id: 'farm-5',
          title: '🌧️ Weather Warning',
          message: 'Heavy rain expected in 2 hours. Cover seedlings and secure equipment.',
          severity: 'warning',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        AlertItem(
          id: 'farm-6',
          title: '📊 Monthly Report',
          message: 'December farm report generated. Total production: 45 tons of sugarcane.',
          severity: 'info',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ];
      
      // Save alerts directly
      await repo.saveAlerts(testAlerts);
      
      // Debug: Check alert count
      final alerts = await repo.getAlerts();
      print('🔔 Total alerts: ${alerts.length}');
      print('🔔 Unread alerts: ${alerts.where((a) => !a.read).length}');
      
      return;
    } catch (e) {
      print('❌ Error creating test notifications: $e');
      rethrow;
    }
  }
  
  static Future<void> clearAllNotifications() async {
    try {
      final repo = LocalRepository.instance;
      await repo.saveAlerts([]);
      print('🔔 All notifications cleared');
    } catch (e) {
      print('❌ Error clearing notifications: $e');
      rethrow;
    }
  }
}
