import 'package:flutter/material.dart';
import 'package:sample/screens/dashboard.dart';
import 'package:sample/sugar.dart';
import 'package:sample/inventory.dart';
import 'package:sample/screens/suppliers.dart';
import 'package:sample/screens/realtime_reports.dart';
import 'package:sample/widgets/smooth_navigation.dart';
import 'package:sample/widgets/animated_card.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const Sugar(),
    const Inventory(),
    const SuppliersScreen(),
    const RealtimeReportsScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      color: const Color(0xFF2E7D32),
    ),
    NavigationItem(
      icon: Icons.eco_outlined,
      activeIcon: Icons.eco,
      label: 'Sugar',
      color: const Color(0xFF4CAF50),
    ),
    NavigationItem(
      icon: Icons.inventory_outlined,
      activeIcon: Icons.inventory,
      label: 'Inventory',
      color: const Color(0xFF2196F3),
    ),
    NavigationItem(
      icon: Icons.business_outlined,
      activeIcon: Icons.business,
      label: 'Suppliers',
      color: const Color(0xFFFF9800),
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Reports',
      color: const Color(0xFF9C27B0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: SmoothNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _navigationItems,
      ),
      floatingActionButton: SmoothFAB(
        onPressed: () {
          // Add new record action
          _showAddRecordDialog();
        },
        icon: Icons.add,
        tooltip: 'Add New Record',
      ),
    );
  }

  void _showAddRecordDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Add New Record',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ActionCard(
                          title: 'Sugar Record',
                          icon: Icons.eco,
                          color: const Color(0xFF4CAF50),
                          onTap: () {
                            Navigator.pop(context);
                            _onTabTapped(1);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionCard(
                          title: 'Inventory',
                          icon: Icons.inventory,
                          color: const Color(0xFF2196F3),
                          onTap: () {
                            Navigator.pop(context);
                            _onTabTapped(2);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ActionCard(
                          title: 'Supplier',
                          icon: Icons.business,
                          color: const Color(0xFFFF9800),
                          onTap: () {
                            Navigator.pop(context);
                            _onTabTapped(3);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionCard(
                          title: 'Reports',
                          icon: Icons.analytics,
                          color: const Color(0xFF9C27B0),
                          onTap: () {
                            Navigator.pop(context);
                            _onTabTapped(4);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
