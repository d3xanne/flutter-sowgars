import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/models/alert.dart';
import 'package:sample/models/realtime_event.dart';
import 'package:sample/config/app_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static bool _ready = false;
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (!_ready || _client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static bool get isReady => _ready;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _ready = true;
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  // Sugar Records
  static Future<List<SugarRecord>> getSugarRecords() async {
    try {
      if (!_ready || _client == null) {
        throw Exception('Supabase not initialized');
      }
      final response = await client!
          .from('sugar_records')
          .select()
          .order('created_at', ascending: false);

      if (response == null) return [];
      
      return (response as List)
          .map((json) {
            try {
              return SugarRecord.fromMap(json as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing sugar record: $e');
              return null;
            }
          })
          .whereType<SugarRecord>()
          .toList();
    } catch (e) {
      print('Error fetching sugar records: $e');
      return [];
    }
  }

  static Future<void> saveSugarRecords(List<SugarRecord> records) async {
    try {
      if (!_ready || _client == null) {
        throw Exception('Supabase not initialized');
      }
      if (records.isEmpty) {
        print('No records to save');
        return;
      }
      final recordsMap = records.map((record) => record.toMap()).toList();
      
      // Use upsert (insert or update) instead of delete + insert
      await _client!.from('sugar_records').upsert(recordsMap);
      
      print('✅ Sugar records saved to Supabase');
    } catch (e) {
      print('❌ Error saving sugar records: $e');
      rethrow;
    }
  }

  static Future<void> deleteSugarRecord(String id) async {
    try {
      await client.from('sugar_records').delete().eq('id', id);
      print('✅ Sugar record deleted from Supabase');
    } catch (e) {
      print('❌ Error deleting sugar record: $e');
      rethrow;
    }
  }

  // Inventory Items
  static Future<List<InventoryItem>> getInventoryItems() async {
    try {
      final response = await client
          .from('inventory_items')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => InventoryItem.fromMap(json))
          .toList();
    } catch (e) {
      print('Error fetching inventory items: $e');
      return [];
    }
  }

  static Future<void> saveInventoryItems(List<InventoryItem> items) async {
    try {
      final itemsMap = items.map((item) => item.toMap()).toList();
      
      await client.from('inventory_items').upsert(itemsMap);
      
      print('✅ Inventory items saved to Supabase');
    } catch (e) {
      print('❌ Error saving inventory items: $e');
      rethrow;
    }
  }

  static Future<void> deleteInventoryItem(String id) async {
    try {
      await client.from('inventory_items').delete().eq('id', id);
      print('✅ Inventory item deleted from Supabase');
    } catch (e) {
      print('❌ Error deleting inventory item: $e');
      rethrow;
    }
  }

  // Supplier Transactions
  static Future<List<SupplierTransaction>> getSupplierTransactions() async {
    try {
      final response = await client
          .from('supplier_transactions')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SupplierTransaction.fromMap(json))
          .toList();
    } catch (e) {
      print('Error fetching supplier transactions: $e');
      return [];
    }
  }

  static Future<void> saveSupplierTransactions(List<SupplierTransaction> transactions) async {
    try {
      // Create a simplified map without archived fields for now
      final transactionsMap = transactions.map((tx) {
        final map = tx.toMap();
        // Remove archived fields if they exist to avoid schema errors
        map.remove('archived');
        map.remove('archived_at');
        return map;
      }).toList();
      
      await client.from('supplier_transactions').upsert(transactionsMap);
      
      print('✅ Supplier transactions saved to Supabase');
    } catch (e) {
      print('❌ Error saving supplier transactions: $e');
      rethrow;
    }
  }

  static Future<void> deleteSupplierTransaction(String id) async {
    try {
      await client.from('supplier_transactions').delete().eq('id', id);
      print('✅ Supplier transaction deleted from Supabase');
    } catch (e) {
      print('❌ Error deleting supplier transaction: $e');
      rethrow;
    }
  }

  // Alerts
  static Future<List<AlertItem>> getAlerts() async {
    try {
      final response = await client
          .from('alerts')
          .select()
          .order('timestamp', ascending: false);

      return (response as List)
          .map((json) => AlertItem.fromMap(json))
          .toList();
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }

  static Future<void> addAlert(AlertItem alert) async {
    try {
      await client.from('alerts').insert(alert.toMap());
      print('✅ Alert added to Supabase');
    } catch (e) {
      print('❌ Error adding alert: $e');
      rethrow;
    }
  }

  // Realtime Events
  static Future<List<RealtimeEvent>> getEvents() async {
    try {
      final response = await client
          .from('realtime_events')
          .select()
          .order('timestamp', ascending: false);

      return (response as List)
          .map((json) => RealtimeEvent.fromMap(json))
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  static Future<void> addEvent(RealtimeEvent event) async {
    try {
      await client.from('realtime_events').insert(event.toMap());
      print('✅ Event added to Supabase');
    } catch (e) {
      print('❌ Error adding event: $e');
      rethrow;
    }
  }

  // Real-time subscriptions
  static RealtimeChannel subscribeToSugarRecords(Function(List<SugarRecord>) callback) {
    return client
        .channel('sugar_records_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'sugar_records',
          callback: (payload) async {
            final records = await getSugarRecords();
            callback(records);
          },
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToInventoryItems(Function(List<InventoryItem>) callback) {
    return client
        .channel('inventory_items_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'inventory_items',
          callback: (payload) async {
            final items = await getInventoryItems();
            callback(items);
          },
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToSupplierTransactions(Function(List<SupplierTransaction>) callback) {
    return client
        .channel('supplier_transactions_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'supplier_transactions',
          callback: (payload) async {
            final transactions = await getSupplierTransactions();
            callback(transactions);
          },
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToAlerts(Function(List<AlertItem>) callback) {
    return client
        .channel('alerts_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'alerts',
          callback: (payload) async {
            final alerts = await getAlerts();
            callback(alerts);
          },
        )
        .subscribe();
  }

  // Test connection
  static Future<bool> testConnection() async {
    try {
      await client.from('sugar_records').select().limit(1);
      return true;
    } catch (e) {
      print('❌ Supabase connection test failed: $e');
      return false;
    }
  }

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    try {
      await client.from('sugar_records').delete();
      await client.from('inventory_items').delete();
      await client.from('supplier_transactions').delete();
      await client.from('alerts').delete();
      await client.from('realtime_events').delete();
      print('✅ All data cleared from Supabase');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }

  // Farming Insights
  static Future<void> saveFarmingInsights(List<dynamic> insights) async {
    try {
      final insightsMap = insights.map((insight) => insight.toMap()).toList();
      await client.from('farming_insights').upsert(insightsMap);
      print('✅ Farming insights saved to Supabase');
    } catch (e) {
      print('❌ Error saving farming insights: $e');
      rethrow;
    }
  }

  // Alerts - Save all alerts
  static Future<void> saveAlerts(List<AlertItem> alerts) async {
    try {
      final alertsMap = alerts.map((alert) => alert.toMap()).toList();
      await client.from('alerts').upsert(alertsMap);
      print('✅ Alerts saved to Supabase');
    } catch (e) {
      print('❌ Error saving alerts: $e');
      rethrow;
    }
  }
}
