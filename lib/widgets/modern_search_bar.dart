import 'package:flutter/material.dart';

class ModernSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Function()? onClear;
  final bool showFilter;
  final Function()? onFilterTap;

  const ModernSearchBar({
    Key? key,
    required this.hintText,
    required this.onSearch,
    this.onClear,
    this.showFilter = false,
    this.onFilterTap,
  }) : super(key: key);

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onSearchChanged(String value) {
    widget.onSearch(value);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12, 
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: isTablet ? 8 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
              border: Border.all(
                color: _isFocused 
                    ? const Color(0xFF2E7D32).withValues(alpha: _animation.value)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12, 
                vertical: isTablet ? 4 : 2,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: _isFocused 
                        ? const Color(0xFF2E7D32)
                        : Colors.grey[600],
                    size: isTablet ? 24 : 20,
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: _onSearchChanged,
                      onTap: () => _onFocusChange(true),
                      onTapOutside: (_) => _onFocusChange(false),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: isTablet ? 16 : 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
                      ),
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.clear,
                          size: isTablet ? 16 : 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  if (widget.showFilter && widget.onFilterTap != null) ...[
                    SizedBox(width: isTablet ? 8 : 6),
                    GestureDetector(
                      onTap: widget.onFilterTap,
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 8 : 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                        ),
                        child: Icon(
                          Icons.filter_list,
                          size: isTablet ? 20 : 18,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
