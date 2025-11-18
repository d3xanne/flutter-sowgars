import 'package:flutter/material.dart';

class GestureHandler extends StatefulWidget {
  final Widget child;
  final Function()? onSwipeLeft;
  final Function()? onSwipeRight;
  final Function()? onSwipeUp;
  final Function()? onSwipeDown;
  final Function()? onDoubleTap;
  final Function()? onLongPress;
  final double sensitivity;

  const GestureHandler({
    Key? key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onDoubleTap,
    this.onLongPress,
    this.sensitivity = 50.0,
  }) : super(key: key);

  @override
  State<GestureHandler> createState() => _GestureHandlerState();
}

class _GestureHandlerState extends State<GestureHandler> {
  Offset? _startPosition;
  Offset? _currentPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _startPosition = details.globalPosition;
      },
      onPanUpdate: (details) {
        _currentPosition = details.globalPosition;
      },
      onPanEnd: (details) {
        if (_startPosition != null && _currentPosition != null) {
          final deltaX = _currentPosition!.dx - _startPosition!.dx;
          final deltaY = _currentPosition!.dy - _startPosition!.dy;
          
          // Determine swipe direction
          if (deltaX.abs() > deltaY.abs()) {
            // Horizontal swipe
            if (deltaX > widget.sensitivity) {
              widget.onSwipeRight?.call();
            } else if (deltaX < -widget.sensitivity) {
              widget.onSwipeLeft?.call();
            }
          } else {
            // Vertical swipe
            if (deltaY > widget.sensitivity) {
              widget.onSwipeDown?.call();
            } else if (deltaY < -widget.sensitivity) {
              widget.onSwipeUp?.call();
            }
          }
        }
        
        _startPosition = null;
        _currentPosition = null;
      },
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      child: widget.child,
    );
  }
}

// Swipe navigation wrapper
class SwipeNavigationWrapper extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onIndexChanged;
  final int maxIndex;

  const SwipeNavigationWrapper({
    Key? key,
    required this.child,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.maxIndex,
  }) : super(key: key);

  @override
  State<SwipeNavigationWrapper> createState() => _SwipeNavigationWrapperState();
}

class _SwipeNavigationWrapperState extends State<SwipeNavigationWrapper> {
  @override
  Widget build(BuildContext context) {
    return GestureHandler(
      onSwipeLeft: () {
        if (widget.currentIndex < widget.maxIndex) {
          widget.onIndexChanged(widget.currentIndex + 1);
        }
      },
      onSwipeRight: () {
        if (widget.currentIndex > 0) {
          widget.onIndexChanged(widget.currentIndex - 1);
        }
      },
      child: widget.child,
    );
  }
}

// Pull to refresh with custom animation
class CustomPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const CustomPullToRefresh({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _controller.forward();
        await widget.onRefresh();
        _controller.reverse();
      },
      color: widget.color ?? const Color(0xFF2E7D32),
      backgroundColor: widget.backgroundColor ?? Colors.white,
      child: widget.child,
    );
  }
}
