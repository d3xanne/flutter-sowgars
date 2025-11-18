import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/models/farming_insight.dart';
import 'package:sample/services/local_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sample/constants/app_icons.dart';
import 'package:sample/widgets/responsive_builder.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with TickerProviderStateMixin {
  final LocalRepository _repo = LocalRepository.instance;
  List<SugarRecord> _sugar = [];
  List<InventoryItem> _inventory = [];
  List<SupplierTransaction> _tx = [];
  List<FarmingInsight> _insights = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _load();
    _setupStreamListeners();
    _animationController.forward();
  }

  void _setupStreamListeners() {
    _repo.sugarRecordsStream.listen((e) {
      if (mounted) setState(() => _sugar = e);
    });
    _repo.inventoryItemsStream.listen((e) {
      if (mounted) setState(() => _inventory = e);
    });
    _repo.supplierTransactionsStream.listen((e) {
      if (mounted) setState(() => _tx = e);
    });
    _repo.farmingInsightsStream.listen((e) {
      if (mounted) setState(() => _insights = e);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final s = await _repo.getSugarRecords();
    final i = await _repo.getInventoryItems();
    final t = await _repo.getSupplierTransactions();
    final insights = await _repo.getFarmingInsights();
    if (mounted) {
      setState(() {
        _sugar = s;
        _inventory = i;
        _tx = t;
        _insights = insights;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Analytics & Insights'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: ResponsiveUtils.getPadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getMaxContentWidth(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 24)),
                _buildGrowthAnalytics(),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 24)),
                _buildFinancialInsights(),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 24)),
                _buildFarmingInsights(),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 24)),
                _buildInventoryStatus(),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 24)),
                _buildRecentActivity(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, double> _groupMonthlySpend(List<SupplierTransaction> tx) {
    final map = <String, double>{};
    for (final t in tx) {
      DateTime? d;
      try {
        d = DateTime.parse(t.date);
      } catch (_) {
        d = DateTime.now();
      }
      final key = DateFormat('yyyy-MM').format(d);
      map[key] = (map[key] ?? 0) + t.amount;
    }
    final sortedKeys = map.keys.toList()..sort();
    final sorted = <String, double>{};
    for (final k in sortedKeys) {
      sorted[k] = map[k]!;
    }
    return sorted;
  }

  // New comprehensive analytics methods
  Widget _buildOverviewCards() {
    final totalRecords = _sugar.length;
    final avgHeight = _sugar.isEmpty ? 0.0 : _sugar.fold(0, (sum, record) => sum + record.heightCm) / _sugar.length;
    final lowStockItems = _inventory.where((item) => item.quantity <= 10).length;
    final totalSpend = _tx.fold(0.0, (sum, tx) => sum + tx.amount);
    final totalInsights = _insights.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Farm Overview',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
                   _buildMetricCard('Total Records', totalRecords.toString(), AppIcons.agriculture, AppColors.success),
                   _buildMetricCard('Avg Height', '${avgHeight.toStringAsFixed(1)} cm', AppIcons.height, AppColors.info),
                   _buildMetricCard('Low Stock', lowStockItems.toString(), AppIcons.warning, AppColors.warning),
                   _buildMetricCard('Total Spend', '₱${totalSpend.toStringAsFixed(0)}', AppIcons.money, AppColors.error),
                   _buildMetricCard('Insights', totalInsights.toString(), AppIcons.psychology, AppColors.weather),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthAnalytics() {
         if (_sugar.isEmpty) {
           return _buildEmptyState('No growth data available', AppIcons.agriculture);
         }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Growth Analytics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: _sugar.asMap().entries.map((e) => 
                    FlSpot(e.key.toDouble(), e.value.heightCm.toDouble())
                  ).toList(),
                  isCurved: true,
                  color: AppColors.success,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialInsights() {
         if (_tx.isEmpty) {
           return _buildEmptyState('No financial data available', AppIcons.money);
         }

    final monthlySpend = _groupMonthlySpend(_tx);
    final totalSpend = _tx.fold(0.0, (sum, tx) => sum + tx.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Insights',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Spend:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('₱${totalSpend.toStringAsFixed(0)}', 
                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 16),
              ...monthlySpend.entries.map((e) => _buildSpendBar(e.key, e.value, totalSpend)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFarmingInsights() {
         if (_insights.isEmpty) {
           return _buildEmptyState('No farming insights available', AppIcons.psychology);
         }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Farming Insights',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 16),
        ..._insights.take(3).map((insight) => _buildInsightCard(insight)),
      ],
    );
  }

  Widget _buildInsightCard(FarmingInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Variety: ${insight.variety}'),
          Text('Soil: ${insight.soilType} • Climate: ${insight.climateZone}'),
          Text('Expected Income: ₱${insight.estimatedIncome.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _buildInventoryStatus() {
         if (_inventory.isEmpty) {
           return _buildEmptyState('No inventory data available', AppIcons.inventory);
         }

    final lowStockItems = _inventory.where((item) => item.quantity <= 10).toList();
    final categories = _inventory.map((item) => item.category).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Status',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Items: ${_inventory.length}'),
                  Text('Low Stock: ${lowStockItems.length}', 
                       style: TextStyle(color: lowStockItems.isNotEmpty ? Colors.red : Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: categories.map((category) => Chip(
                  label: Text(category),
                  backgroundColor: Colors.grey[200],
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
                     ..._sugar.take(5).map((record) => ListTile(
                       leading: const Icon(AppIcons.agriculture, color: AppColors.success),
                       title: Text('${record.variety} - ${record.heightCm}cm'),
                       subtitle: Text('Date: ${record.date} • Soil: ${record.soilTest}'),
                       dense: true,
                     )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendBar(String month, double amount, double total) {
    final percentage = total > 0 ? (amount / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(month)),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[300]!),
            ),
          ),
          const SizedBox(width: 8),
          Text('₱${amount.toStringAsFixed(0)}'),
        ],
      ),
    );
  }
}
