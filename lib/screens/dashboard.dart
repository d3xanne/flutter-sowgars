import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/activity_tracker_service.dart';
import 'package:sample/widgets/animated_card.dart';
import 'package:sample/widgets/data_visualization.dart';
import 'package:sample/services/advanced_analytics.dart';
import 'package:sample/widgets/data_export_widget.dart';
import 'package:sample/widgets/data_filter_widget.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/models/alert.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final LocalRepository _repo = LocalRepository.instance;
  final ActivityTrackerService _activityTracker = ActivityTrackerService();
  bool _isLoading = true;
  
  int _totalSugarRecords = 0;
  int _totalInventoryItems = 0;
  int _totalSuppliers = 0;
  int _unreadAlerts = 0;
  int _lowStockItems = 0;
  double _averageGrowth = 0.0;
  int _unreadActivities = 0;

  // Advanced analytics data
  Map<String, dynamic> _analyticsData = {};
  List<SugarRecord> _sugarRecords = [];
  List<InventoryItem> _inventoryItems = [];
  List<SupplierTransaction> _supplierTransactions = [];
  List<AlertItem> _alerts = [];
  
  // Filtering
  Map<String, dynamic> _currentFilters = {};

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _activityTracker.initialize();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _loadDashboardData();
    _setupStreamListeners();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _activityTracker.dispose();
    super.dispose();
  }

  void _setupStreamListeners() {
    // Listen to real-time updates
    _repo.sugarRecordsStream.listen((records) {
      if (mounted) {
        setState(() {
          _sugarRecords = records;
          _totalSugarRecords = records.length;
          if (records.isNotEmpty) {
            _averageGrowth = records.map((r) => r.heightCm).reduce((a, b) => a + b) / records.length;
          }
          _updateAnalytics();
        });
      }
    });

    _repo.inventoryItemsStream.listen((items) {
      if (mounted) {
        setState(() {
          _inventoryItems = items;
          _totalInventoryItems = items.length;
          _lowStockItems = items.where((item) => item.quantity <= 10).length;
          _updateAnalytics();
        });
      }
    });

    _repo.supplierTransactionsStream.listen((transactions) {
      if (mounted) {
        setState(() {
          _supplierTransactions = transactions;
          _totalSuppliers = transactions.length;
          _updateAnalytics();
        });
      }
    });

    _repo.alertsStream.listen((alerts) {
      if (mounted) {
        setState(() {
          _alerts = alerts;
          _unreadAlerts = alerts.where((a) => !a.read).length;
          _updateAnalytics();
        });
      }
    });

    // Listen to activity updates
    _activityTracker.activitiesStream.listen((activities) {
      if (mounted) {
        setState(() {
          _unreadActivities = _activityTracker.unreadCount;
        });
      }
    });
  }

  void _updateAnalytics() {
    _analyticsData = AdvancedAnalytics.generateDashboardMetrics(
      sugarRecords: _sugarRecords,
      inventoryItems: _inventoryItems,
      supplierTransactions: _supplierTransactions,
      alerts: _alerts,
    );
  }

  Future<void> _loadDashboardData() async {
    try {
      final sugarRecords = await _repo.getSugarRecords();
      final inventoryItems = await _repo.getInventoryItems();
      final suppliers = await _repo.getSupplierTransactions();
      final alerts = await _repo.getAlerts();

      setState(() {
        _totalSugarRecords = sugarRecords.length;
        _totalInventoryItems = inventoryItems.length;
        _totalSuppliers = suppliers.length;
        _unreadAlerts = alerts.where((a) => !a.read).length;
        _lowStockItems = inventoryItems.where((item) => item.quantity <= 10).length;
        
        if (sugarRecords.isNotEmpty) {
          _averageGrowth = sugarRecords.map((r) => r.heightCm).reduce((a, b) => a + b) / sugarRecords.length;
        }
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Force refresh all data
      await _repo.getSugarRecords();
      await _repo.getInventoryItems();
      await _repo.getSupplierTransactions();
      await _repo.getAlerts();
      await _loadDashboardData();
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, isMobile, isTablet, isDesktop),
                _buildStatsGrid(context, isMobile, isTablet, isDesktop),
                _buildQuickActions(context, isMobile, isTablet, isDesktop),
                _buildDataFilterSection(context, isMobile, isTablet, isDesktop),
                _buildDataVisualizationSection(context, isMobile, isTablet, isDesktop),
                _buildDataExportSection(context, isMobile, isTablet, isDesktop),
                _buildRecentActivity(context, isMobile, isTablet, isDesktop),
                _buildLowStockAlert(context, isMobile, isTablet, isDesktop),
                _buildRecommendationsSection(context, isMobile, isTablet, isDesktop),
                // Add bottom padding for safe area
                SliverToBoxAdapter(
                  child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF2E7D32),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Farm Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF4CAF50),
                Color(0xFF66BB6A),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                onPressed: () => Navigator.pushNamed(context, '/alerts'),
              ),
              if (_unreadAlerts > 0 || _unreadActivities > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${_unreadAlerts + _unreadActivities}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
            onPressed: _refreshData,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    if (_isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 2,
            childAspectRatio: isTablet ? 1.2 : 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildMobileLoadingCard(),
            childCount: isTablet ? 6 : 6,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          childAspectRatio: isTablet ? 1.2 : 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildListDelegate([
          MetricCard(
            title: 'Sugar Records',
            value: _totalSugarRecords.toString(),
            icon: Icons.eco,
            color: const Color(0xFF4CAF50),
            onTap: () => Navigator.pushNamed(context, '/sugar'),
            subtitle: 'Total monitoring records',
            showTrend: true,
            trendValue: _totalSugarRecords > 0 ? 5.2 : 0,
          ),
          MetricCard(
            title: 'Inventory Items',
            value: _totalInventoryItems.toString(),
            icon: Icons.inventory,
            color: const Color(0xFF2196F3),
            onTap: () => Navigator.pushNamed(context, '/inventory'),
            subtitle: 'Items in stock',
            showTrend: true,
            trendValue: _totalInventoryItems > 0 ? 2.1 : 0,
          ),
          MetricCard(
            title: 'Suppliers',
            value: _totalSuppliers.toString(),
            icon: Icons.business,
            color: const Color(0xFFFF9800),
            onTap: () => Navigator.pushNamed(context, '/suppliers'),
            subtitle: 'Active suppliers',
          ),
          MetricCard(
            title: 'Avg Growth',
            value: '${_averageGrowth.toStringAsFixed(1)} cm',
            icon: Icons.trending_up,
            color: const Color(0xFF9C27B0),
            onTap: () => Navigator.pushNamed(context, '/insights'),
            subtitle: 'Average height',
            showTrend: true,
            trendValue: _averageGrowth > 0 ? 3.8 : 0,
          ),
          MetricCard(
            title: 'Alerts',
            value: _unreadAlerts.toString(),
            icon: Icons.notifications_active,
            color: const Color(0xFFF44336),
            onTap: () => Navigator.pushNamed(context, '/alerts'),
            subtitle: 'Unread notifications',
          ),
          MetricCard(
            title: 'Low Stock',
            value: _lowStockItems.toString(),
            icon: Icons.warning,
            color: const Color(0xFFFF5722),
            onTap: () => Navigator.pushNamed(context, '/inventory'),
            subtitle: 'Items need restocking',
          ),
        ]),
      ),
    );
  }


  Widget _buildMobileLoadingCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Spacer(),
            Container(
              width: 50,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 70,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ActionCard(
                    title: 'Add Sugar Record',
                    icon: Icons.add_circle,
                    color: const Color(0xFF4CAF50),
                    onTap: () => Navigator.pushNamed(context, '/sugar'),
                    description: 'Record new growth data',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ActionCard(
                    title: 'Add Inventory',
                    icon: Icons.add_box,
                    color: const Color(0xFF2196F3),
                    onTap: () => Navigator.pushNamed(context, '/inventory'),
                    description: 'Update stock levels',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ActionCard(
                    title: 'Add Supplier',
                    icon: Icons.business_center,
                    color: const Color(0xFFFF9800),
                    onTap: () => Navigator.pushNamed(context, '/suppliers'),
                    description: 'Record transactions',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ActionCard(
                    title: 'View Reports',
                    icon: Icons.analytics,
                    color: const Color(0xFF9C27B0),
                    onTap: () => Navigator.pushNamed(context, '/realtime'),
                    description: 'Analytics dashboard',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRecentActivity(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (_totalSugarRecords > 0)
                      _buildMobileActivityItem(
                        Icons.eco,
                        'Sugar monitoring updated',
                        'Latest record: ${_averageGrowth.toStringAsFixed(1)} cm',
                        const Color(0xFF4CAF50),
                      ),
                    if (_totalSugarRecords > 0 && _totalInventoryItems > 0)
                      const Divider(height: 20),
                    if (_totalInventoryItems > 0)
                      _buildMobileActivityItem(
                        Icons.inventory,
                        'Inventory stock updated',
                        '${_totalInventoryItems} items in stock',
                        const Color(0xFF2196F3),
                      ),
                    if (_totalInventoryItems > 0 && _totalSuppliers > 0)
                      const Divider(height: 20),
                    if (_totalSuppliers > 0)
                      _buildMobileActivityItem(
                        Icons.business,
                        'Supplier transactions',
                        '${_totalSuppliers} transactions recorded',
                        const Color(0xFFFF9800),
                      ),
                    if (_totalSuppliers > 0 && _unreadAlerts > 0)
                      const Divider(height: 20),
                    if (_unreadAlerts > 0)
                      _buildMobileActivityItem(
                        Icons.notifications,
                        'New alerts received',
                        '$_unreadAlerts unread notifications',
                        const Color(0xFFF44336),
                      ),
                    if (_unreadAlerts == 0 && _totalSugarRecords == 0 && _totalInventoryItems == 0 && _totalSuppliers == 0)
                      _buildMobileActivityItem(
                        Icons.info,
                        'No data available',
                        'Start by adding your first record',
                        const Color(0xFF2E7D32),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileActivityItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataVisualizationSection(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Data Visualization',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Growth trend chart
            if (_sugarRecords.isNotEmpty)
              DataVisualizationWidgets.buildGrowthTrendChart(_sugarRecords),
            const SizedBox(height: 12),
            // Inventory status chart
            if (_inventoryItems.isNotEmpty)
              DataVisualizationWidgets.buildInventoryStatusChart(_inventoryItems),
            const SizedBox(height: 12),
            // Supplier spending chart
            if (_supplierTransactions.isNotEmpty)
              DataVisualizationWidgets.buildSupplierSpendingChart(_supplierTransactions),
            const SizedBox(height: 12),
            // Alert distribution chart
            if (_alerts.isNotEmpty)
              DataVisualizationWidgets.buildAlertDistributionChart(_alerts),
          ],
        ),
      ),
    );
  }

  Widget _buildDataFilterSection(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverToBoxAdapter(
        child: DataFilterWidget(
          currentFilters: _currentFilters,
          onFiltersChanged: (filters) {
            setState(() {
              _currentFilters = filters;
            });
            _applyFilters();
          },
        ),
      ),
    );
  }

  Widget _buildDataExportSection(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverToBoxAdapter(
        child: const DataExportWidget(),
      ),
    );
  }

  void _applyFilters() {
    // Apply filters to data and update analytics
    _updateAnalytics();
  }

  Widget _buildLowStockAlert(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    if (_lowStockItems == 0) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverToBoxAdapter(
        child: Card(
          elevation: 3,
          color: Colors.red.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/inventory'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: Colors.red[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Low Stock Alert',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_lowStockItems items need restocking',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.red[600],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    final recommendations = _analyticsData['recommendations'] as List<String>? ?? [];
    
    if (recommendations.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: recommendations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final recommendation = entry.value;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < recommendations.length - 1 ? 12 : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFF2E7D32),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              recommendation,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
