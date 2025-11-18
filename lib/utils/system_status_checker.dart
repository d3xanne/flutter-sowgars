import 'package:flutter/material.dart';
import 'package:sample/services/supabase_service.dart';
import 'package:sample/services/local_repository.dart';

class SystemStatusChecker {
  static Future<Map<String, dynamic>> checkSystemStatus() async {
    final status = <String, dynamic>{};
    
    // Check Supabase connection
    try {
      final isConnected = await SupabaseService.testConnection();
      status['supabase_connected'] = isConnected;
      status['supabase_message'] = isConnected 
          ? '✅ Connected to Supabase' 
          : '❌ Supabase connection failed';
    } catch (e) {
      status['supabase_connected'] = false;
      status['supabase_message'] = '❌ Supabase error: $e';
    }
    
    // Check local repository
    try {
      final repository = LocalRepository.instance;
      final sugarRecords = await repository.getSugarRecords();
      final inventoryItems = await repository.getInventoryItems();
      final supplierTransactions = await repository.getSupplierTransactions();
      final alerts = await repository.getAlerts();
      
      status['local_repository'] = true;
      status['data_counts'] = {
        'sugar_records': sugarRecords.length,
        'inventory_items': inventoryItems.length,
        'supplier_transactions': supplierTransactions.length,
        'alerts': alerts.length,
      };
      status['local_message'] = '✅ Local repository working';
    } catch (e) {
      status['local_repository'] = false;
      status['local_message'] = '❌ Local repository error: $e';
    }
    
    // Check real-time subscriptions
    try {
      final repository = LocalRepository.instance;
      await repository.initializeRealtimeSubscriptions();
      status['realtime_subscriptions'] = true;
      status['realtime_message'] = '✅ Real-time subscriptions active';
    } catch (e) {
      status['realtime_subscriptions'] = false;
      status['realtime_message'] = '❌ Real-time subscriptions error: $e';
    }
    
    return status;
  }
  
  static Widget buildStatusWidget(Map<String, dynamic> status) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              'Supabase Connection',
              status['supabase_message'] ?? 'Unknown',
              status['supabase_connected'] == true,
            ),
            const SizedBox(height: 8),
            _buildStatusItem(
              'Local Repository',
              status['local_message'] ?? 'Unknown',
              status['local_repository'] == true,
            ),
            const SizedBox(height: 8),
            _buildStatusItem(
              'Real-time Sync',
              status['realtime_message'] ?? 'Unknown',
              status['realtime_subscriptions'] == true,
            ),
            if (status['data_counts'] != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Data Counts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...status['data_counts'].entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  static Widget _buildStatusItem(String title, String message, bool isSuccess) {
    return Row(
      children: [
        Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
