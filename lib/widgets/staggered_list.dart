import 'package:flutter/material.dart';

class StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final bool animate;

  const StaggeredListItem({
    Key? key,
    required this.child,
    required this.index,
    this.animate = true,
  }) : super(key: key);

  @override
  _StaggeredListItemState createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    final delay = widget.index * 60;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted && widget.animate) {
        _controller.forward();
      }
    });

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
