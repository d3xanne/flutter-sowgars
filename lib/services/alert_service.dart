import 'package:sample/models/alert.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';

class AlertService {
  static final LocalRepository _repo = LocalRepository.instance;
  
  // Low stock threshold
  static const int lowStockThreshold = 10;
  
  // Real-time notification settings
  static bool _notificationsEnabled = true;
  
  // Add alert for any activity with instant notification
  static Future<void> addActivityAlert({
    required String activity,
    required String entity,
    required String details,
    String severity = 'info',
  }) async {
    if (!_notificationsEnabled) return;
    
    final alert = AlertItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: '$activity $entity',
      message: details,
      severity: severity,
      timestamp: DateTime.now(),
    );
    
    await _repo.addAlert(alert);
    print('🔔 Instant notification: $activity $entity - $details');
  }
  
  // Enable/disable notifications
  static void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }
  
  // Check for low stock and create alerts (optimized)
  static Future<void> checkLowStock() async {
    try {
      final inventoryItems = await _repo.getInventoryItems();
      final lowStockItems = inventoryItems.where((item) => item.quantity <= lowStockThreshold).toList();
      
      if (lowStockItems.isEmpty) return;
      
      // Get existing alerts once
      final existingAlerts = await _repo.getAlerts();
      final recentLowStockAlerts = existingAlerts.where((alert) => 
        alert.title.contains('Low Stock') && 
        alert.timestamp.isAfter(DateTime.now().subtract(const Duration(hours: 24)))
      ).toList();
      
      for (final item in lowStockItems) {
        // Check if alert already exists for this specific item
        final hasExistingAlert = recentLowStockAlerts.any((alert) => 
          alert.message.contains(item.name)
        );
        
        if (!hasExistingAlert) {
          await addActivityAlert(
            activity: 'Low Stock Alert',
            entity: 'Inventory Management',
            details: '⚠️ ${item.name} is running low (${item.quantity} ${item.unit} remaining). Please restock soon.',
            severity: 'warning',
          );
        }
      }
    } catch (e) {
      print('Error checking low stock: $e');
    }
  }
  
  // Comprehensive sugar record notifications
  static Future<void> notifySugarRecordAdded(SugarRecord record) async {
    await addActivityAlert(
      activity: 'New Sugar Record',
      entity: 'Sugar Monitoring',
      details: '🌾 Added ${record.variety} - Height: ${record.heightCm}cm, Soil: ${record.soilTest}',
      severity: 'success',
    );
  }
  
  static Future<void> notifySugarRecordUpdated(SugarRecord record) async {
    await addActivityAlert(
      activity: 'Sugar Record Updated',
      entity: 'Sugar Monitoring',
      details: '🌾 Updated ${record.variety} - Height: ${record.heightCm}cm',
      severity: 'info',
    );
  }
  
  static Future<void> notifySugarRecordDeleted(String variety) async {
    await addActivityAlert(
      activity: 'Sugar Record Deleted',
      entity: 'Sugar Monitoring',
      details: '🌾 Deleted $variety record',
      severity: 'warning',
    );
  }
  
  // Legacy method for backward compatibility
  static Future<void> alertSugarRecordActivity({
    required String action,
    required String variety,
    required String details,
  }) async {
    String severity = 'info';
    String title = 'Sugar Monitoring';
    
    // Determine severity based on action
    if (action.toLowerCase().contains('delete')) {
      severity = 'warning';
      title = 'Sugar Record Deleted';
    } else if (action.toLowerCase().contains('add') || action.toLowerCase().contains('new')) {
      severity = 'success';
      title = 'New Sugar Record Added';
    } else if (action.toLowerCase().contains('update')) {
      severity = 'info';
      title = 'Sugar Record Updated';
    }
    
    await addActivityAlert(
      activity: title,
      entity: 'Sugar Monitoring',
      details: '🌾 $variety: $details',
      severity: severity,
    );
  }
  
  // Alert for inventory activities
  static Future<void> alertInventoryActivity({
    required String action,
    required String itemName,
    required String details,
  }) async {
    String severity = 'info';
    String title = 'Inventory Management';
    
    // Determine severity based on action
    if (action.toLowerCase().contains('delete')) {
      severity = 'warning';
      title = 'Inventory Item Deleted';
    } else if (action.toLowerCase().contains('add') || action.toLowerCase().contains('new')) {
      severity = 'success';
      title = 'New Inventory Item Added';
    } else if (action.toLowerCase().contains('update')) {
      severity = 'info';
      title = 'Inventory Item Updated';
    }
    
    await addActivityAlert(
      activity: title,
      entity: 'Inventory Management',
      details: '📦 $itemName: $details',
      severity: severity,
    );
    
    // Check for low stock after inventory changes
    await checkLowStock();
  }
  
  // Comprehensive inventory notifications
  static Future<void> notifyInventoryItemAdded(InventoryItem item) async {
    await addActivityAlert(
      activity: 'New Inventory Item',
      entity: 'Inventory Management',
      details: '📦 Added ${item.name} - ${item.quantity} ${item.unit} (${item.category})',
      severity: 'success',
    );
    await checkLowStock();
  }
  
  static Future<void> notifyInventoryItemUpdated(InventoryItem item) async {
    await addActivityAlert(
      activity: 'Inventory Updated',
      entity: 'Inventory Management',
      details: '📦 Updated ${item.name} - ${item.quantity} ${item.unit}',
      severity: 'info',
    );
    await checkLowStock();
  }
  
  static Future<void> notifyInventoryItemDeleted(String itemName) async {
    await addActivityAlert(
      activity: 'Inventory Item Deleted',
      entity: 'Inventory Management',
      details: '📦 Deleted $itemName',
      severity: 'warning',
    );
  }
  
  static Future<void> notifyLowStock(InventoryItem item) async {
    await addActivityAlert(
      activity: 'Low Stock Alert',
      entity: 'Inventory Management',
      details: '⚠️ ${item.name} is running low (${item.quantity} ${item.unit} remaining)',
      severity: 'warning',
    );
  }
  
  // Alert for supplier activities
  static Future<void> alertSupplierActivity({
    required String action,
    required String supplierName,
    required String details,
  }) async {
    String severity = 'info';
    String title = 'Supplier Management';
    
    // Determine severity based on action
    if (action.toLowerCase().contains('delete')) {
      severity = 'warning';
      title = 'Supplier Transaction Deleted';
    } else if (action.toLowerCase().contains('add') || action.toLowerCase().contains('new')) {
      severity = 'success';
      title = 'New Supplier Transaction';
    } else if (action.toLowerCase().contains('update')) {
      severity = 'info';
      title = 'Supplier Transaction Updated';
    }
    
    await addActivityAlert(
      activity: title,
      entity: 'Supplier Management',
      details: '🚚 $supplierName: $details',
      severity: severity,
    );
  }
  
  // Comprehensive supplier notifications
  static Future<void> notifySupplierTransactionAdded(SupplierTransaction transaction) async {
    await addActivityAlert(
      activity: 'New Transaction',
      entity: 'Supplier Management',
      details: '🚚 ${transaction.supplierName} - ${transaction.itemName} (${transaction.quantity} ${transaction.unit}) - ₱${transaction.amount.toStringAsFixed(0)}',
      severity: 'success',
    );
  }
  
  static Future<void> notifySupplierTransactionUpdated(SupplierTransaction transaction) async {
    await addActivityAlert(
      activity: 'Transaction Updated',
      entity: 'Supplier Management',
      details: '🚚 Updated ${transaction.supplierName} - ${transaction.itemName}',
      severity: 'info',
    );
  }
  
  static Future<void> notifySupplierTransactionDeleted(String supplierName, String itemName) async {
    await addActivityAlert(
      activity: 'Transaction Deleted',
      entity: 'Supplier Management',
      details: '🚚 Deleted ${supplierName} - $itemName',
      severity: 'warning',
    );
  }
  
  static Future<void> notifySupplierTransactionArchived(String supplierName, String itemName) async {
    await addActivityAlert(
      activity: 'Transaction Archived',
      entity: 'Supplier Management',
      details: '📦 Archived ${supplierName} - $itemName (can be restored later)',
      severity: 'info',
    );
  }
  
  static Future<void> notifySupplierTransactionRestored(String supplierName, String itemName) async {
    await addActivityAlert(
      activity: 'Transaction Restored',
      entity: 'Supplier Management',
      details: '🔄 Restored ${supplierName} - $itemName from archive',
      severity: 'success',
    );
  }
  
  // Alert for weather activities
  static Future<void> alertWeatherActivity({
    required String condition,
    required String temperature,
    required String details,
    String severity = 'info',
  }) async {
    String title = 'Weather Update';
    
    // Determine severity based on weather condition
    if (condition.toLowerCase().contains('storm') || condition.toLowerCase().contains('heavy rain')) {
      severity = 'error';
      title = 'Severe Weather Alert';
    } else if (condition.toLowerCase().contains('rain') || condition.toLowerCase().contains('cloudy')) {
      severity = 'warning';
      title = 'Weather Advisory';
    } else if (condition.toLowerCase().contains('sunny') || condition.toLowerCase().contains('clear')) {
      severity = 'success';
      title = 'Good Weather Conditions';
    }
    
    await addActivityAlert(
      activity: title,
      entity: 'Weather Monitoring',
      details: '🌤️ $condition - $temperature: $details',
      severity: severity,
    );
  }

  // Alert for system activities
  static Future<void> alertSystemActivity({
    required String activity,
    required String details,
    String severity = 'info',
  }) async {
    await addActivityAlert(
      activity: activity,
      entity: 'System',
      details: details,
      severity: severity,
    );
  }
  
  // Get unread alert count
  static Future<int> getUnreadCount() async {
    try {
      final alerts = await _repo.getAlerts();
      return alerts.where((alert) => !alert.read).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
  
  // Mark alert as read
  static Future<void> markAsRead(String alertId) async {
    try {
      print('🔔 AlertService: Marking alert $alertId as read');
      final alerts = await _repo.getAlerts();
      print('🔔 AlertService: Current alerts: ${alerts.map((a) => '${a.id}:${a.read}').join(', ')}');
      final alertIndex = alerts.indexWhere((alert) => alert.id == alertId);
      
      if (alertIndex != -1) {
        final updatedAlert = alerts[alertIndex].copyWith(read: true);
        alerts[alertIndex] = updatedAlert;
        print('🔔 AlertService: Updated alert: ${updatedAlert.id}:${updatedAlert.read}');
        await _repo.saveAlerts(alerts);
        print('🔔 AlertService: Alert $alertId marked as read successfully');
        // Verify the save worked
        final savedAlerts = await _repo.getAlerts();
        print('🔔 AlertService: Saved alerts: ${savedAlerts.map((a) => '${a.id}:${a.read}').join(', ')}');
      } else {
        print('🔔 AlertService: Alert $alertId not found');
      }
    } catch (e) {
      print('Error marking alert as read: $e');
    }
  }
  
  // Mark all alerts as read
  static Future<void> markAllAsRead() async {
    try {
      print('🔔 AlertService: Marking all alerts as read');
      final alerts = await _repo.getAlerts();
      print('🔔 AlertService: Current alerts: ${alerts.map((a) => '${a.id}:${a.read}').join(', ')}');
      final updatedAlerts = alerts.map((alert) => alert.copyWith(read: true)).toList();
      print('🔔 AlertService: Updated alerts: ${updatedAlerts.map((a) => '${a.id}:${a.read}').join(', ')}');
      await _repo.saveAlerts(updatedAlerts);
      print('🔔 AlertService: All alerts marked as read successfully');
      // Verify the save worked
      final savedAlerts = await _repo.getAlerts();
      print('🔔 AlertService: Saved alerts: ${savedAlerts.map((a) => '${a.id}:${a.read}').join(', ')}');
    } catch (e) {
      print('Error marking all alerts as read: $e');
    }
  }
  
  // Delete a specific alert
  static Future<void> deleteAlert(String alertId) async {
    try {
      print('🔔 AlertService: Deleting alert $alertId');
      final alerts = await _repo.getAlerts();
      print('🔔 AlertService: Current alerts: ${alerts.map((a) => '${a.id}:${a.read}').join(', ')}');
      final updatedAlerts = alerts.where((alert) => alert.id != alertId).toList();
      print('🔔 AlertService: After deletion: ${updatedAlerts.map((a) => '${a.id}:${a.read}').join(', ')}');
      await _repo.saveAlerts(updatedAlerts);
      print('🔔 AlertService: Alert $alertId deleted successfully');
      // Verify the deletion worked
      final savedAlerts = await _repo.getAlerts();
      print('🔔 AlertService: Saved alerts after deletion: ${savedAlerts.map((a) => '${a.id}:${a.read}').join(', ')}');
    } catch (e) {
      print('Error deleting alert: $e');
    }
  }
  
  // Delete all alerts
  static Future<void> deleteAllAlerts() async {
    try {
      print('🔔 AlertService: Deleting all alerts');
      await _repo.saveAlerts([]);
      print('🔔 AlertService: All alerts deleted successfully');
      // Verify the deletion worked
      final savedAlerts = await _repo.getAlerts();
      print('🔔 AlertService: Saved alerts after deletion: ${savedAlerts.length} alerts');
    } catch (e) {
      print('Error deleting all alerts: $e');
    }
  }
  
  // Clear old alerts (older than 30 days)
  static Future<void> clearOldAlerts() async {
    try {
      final alerts = await _repo.getAlerts();
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentAlerts = alerts.where((alert) => alert.timestamp.isAfter(thirtyDaysAgo)).toList();
      await _repo.saveAlerts(recentAlerts);
    } catch (e) {
      print('Error clearing old alerts: $e');
    }
  }
  
  // System notifications
  static Future<void> notifySystemStartup() async {
    await addActivityAlert(
      activity: 'System Started',
      entity: 'System',
      details: '🚀 Hacienda Elizabeth farm management system is now online',
      severity: 'success',
    );
  }
  
  static Future<void> notifyDataSync() async {
    await addActivityAlert(
      activity: 'Data Synchronized',
      entity: 'System',
      details: '🔄 All farm data has been synchronized with the cloud',
      severity: 'info',
    );
  }
  
  static Future<void> notifySystemError(String error) async {
    await addActivityAlert(
      activity: 'System Error',
      entity: 'System',
      details: '❌ $error',
      severity: 'error',
    );
  }
  
  // Insight notifications
  static Future<void> notifyInsightGenerated(String title, String variety) async {
    await addActivityAlert(
      activity: 'New Insight Generated',
      entity: 'Farming Insights',
      details: '🧠 $title for $variety - Check insights dashboard for details',
      severity: 'success',
    );
  }
  
  static Future<void> notifyInsightUpdated(String title) async {
    await addActivityAlert(
      activity: 'Insight Updated',
      entity: 'Farming Insights',
      details: '🧠 Updated $title - New recommendations available',
      severity: 'info',
    );
  }
  
  // Weather notifications
  static Future<void> notifyWeatherUpdate(String condition, String temperature) async {
    String severity = 'info';
    if (condition.toLowerCase().contains('storm') || condition.toLowerCase().contains('heavy rain')) {
      severity = 'error';
    } else if (condition.toLowerCase().contains('rain')) {
      severity = 'warning';
    } else if (condition.toLowerCase().contains('sunny')) {
      severity = 'success';
    }
    
    await addActivityAlert(
      activity: 'Weather Update',
      entity: 'Weather',
      details: '🌤️ $condition - $temperature',
      severity: severity,
    );
  }
  
  // Financial notifications
  static Future<void> notifyHighSpending(double amount) async {
    await addActivityAlert(
      activity: 'High Spending Alert',
      entity: 'Financial',
      details: '💰 Monthly spending is ₱${amount.toStringAsFixed(0)} - Consider reviewing expenses',
      severity: 'warning',
    );
  }
  
  static Future<void> notifyBudgetExceeded(double amount, double budget) async {
    await addActivityAlert(
      activity: 'Budget Exceeded',
      entity: 'Financial',
      details: '💰 Spending ₱${amount.toStringAsFixed(0)} exceeds budget of ₱${budget.toStringAsFixed(0)}',
      severity: 'error',
    );
  }

  // Clear all alerts
  static Future<void> clearAllAlerts() async {
    try {
      print('🧹 Clearing all alerts...');
      await _repo.saveAlerts([]);
      print('✅ All alerts cleared successfully');
    } catch (e) {
      print('❌ Error clearing alerts: $e');
      rethrow;
    }
  }
}
