import 'package:flutter/material.dart';

class ModernBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ModernBottomNav> createState() => _ModernBottomNavState();
}

class _ModernBottomNavState extends State<ModernBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 8, 
            vertical: isTablet ? 12 : 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard, 'Dashboard', isTablet),
              _buildNavItem(1, Icons.eco, 'Sugar', isTablet),
              _buildNavItem(2, Icons.inventory, 'Inventory', isTablet),
              _buildNavItem(3, Icons.business, 'Suppliers', isTablet),
              _buildNavItem(4, Icons.analytics, 'Reports', isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isTablet) {
    final isSelected = widget.currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        widget.onTap(index);
        _animationController.reset();
        _animationController.forward();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 8, 
              vertical: isTablet ? 12 : 6,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isTablet ? 10 : 6),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected 
                        ? Colors.white
                        : Colors.grey[600],
                    size: isTablet ? 28 : 22,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                        ? const Color(0xFF2E7D32)
                        : Colors.grey[600],
                  ),
                  child: Text(label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
