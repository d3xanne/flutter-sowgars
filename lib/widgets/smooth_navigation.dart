import 'package:flutter/material.dart';

class SmoothNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;

  const SmoothNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  State<SmoothNavigation> createState() => _SmoothNavigationState();
}

class _SmoothNavigationState extends State<SmoothNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = widget.currentIndex == index;
              
              return _buildNavItem(index, item, isSelected);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, NavigationItem item, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.onTap(index);
        _animationController.reset();
        _animationController.forward();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? item.color.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isSelected ? 12 : 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? item.color
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected 
                    ? Colors.white
                    : Colors.grey[600],
                size: isSelected ? 24 : 20,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? item.color
                    : Colors.grey[600],
              ),
              child: Text(item.label),
            ),
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 4),
                width: 20,
                height: 3,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

// Floating Action Button with smooth animations
class SmoothFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SmoothFAB({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  State<SmoothFAB> createState() => _SmoothFABState();
}

class _SmoothFABState extends State<SmoothFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: FloatingActionButton(
                onPressed: null, // Handled by GestureDetector
                tooltip: widget.tooltip,
                backgroundColor: widget.backgroundColor ?? const Color(0xFF2E7D32),
                foregroundColor: widget.foregroundColor ?? Colors.white,
                elevation: 8,
                child: Icon(widget.icon, size: 28),
              ),
            ),
          );
        },
      ),
    );
  }
}
