import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/models/alert.dart';

class AdvancedAnalytics {
  // Comprehensive dashboard metrics
  static Map<String, dynamic> generateDashboardMetrics({
    required List<SugarRecord> sugarRecords,
    required List<InventoryItem> inventoryItems,
    required List<SupplierTransaction> supplierTransactions,
    required List<AlertItem> alerts,
  }) {
    return {
      'overview': _generateOverviewMetrics(sugarRecords, inventoryItems, supplierTransactions, alerts),
      'growth': _analyzeGrowthMetrics(sugarRecords),
      'inventory': _analyzeInventoryMetrics(inventoryItems),
      'suppliers': _analyzeSupplierMetrics(supplierTransactions),
      'alerts': _analyzeAlertMetrics(alerts),
      'trends': _analyzeTrends(sugarRecords, inventoryItems, supplierTransactions),
      'recommendations': _generateRecommendations(sugarRecords, inventoryItems, supplierTransactions, alerts),
    };
  }

  // Overview metrics
  static Map<String, dynamic> _generateOverviewMetrics(
    List<SugarRecord> sugarRecords,
    List<InventoryItem> inventoryItems,
    List<SupplierTransaction> supplierTransactions,
    List<AlertItem> alerts,
  ) {
    final totalSpending = supplierTransactions.fold<double>(0, (sum, tx) => sum + tx.amount);
    final averageGrowth = sugarRecords.isNotEmpty 
        ? sugarRecords.map((r) => r.heightCm).reduce((a, b) => a + b) / sugarRecords.length 
        : 0.0;
    final lowStockItems = inventoryItems.where((item) => item.quantity <= 10).length;
    final unreadAlerts = alerts.where((a) => !a.read).length;

    return {
      'totalSugarRecords': sugarRecords.length,
      'totalInventoryItems': inventoryItems.length,
      'totalSuppliers': supplierTransactions.map((tx) => tx.supplierName).toSet().length,
      'totalSpending': totalSpending,
      'averageGrowth': averageGrowth,
      'lowStockItems': lowStockItems,
      'unreadAlerts': unreadAlerts,
      'systemHealth': _calculateSystemHealth(sugarRecords, inventoryItems, alerts),
    };
  }

  // Growth analysis
  static Map<String, dynamic> _analyzeGrowthMetrics(List<SugarRecord> records) {
    if (records.isEmpty) {
      return {
        'trend': 'stable',
        'averageGrowth': 0.0,
        'growthRate': 0.0,
        'bestVariety': 'N/A',
        'recommendation': 'No growth data available',
      };
    }

    final sortedRecords = List<SugarRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final heights = sortedRecords.map((r) => r.heightCm).toList();
    final averageGrowth = heights.reduce((a, b) => a + b) / heights.length;

    // Calculate growth rate
    double growthRate = 0.0;
    if (heights.length > 1) {
      final firstHeight = heights.first;
      final lastHeight = heights.last;
      growthRate = ((lastHeight - firstHeight) / firstHeight) * 100;
    }

    // Find best performing variety
    final varietyPerformance = <String, double>{};
    for (final record in records) {
      varietyPerformance[record.variety] = 
          (varietyPerformance[record.variety] ?? 0) + record.heightCm;
    }

    final bestVariety = varietyPerformance.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Determine trend
    String trend = 'stable';
    if (growthRate > 5) {
      trend = 'increasing';
    } else if (growthRate < -5) {
      trend = 'decreasing';
    }

    return {
      'trend': trend,
      'averageGrowth': averageGrowth,
      'growthRate': growthRate,
      'bestVariety': bestVariety,
      'totalRecords': records.length,
      'dateRange': {
        'start': sortedRecords.first.date,
        'end': sortedRecords.last.date,
      },
      'recommendation': _getGrowthRecommendation(trend, averageGrowth, growthRate),
    };
  }

  // Inventory analysis
  static Map<String, dynamic> _analyzeInventoryMetrics(List<InventoryItem> items) {
    if (items.isEmpty) {
      return {
        'totalItems': 0,
        'lowStockItems': 0,
        'totalValue': 0.0,
        'recommendation': 'No inventory data available',
      };
    }

    final lowStockItems = items.where((item) => item.quantity <= 10).toList();
    final totalValue = items.fold<double>(0, (sum, item) => sum + (item.quantity * 100)); // Assuming 100 per unit

    // Category analysis
    final categories = <String, int>{};
    for (final item in items) {
      categories[item.category] = (categories[item.category] ?? 0) + 1;
    }

    // Most common category
    final mostCommonCategory = categories.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'totalItems': items.length,
      'lowStockItems': lowStockItems.length,
      'totalValue': totalValue,
      'lowStockPercentage': (lowStockItems.length / items.length) * 100,
      'categories': categories,
      'mostCommonCategory': mostCommonCategory,
      'recommendation': _getInventoryRecommendation(lowStockItems.length, items.length),
    };
  }

  // Supplier analysis
  static Map<String, dynamic> _analyzeSupplierMetrics(List<SupplierTransaction> transactions) {
    if (transactions.isEmpty) {
      return {
        'totalTransactions': 0,
        'totalSpent': 0.0,
        'topSuppliers': [],
        'recommendation': 'No supplier data available',
      };
    }

    final totalSpent = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
    final supplierSpending = <String, double>{};
    final supplierCount = <String, int>{};

    for (final tx in transactions) {
      supplierSpending[tx.supplierName] = 
          (supplierSpending[tx.supplierName] ?? 0) + tx.amount;
      supplierCount[tx.supplierName] = 
          (supplierCount[tx.supplierName] ?? 0) + 1;
    }

    final sortedSuppliers = supplierSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topSuppliers = sortedSuppliers.take(5).map((e) => {
      'name': e.key,
      'amount': e.value,
      'percentage': (e.value / totalSpent) * 100,
      'transactions': supplierCount[e.key] ?? 0,
    }).toList();

    return {
      'totalTransactions': transactions.length,
      'totalSpent': totalSpent,
      'averageTransaction': totalSpent / transactions.length,
      'topSuppliers': topSuppliers,
      'supplierCount': supplierSpending.length,
      'recommendation': _getSupplierRecommendation(sortedSuppliers.length, totalSpent),
    };
  }

  // Alert analysis
  static Map<String, dynamic> _analyzeAlertMetrics(List<AlertItem> alerts) {
    if (alerts.isEmpty) {
      return {
        'totalAlerts': 0,
        'unreadAlerts': 0,
        'severityBreakdown': {},
        'recommendation': 'No alerts available',
      };
    }

    final unreadAlerts = alerts.where((a) => !a.read).length;
    final severityBreakdown = <String, int>{};
    final recentAlerts = alerts.where((a) => 
        DateTime.now().difference(a.timestamp).inDays <= 7).length;

    for (final alert in alerts) {
      severityBreakdown[alert.severity] = 
          (severityBreakdown[alert.severity] ?? 0) + 1;
    }

    return {
      'totalAlerts': alerts.length,
      'unreadAlerts': unreadAlerts,
      'recentAlerts': recentAlerts,
      'severityBreakdown': severityBreakdown,
      'recommendation': _getAlertRecommendation(unreadAlerts, alerts.length),
    };
  }

  // Trend analysis
  static Map<String, dynamic> _analyzeTrends(
    List<SugarRecord> sugarRecords,
    List<InventoryItem> inventoryItems,
    List<SupplierTransaction> supplierTransactions,
  ) {
    final monthlyGrowth = <String, double>{};
    final monthlySpending = <String, double>{};

    // Analyze monthly growth
    for (final record in sugarRecords) {
      final month = record.date.substring(0, 7); // YYYY-MM
      monthlyGrowth[month] = (monthlyGrowth[month] ?? 0) + record.heightCm;
    }

    // Analyze monthly spending
    for (final tx in supplierTransactions) {
      final month = tx.date.substring(0, 7); // YYYY-MM
      monthlySpending[month] = (monthlySpending[month] ?? 0) + tx.amount;
    }

    return {
      'monthlyGrowth': monthlyGrowth,
      'monthlySpending': monthlySpending,
      'growthTrend': _calculateTrend(monthlyGrowth.values.toList()),
      'spendingTrend': _calculateTrend(monthlySpending.values.toList()),
    };
  }

  // Generate recommendations
  static List<String> _generateRecommendations(
    List<SugarRecord> sugarRecords,
    List<InventoryItem> inventoryItems,
    List<SupplierTransaction> supplierTransactions,
    List<AlertItem> alerts,
  ) {
    final recommendations = <String>[];

    // Growth recommendations
    if (sugarRecords.isNotEmpty) {
      final avgGrowth = sugarRecords.map((r) => r.heightCm).reduce((a, b) => a + b) / sugarRecords.length;
      if (avgGrowth < 80) {
        recommendations.add('Consider improving fertilization practices - average growth is below optimal');
      }
    }

    // Inventory recommendations
    final lowStockItems = inventoryItems.where((item) => item.quantity <= 10).length;
    if (lowStockItems > inventoryItems.length * 0.3) {
      recommendations.add('High number of low stock items - consider bulk ordering');
    }

    // Alert recommendations
    final unreadAlerts = alerts.where((a) => !a.read).length;
    if (unreadAlerts > 5) {
      recommendations.add('Multiple unread alerts require attention');
    }

    // Supplier recommendations
    if (supplierTransactions.isNotEmpty) {
      final totalSpent = supplierTransactions.fold<double>(0, (sum, tx) => sum + tx.amount);
      if (totalSpent > 100000) {
        recommendations.add('High spending detected - review supplier contracts for better rates');
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('System is running smoothly - continue current practices');
    }

    return recommendations;
  }

  // Helper methods
  static double _calculateSystemHealth(
    List<SugarRecord> sugarRecords,
    List<InventoryItem> inventoryItems,
    List<AlertItem> alerts,
  ) {
    int healthScore = 100;
    
    // Deduct points for issues
    if (sugarRecords.isNotEmpty) {
      final avgGrowth = sugarRecords.map((r) => r.heightCm).reduce((a, b) => a + b) / sugarRecords.length;
      if (avgGrowth < 80) healthScore -= 15;
    }
    
    final lowStockPercentage = inventoryItems.isNotEmpty 
        ? (inventoryItems.where((item) => item.quantity <= 10).length / inventoryItems.length) * 100
        : 0;
    if (lowStockPercentage > 30) healthScore -= 20;
    
    final unreadAlerts = alerts.where((a) => !a.read).length;
    if (unreadAlerts > 5) healthScore -= 10;
    
    return healthScore.clamp(0, 100).toDouble();
  }

  static String _getGrowthRecommendation(String trend, double averageGrowth, double growthRate) {
    if (trend == 'increasing') {
      return 'Excellent growth trend! Maintain current practices.';
    } else if (trend == 'decreasing') {
      return 'Growth is declining. Review soil conditions and fertilization.';
    } else {
      return 'Stable growth pattern. Monitor for seasonal changes.';
    }
  }

  static String _getInventoryRecommendation(int lowStockItems, int totalItems) {
    final percentage = totalItems > 0 ? (lowStockItems / totalItems) * 100 : 0;
    if (percentage > 30) {
      return 'High number of low stock items. Plan bulk ordering.';
    } else if (percentage > 10) {
      return 'Some items running low. Schedule restocking.';
    } else {
      return 'Inventory levels are healthy.';
    }
  }

  static String _getSupplierRecommendation(int supplierCount, double totalSpent) {
    if (supplierCount < 2) {
      return 'Consider diversifying suppliers for better pricing.';
    } else if (totalSpent > 100000) {
      return 'High spending - negotiate better rates with suppliers.';
    } else {
      return 'Supplier relationships are well managed.';
    }
  }

  static String _getAlertRecommendation(int unreadAlerts, int totalAlerts) {
    if (unreadAlerts > 5) {
      return 'Many unread alerts. Review urgent issues.';
    } else if (unreadAlerts > 0) {
      return 'Some alerts need attention.';
    } else {
      return 'All alerts are up to date.';
    }
  }

  static String _calculateTrend(List<double> values) {
    if (values.length < 2) return 'stable';
    
    final firstHalf = values.take(values.length ~/ 2).reduce((a, b) => a + b) / (values.length ~/ 2);
    final secondHalf = values.skip(values.length ~/ 2).reduce((a, b) => a + b) / (values.length - values.length ~/ 2);
    
    final change = ((secondHalf - firstHalf) / firstHalf) * 100;
    
    if (change > 5) return 'increasing';
    if (change < -5) return 'decreasing';
    return 'stable';
  }
}
