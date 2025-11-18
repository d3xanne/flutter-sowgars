import 'dart:async';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/alert_service.dart';

/// Consolidated service to reduce redundancy across multiple services
class ConsolidatedService {
  static final LocalRepository _repo = LocalRepository.instance;
  static final Map<String, StreamSubscription> _subscriptions = {};
  static final Map<String, Timer> _timers = {};
  
  // Cache for frequently accessed data
  static final Map<String, dynamic> _cache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// Initialize all services with optimized subscriptions
  static Future<void> initialize() async {
    await _initializeOptimizedSubscriptions();
    await _startPeriodicTasks();
  }

  /// Initialize optimized subscriptions to reduce redundancy
  static Future<void> _initializeOptimizedSubscriptions() async {
    // Single subscription for all data changes
    _subscriptions['data_changes'] = _repo.sugarRecordsStream.listen((_) {
      _clearCache('sugar_records');
    });
    
    _subscriptions['inventory_changes'] = _repo.inventoryItemsStream.listen((_) {
      _clearCache('inventory_items');
    });
    
    _subscriptions['supplier_changes'] = _repo.supplierTransactionsStream.listen((_) {
      _clearCache('supplier_transactions');
    });
    
    _subscriptions['alert_changes'] = _repo.alertsStream.listen((_) {
      _clearCache('alerts');
    });
  }

  /// Start periodic tasks with optimized intervals
  static Future<void> _startPeriodicTasks() async {
    // Check low stock every 30 minutes instead of on every change
    _timers['low_stock_check'] = Timer.periodic(
      const Duration(minutes: 30),
      (_) => AlertService.checkLowStock(),
    );
    
    // Clean up old alerts every hour
    _timers['alert_cleanup'] = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cleanupOldAlerts(),
    );
  }

  /// Get cached data or fetch if not cached
  static Future<T> getCachedData<T>(
    String key,
    Future<T> Function() fetcher,
  ) async {
    if (_isCacheValid(key)) {
      return _cache[key] as T;
    }
    
    final data = await fetcher();
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    return data;
  }

  /// Check if cache is still valid
  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    
    final age = DateTime.now().difference(_cacheTimestamps[key]!);
    return age < _cacheExpiry;
  }

  /// Clear specific cache entry
  static void _clearCache(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// Clean up old alerts (older than 7 days)
  static Future<void> _cleanupOldAlerts() async {
    try {
      final alerts = await _repo.getAlerts();
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      final recentAlerts = alerts.where((alert) => 
        alert.timestamp.isAfter(cutoffDate)
      ).toList();
      
      if (recentAlerts.length != alerts.length) {
        await _repo.saveAlerts(recentAlerts);
        print('🧹 Cleaned up ${alerts.length - recentAlerts.length} old alerts');
      }
    } catch (e) {
      print('Error cleaning up alerts: $e');
    }
  }

  /// Dispose all resources
  static void dispose() {
    // Cancel all subscriptions
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    // Cancel all timers
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    
    // Clear cache
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Get system health status
  static Map<String, dynamic> getSystemHealth() {
    return {
      'active_subscriptions': _subscriptions.length,
      'active_timers': _timers.length,
      'cached_items': _cache.length,
      'memory_usage': _cache.values.length,
    };
  }
}
