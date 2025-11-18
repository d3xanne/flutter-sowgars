import 'package:flutter/material.dart';

class AnimatedBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<BottomNavItem> items;
  final ValueChanged<int> onItemSelected;

  const AnimatedBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          var index = items.indexOf(item);
          return GestureDetector(
            onTap: () => onItemSelected(index),
            child: _buildNavItem(item, index == selectedIndex),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(BottomNavItem item, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isSelected ? item.activeColor.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            color: isSelected ? item.activeColor : Colors.grey,
            size: 24,
          ),
          if (isSelected)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 80 : 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: item.activeColor,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final Color activeColor;

  BottomNavItem({
    required this.icon,
    required this.label,
    this.activeColor = Colors.blue,
  });
}
