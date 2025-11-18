import 'package:flutter/material.dart';

class AppAnimations {
  // Page transition animations
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.right,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.left:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.right:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.up:
        begin = const Offset(0.0, 1.0);
        break;
      case SlideDirection.down:
        begin = const Offset(0.0, -1.0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      )),
      child: child,
    );
  }

  // Fade transition
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }

  // Scale transition
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double beginScale = 0.8,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: beginScale,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      )),
      child: child,
    );
  }

  // Combined transition
  static Widget combinedTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection slideDirection = SlideDirection.right,
    bool includeFade = true,
    bool includeScale = true,
  }) {
    Widget result = child;

    if (includeScale) {
      result = scaleTransition(
        child: result,
        animation: animation,
      );
    }

    if (includeFade) {
      result = fadeTransition(
        child: result,
        animation: animation,
      );
    }

    return slideTransition(
      child: result,
      animation: animation,
      direction: slideDirection,
    );
  }

  // Staggered animation for lists
  static Widget staggeredList({
    required List<Widget> children,
    required Animation<double> animation,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        final delayedAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(
            (index * 0.1).clamp(0.0, 1.0),
            ((index * 0.1) + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ));

        return AnimatedBuilder(
          animation: delayedAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - delayedAnimation.value)),
              child: Opacity(
                opacity: delayedAnimation.value,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }

  // Floating animation
  static Widget floatingAnimation({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (0.5 - (value - 0.5).abs())),
          child: child,
        );
      },
      child: child,
    );
  }

  // Pulse animation
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(seconds: 1),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 1.0, end: 1.1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Shake animation for errors
  static Widget shakeAnimation({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(10 * (0.5 - (animation.value - 0.5).abs()), 0),
          child: child,
        );
      },
      child: child,
    );
  }

  // Bounce animation
  static Widget bounceAnimation({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (0.1 * (0.5 - (animation.value - 0.5).abs())),
          child: child,
        );
      },
      child: child,
    );
  }
}

enum SlideDirection { left, right, up, down }

// Custom page route with animations
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;
  final Duration duration;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppAnimations.combinedTransition(
              child: child,
              animation: animation,
              slideDirection: direction,
            );
          },
        );
}

// Fade page route
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppAnimations.fadeTransition(
              child: child,
              animation: animation,
            );
          },
        );
}

// Scale page route
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppAnimations.scaleTransition(
              child: child,
              animation: animation,
            );
          },
        );
}
