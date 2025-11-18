import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/models/alert.dart';

class AnalyticsService {
  // Growth trend analysis
  static Map<String, dynamic> analyzeGrowthTrend(List<SugarRecord> records) {
    if (records.isEmpty) {
      return {
        'trend': 'stable',
        'averageGrowth': 0.0,
        'growthRate': 0.0,
        'recommendation': 'No data available for analysis',
      };
    }

    // Sort by date
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

    // Determine trend
    String trend = 'stable';
    if (growthRate > 5) {
      trend = 'increasing';
    } else if (growthRate < -5) {
      trend = 'decreasing';
    }

    // Generate recommendation
    String recommendation = _generateGrowthRecommendation(trend, averageGrowth, growthRate);

    return {
      'trend': trend,
      'averageGrowth': averageGrowth,
      'growthRate': growthRate,
      'recommendation': recommendation,
      'totalRecords': records.length,
      'dateRange': {
        'start': sortedRecords.first.date,
        'end': sortedRecords.last.date,
      },
    };
  }

  // Inventory analysis
  static Map<String, dynamic> analyzeInventory(List<InventoryItem> items) {
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

    return {
      'totalItems': items.length,
      'lowStockItems': lowStockItems.length,
      'totalValue': totalValue,
      'lowStockPercentage': (lowStockItems.length / items.length) * 100,
      'recommendation': _generateInventoryRecommendation(lowStockItems.length, items.length),
      'categories': _analyzeInventoryCategories(items),
    };
  }

  // Supplier analysis
  static Map<String, dynamic> analyzeSuppliers(List<SupplierTransaction> transactions) {
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

    for (final tx in transactions) {
      supplierSpending[tx.supplierName] = 
          (supplierSpending[tx.supplierName] ?? 0) + tx.amount;
    }

    final sortedSuppliers = supplierSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalTransactions': transactions.length,
      'totalSpent': totalSpent,
      'averageTransaction': totalSpent / transactions.length,
      'topSuppliers': sortedSuppliers.take(5).map((e) => {
        'name': e.key,
        'amount': e.value,
        'percentage': (e.value / totalSpent) * 100,
      }).toList(),
      'recommendation': _generateSupplierRecommendation(sortedSuppliers.length, totalSpent),
    };
  }

  // Alert analysis
  static Map<String, dynamic> analyzeAlerts(List<AlertItem> alerts) {
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

    for (final alert in alerts) {
      severityBreakdown[alert.severity] = 
          (severityBreakdown[alert.severity] ?? 0) + 1;
    }

    return {
      'totalAlerts': alerts.length,
      'unreadAlerts': unreadAlerts,
      'severityBreakdown': severityBreakdown,
      'recommendation': _generateAlertRecommendation(unreadAlerts, alerts.length),
    };
  }

  // Generate comprehensive system health report
  static Map<String, dynamic> generateSystemHealthReport({
    required List<SugarRecord> sugarRecords,
    required List<InventoryItem> inventoryItems,
    required List<SupplierTransaction> supplierTransactions,
    required List<AlertItem> alerts,
  }) {
    final growthAnalysis = analyzeGrowthTrend(sugarRecords);
    final inventoryAnalysis = analyzeInventory(inventoryItems);
    final supplierAnalysis = analyzeSuppliers(supplierTransactions);
    final alertAnalysis = analyzeAlerts(alerts);

    // Calculate overall health score (0-100)
    int healthScore = 100;
    
    // Deduct points for issues
    if (growthAnalysis['trend'] == 'decreasing') healthScore -= 20;
    if (inventoryAnalysis['lowStockPercentage'] > 30) healthScore -= 15;
    if (alertAnalysis['unreadAlerts'] > 5) healthScore -= 10;
    if (supplierAnalysis['totalTransactions'] == 0) healthScore -= 5;

    String healthStatus = 'excellent';
    if (healthScore < 70) healthStatus = 'needs_attention';
    if (healthScore < 50) healthStatus = 'critical';

    return {
      'healthScore': healthScore,
      'healthStatus': healthStatus,
      'growthAnalysis': growthAnalysis,
      'inventoryAnalysis': inventoryAnalysis,
      'supplierAnalysis': supplierAnalysis,
      'alertAnalysis': alertAnalysis,
      'recommendations': _generateOverallRecommendations(
        growthAnalysis,
        inventoryAnalysis,
        supplierAnalysis,
        alertAnalysis,
      ),
    };
  }

  // Helper methods
  static String _generateGrowthRecommendation(String trend, double averageGrowth, double growthRate) {
    if (trend == 'increasing') {
      return 'Excellent growth! Consider maintaining current practices.';
    } else if (trend == 'decreasing') {
      return 'Growth is declining. Review fertilization and care practices.';
    } else {
      return 'Stable growth. Monitor for any changes in conditions.';
    }
  }

  static String _generateInventoryRecommendation(int lowStockItems, int totalItems) {
    final percentage = (lowStockItems / totalItems) * 100;
    if (percentage > 30) {
      return 'High number of low stock items. Consider bulk ordering.';
    } else if (percentage > 10) {
      return 'Some items are running low. Plan restocking.';
    } else {
      return 'Inventory levels are healthy.';
    }
  }

  static String _generateSupplierRecommendation(int supplierCount, double totalSpent) {
    if (supplierCount < 2) {
      return 'Consider diversifying suppliers for better pricing.';
    } else if (totalSpent > 100000) {
      return 'High spending detected. Review supplier contracts.';
    } else {
      return 'Supplier relationships are well managed.';
    }
  }

  static String _generateAlertRecommendation(int unreadAlerts, int totalAlerts) {
    if (unreadAlerts > 5) {
      return 'Many unread alerts. Review and address urgent issues.';
    } else if (unreadAlerts > 0) {
      return 'Some alerts need attention.';
    } else {
      return 'All alerts are up to date.';
    }
  }

  static List<String> _generateOverallRecommendations(
    Map<String, dynamic> growth,
    Map<String, dynamic> inventory,
    Map<String, dynamic> suppliers,
    Map<String, dynamic> alerts,
  ) {
    final recommendations = <String>[];

    if (growth['trend'] == 'decreasing') {
      recommendations.add('Review sugarcane growth practices and soil conditions');
    }

    if (inventory['lowStockPercentage'] > 20) {
      recommendations.add('Restock low inventory items to avoid shortages');
    }

    if (alerts['unreadAlerts'] > 3) {
      recommendations.add('Address pending alerts to maintain system health');
    }

    if (suppliers['totalTransactions'] == 0) {
      recommendations.add('Start recording supplier transactions for better tracking');
    }

    if (recommendations.isEmpty) {
      recommendations.add('System is running smoothly. Continue current practices.');
    }

    return recommendations;
  }

  static Map<String, int> _analyzeInventoryCategories(List<InventoryItem> items) {
    final categories = <String, int>{};
    for (final item in items) {
      categories[item.category] = (categories[item.category] ?? 0) + 1;
    }
    return categories;
  }
}
