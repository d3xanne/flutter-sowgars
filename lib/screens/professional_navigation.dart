import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/screens/home_screen.dart';
import 'package:sample/screens/reports_screen.dart';
import 'package:sample/screens/generate_insight_screen.dart';
import 'package:sample/sugar.dart';
import 'package:sample/inventory.dart';
import 'package:sample/screens/suppliers.dart';
import 'package:sample/weather.dart';
import 'package:sample/screens/settings.dart';
import 'package:sample/screens/data_cleanup_screen.dart';
import 'package:sample/constants/app_icons.dart';

class ProfessionalNavigation extends StatefulWidget {
  const ProfessionalNavigation({super.key});

  @override
  State<ProfessionalNavigation> createState() => _ProfessionalNavigationState();
}

class _ProfessionalNavigationState extends State<ProfessionalNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  

         List<NavigationItem> get _navigationItems => [
           NavigationItem(
             icon: AppIcons.homeOutlined,
             activeIcon: AppIcons.home,
             label: 'Home',
             page: HomeScreen(onNavigateTo: _onItemTapped),
             color: AppColors.primary,
           ),
           NavigationItem(
             icon: AppIcons.agricultureOutlined,
             activeIcon: AppIcons.agriculture,
             label: 'Sugar Records',
             page: const Sugar(),
             color: AppColors.primary,
           ),
           NavigationItem(
             icon: AppIcons.inventoryOutlined,
             activeIcon: AppIcons.inventory,
             label: 'Inventory',
             page: const Inventory(),
             color: AppColors.secondary,
           ),
           NavigationItem(
             icon: AppIcons.businessOutlined,
             activeIcon: AppIcons.business,
             label: 'Suppliers',
             page: const SuppliersScreen(),
             color: AppColors.accent,
           ),
           NavigationItem(
             icon: AppIcons.weatherOutlined,
             activeIcon: AppIcons.weather,
             label: 'Weather',
             page: const Weather(),
             color: AppColors.weather,
           ),
          NavigationItem(
            icon: AppIcons.psychologyOutlined,
            activeIcon: AppIcons.psychology,
            label: 'Generate Insight',
            page: const GenerateInsightScreen(),
            color: AppColors.insights,
          ),
          NavigationItem(
             icon: AppIcons.assessmentOutlined,
             activeIcon: AppIcons.assessment,
             label: 'Reports',
             page: const ReportsScreen(),
             color: AppColors.reports,
           ),
          NavigationItem(
            icon: AppIcons.settingsOutlined,
            activeIcon: AppIcons.settings,
            label: 'Settings',
            page: const SettingsScreen(),
            color: AppColors.settings,
          ),
          NavigationItem(
            icon: AppIcons.delete,
            activeIcon: AppIcons.delete,
            label: 'Data Cleanup',
            page: const DataCleanupScreen(),
            color: Colors.red,
          ),
        ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          
          if (isMobile) {
            return _buildMobileLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: _navigationItems[_currentIndex].page,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMobileTopBar(),
        Expanded(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: _navigationItems[_currentIndex].page,
              );
            },
          ),
        ),
        _buildMobileBottomNav(),
      ],
    );
  }

  Widget _buildMobileTopBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(
            Icons.agriculture,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Hacienda Elizabeth',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  _navigationItems[_currentIndex].label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomNav() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / _navigationItems.length;
          final isScrollable = itemWidth < 70;
          
          if (isScrollable) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = _currentIndex == index;
                  
                  return GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? item.color.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? item.color : Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(height: 2),
                          Flexible(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 8,
                                color: isSelected ? item.color : Colors.grey[600],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          } else {
            return Row(
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? item.color.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? item.color : Colors.grey[600],
                            size: 18,
                          ),
                          const SizedBox(height: 2),
                          Flexible(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 9,
                                color: isSelected ? item.color : Colors.grey[600],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildSidebar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final sidebarWidth = isMobile ? 240.0 : 280.0;
        
        return Container(
          width: sidebarWidth,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF1B5E20),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildNavigationList(),
              ),
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hacienda Elizabeth',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _navigationItems.length,
      itemBuilder: (context, index) {
        final item = _navigationItems[index];
        final isSelected = _currentIndex == index;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _currentIndex = index;
                });
                _animationController.reset();
                _animationController.forward();
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            item.color.withValues(alpha: 0.2),
                            item.color.withValues(alpha: 0.1),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: item.color.withValues(alpha: 0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.color.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? item.color : Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'System Online',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
    required this.color,
  });
}
