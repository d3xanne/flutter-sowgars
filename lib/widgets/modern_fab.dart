import 'package:flutter/material.dart';

class ModernFAB extends StatefulWidget {
  final Function(String) onActionSelected;

  const ModernFAB({
    Key? key,
    required this.onActionSelected,
  }) : super(key: key);

  @override
  State<ModernFAB> createState() => _ModernFABState();
}

class _ModernFABState extends State<ModernFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Stack(
      children: [
        // Background overlay
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleExpansion,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
        
        // Action buttons
        Positioned(
          bottom: isTablet ? 20 : 16,
          right: isTablet ? 20 : 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Sugar Record Button
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -(isTablet ? 80 : 70) * _animation.value),
                    child: Transform.scale(
                      scale: _animation.value,
                      child: Opacity(
                        opacity: _animation.value,
                        child: _buildMobileActionButton(
                          'Sugar Record',
                          Icons.eco,
                          const Color(0xFF4CAF50),
                          () => widget.onActionSelected('sugar'),
                          isTablet,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Inventory Button
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -(isTablet ? 60 : 50) * _animation.value),
                    child: Transform.scale(
                      scale: _animation.value,
                      child: Opacity(
                        opacity: _animation.value,
                        child: _buildMobileActionButton(
                          'Inventory',
                          Icons.inventory,
                          const Color(0xFF2196F3),
                          () => widget.onActionSelected('inventory'),
                          isTablet,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Supplier Button
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -(isTablet ? 40 : 30) * _animation.value),
                    child: Transform.scale(
                      scale: _animation.value,
                      child: Opacity(
                        opacity: _animation.value,
                        child: _buildMobileActionButton(
                          'Supplier',
                          Icons.business,
                          const Color(0xFFFF9800),
                          () => widget.onActionSelected('supplier'),
                          isTablet,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Main FAB
              FloatingActionButton(
                onPressed: _toggleExpansion,
                backgroundColor: const Color(0xFF2E7D32),
                mini: !isTablet,
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.125 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.add,
                    color: Colors.white,
                    size: isTablet ? 24 : 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileActionButton(String label, IconData icon, Color color, VoidCallback onTap, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 8 : 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 10, 
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 14 : 12,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 8 : 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: isTablet ? 48 : 40,
              height: isTablet ? 48 : 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isTablet ? 24 : 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
