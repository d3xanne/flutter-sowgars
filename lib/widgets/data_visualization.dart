import 'package:flutter/material.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/models/alert.dart';
import 'package:sample/utils/number_converter.dart';

class DataVisualizationWidgets {
  // Growth trend chart
  static Widget buildGrowthTrendChart(List<SugarRecord> records) {
    if (records.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No growth data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Sort records by date
    final sortedRecords = List<SugarRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final heights = sortedRecords.map((r) => NumberConverter.intToDouble(r.heightCm)).toList();
    final maxHeight = heights.reduce((a, b) => a > b ? a : b);
    final minHeight = heights.reduce((a, b) => a < b ? a : b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: GrowthChartPainter(
                heights: heights,
                maxHeight: maxHeight,
                minHeight: minHeight,
                dates: sortedRecords.map((r) => r.date).toList(),
              ),
              size: const Size(double.infinity, double.infinity),
            ),
          ),
        ],
      ),
    );
  }

  // Inventory status chart
  static Widget buildInventoryStatusChart(List<InventoryItem> items) {
    if (items.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No inventory data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final lowStockItems = items.where((item) => item.quantity <= 10).length;
    final normalStockItems = items.length - lowStockItems;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatusBar(
                    'Normal Stock',
                    normalStockItems,
                    items.length,
                    const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusBar(
                    'Low Stock',
                    lowStockItems,
                    items.length,
                    const Color(0xFFFF5722),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Supplier spending chart
  static Widget buildSupplierSpendingChart(List<SupplierTransaction> transactions) {
    if (transactions.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No supplier data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final supplierSpending = <String, double>{};
    for (final tx in transactions) {
      supplierSpending[tx.supplierName] = 
          (supplierSpending[tx.supplierName] ?? 0) + tx.amount;
    }

    final sortedSuppliers = supplierSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Suppliers by Spending',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: sortedSuppliers.take(5).length,
              itemBuilder: (context, index) {
                final supplier = sortedSuppliers[index];
                final percentage = (supplier.value / sortedSuppliers.first.value) * 100;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          supplier.key,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₱${supplier.value.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Alert severity distribution
  static Widget buildAlertDistributionChart(List<AlertItem> alerts) {
    if (alerts.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No alerts available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final severityCount = <String, int>{};
    for (final alert in alerts) {
      severityCount[alert.severity] = (severityCount[alert.severity] ?? 0) + 1;
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alert Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildSeverityIndicator(
                    'High',
                    severityCount['high'] ?? 0,
                    alerts.length,
                    const Color(0xFFF44336),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSeverityIndicator(
                    'Medium',
                    severityCount['medium'] ?? 0,
                    alerts.length,
                    const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSeverityIndicator(
                    'Low',
                    severityCount['low'] ?? 0,
                    alerts.length,
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  static Widget _buildStatusBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value items',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  static Widget _buildSeverityIndicator(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) : 0.0;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          '${(percentage * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// Custom painter for growth chart
class GrowthChartPainter extends CustomPainter {
  final List<double> heights;
  final double maxHeight;
  final double minHeight;
  final List<String> dates;

  GrowthChartPainter({
    required this.heights,
    required this.maxHeight,
    required this.minHeight,
    required this.dates,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (heights.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (heights.length - 1);
    final heightRange = maxHeight - minHeight;
    final stepY = heightRange > 0 ? size.height / heightRange : 0;

    for (int i = 0; i < heights.length; i++) {
      final x = i * stepX;
      final y = size.height - ((heights[i] - minHeight) * stepY);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < heights.length; i++) {
      final x = i * stepX;
      final y = size.height - ((heights[i] - minHeight) * stepY);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
