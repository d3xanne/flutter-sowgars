import 'package:flutter/material.dart';
import 'package:sample/services/local_repository.dart';
import 'package:sample/services/activity_tracker_service.dart';
import 'package:sample/models/sugar_record.dart';
import 'package:sample/models/inventory_item.dart';
import 'package:sample/models/supplier_transaction.dart';
import 'package:sample/models/alert.dart';
import 'package:sample/screens/alerts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                _buildWelcomeSection(),
                _buildStatsOverview(),
                _buildQuickActions(),
                _buildDataVisualization(),
                _buildRecentActivity(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Analytics Dashboard',
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
          child: _buildNotificationBell(),
        ),
      ],
    );
  }

  Widget _buildNotificationBell() {
    return StreamBuilder<List<AlertItem>>(
      stream: LocalRepository.instance.alertsStream,
      initialData: const [],
      builder: (context, alertsSnapshot) {
        final alerts = alertsSnapshot.data ?? [];
        final unreadAlerts = alerts.where((a) => !a.read).length;
        
        return StreamBuilder<List<ActivityEvent>>(
          stream: ActivityTrackerService().activitiesStream,
          initialData: const [],
          builder: (context, activitiesSnapshot) {
            final activities = activitiesSnapshot.data ?? [];
            final unreadActivities = activities.where((a) => !a.isRead).length;
            final totalUnread = unreadAlerts + unreadActivities;
            
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  ),
                ),
                if (totalUnread > 0)
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
                        totalUnread.toString(),
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
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return const SliverToBoxAdapter(
      child: SizedBox.shrink(),
    );
  }

  Widget _buildStatsOverview() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<SugarRecord>>(
              stream: LocalRepository.instance.sugarRecordsStream,
              builder: (context, sugarSnapshot) {
                return StreamBuilder<List<InventoryItem>>(
                  stream: LocalRepository.instance.inventoryItemsStream,
                  builder: (context, inventorySnapshot) {
                    return StreamBuilder<List<SupplierTransaction>>(
                      stream: LocalRepository.instance.supplierTransactionsStream,
                      builder: (context, supplierSnapshot) {
                        return StreamBuilder<List<AlertItem>>(
                          stream: LocalRepository.instance.alertsStream,
                          builder: (context, alertSnapshot) {
                            final sugarRecords = sugarSnapshot.data ?? [];
                            final inventoryItems = inventorySnapshot.data ?? [];
                            final supplierTransactions = supplierSnapshot.data ?? [];
                            final alerts = alertSnapshot.data ?? [];

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        'Sugar Records',
                                        '${sugarRecords.length}',
                                        Icons.agriculture,
                                        const Color(0xFF4CAF50),
                                        'Total monitoring records',
                                        sugarRecords.length,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildStatCard(
                                        'Inventory Items',
                                        '${inventoryItems.length}',
                                        Icons.inventory_2,
                                        const Color(0xFF2196F3),
                                        'Items in stock',
                                        inventoryItems.length,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        'Suppliers',
                                        '${supplierTransactions.length}',
                                        Icons.business,
                                        const Color(0xFFFF9800),
                                        'Active suppliers',
                                        supplierTransactions.length,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildStatCard(
                                        'Alerts',
                                        '${alerts.where((a) => !a.read).length}',
                                        Icons.notifications_active,
                                        const Color(0xFFF44336),
                                        'Unread notifications',
                                        alerts.where((a) => !a.read).length,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${count}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Add Record',
                    Icons.add_circle_outline,
                    const Color(0xFF4CAF50),
                    () => Navigator.pushNamed(context, '/sugar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    'View Reports',
                    Icons.analytics_outlined,
                    const Color(0xFF2196F3),
                    () => Navigator.pushNamed(context, '/reports'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Inventory',
                    Icons.inventory_2,
                    const Color(0xFFFF9800),
                    () => Navigator.pushNamed(context, '/inventory'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    'Weather',
                    Icons.wb_sunny,
                    const Color(0xFF03A9F4),
                    () => Navigator.pushNamed(context, '/weather'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataVisualization() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Visualization',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.bar_chart,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'System Performance Metrics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  StreamBuilder<List<SugarRecord>>(
                    stream: LocalRepository.instance.sugarRecordsStream,
                    builder: (context, snapshot) {
                      final records = snapshot.data ?? [];
                      return _buildMetricRow('Sugar Records', records.length, const Color(0xFF4CAF50));
                    },
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<InventoryItem>>(
                    stream: LocalRepository.instance.inventoryItemsStream,
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? [];
                      return _buildMetricRow('Inventory Items', items.length, const Color(0xFF2196F3));
                    },
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<SupplierTransaction>>(
                    stream: LocalRepository.instance.supplierTransactionsStream,
                    builder: (context, snapshot) {
                      final transactions = snapshot.data ?? [];
                      return _buildMetricRow('Supplier Transactions', transactions.length, const Color(0xFFFF9800));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, int value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          width: 100,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildActivityItem(
                    Icons.agriculture,
                    'New sugarcane record added',
                    '2 hours ago',
                    const Color(0xFF4CAF50),
                    'Record #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                  ),
                  const Divider(height: 24),
                  _buildActivityItem(
                    Icons.inventory_2,
                    'Inventory updated',
                    '4 hours ago',
                    const Color(0xFF2196F3),
                    'Stock levels adjusted',
                  ),
                  const Divider(height: 24),
                  _buildActivityItem(
                    Icons.notifications,
                    'Weather alert received',
                    '6 hours ago',
                    const Color(0xFFFF9800),
                    'Rain forecast for tomorrow',
                  ),
                  const Divider(height: 24),
                  _buildActivityItem(
                    Icons.business,
                    'Supplier transaction',
                    '8 hours ago',
                    const Color(0xFF9C27B0),
                    'Payment processed',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time, Color color, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}