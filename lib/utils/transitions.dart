
// CREATE THIS FILE: lib/utils/transitions.dart

import 'package:flutter/material.dart';

class PageTransitions {
  // Fade transition
  static PageRouteBuilder fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        var tween = Tween(begin: begin, end: end);
        var fadeAnimation = animation.drive(tween);
        return FadeTransition(opacity: fadeAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Slide transition (from right)
  static PageRouteBuilder slideTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        var tween = Tween(begin: begin, end: end);
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Scale transition
  static PageRouteBuilder scaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.8;
        const end = 1.0;
        var tween = Tween(begin: begin, end: end);
        var scaleAnimation = animation.drive(tween);
        return ScaleTransition(scale: scaleAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Combined transition (slide + fade)
  static PageRouteBuilder slideAndFadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeInOutCubic;
        var curveTween = CurveTween(curve: curve);
        
        // Slide animation
        const beginOffset = Offset(0.0, 0.1);
        const endOffset = Offset.zero;
        var slideTween = Tween(begin: beginOffset, end: endOffset);
        var slideAnimation = animation.drive(curveTween).drive(slideTween);
        
        // Fade animation
        var fadeTween = Tween(begin: 0.0, end: 1.0);
        var fadeAnimation = animation.drive(curveTween).drive(fadeTween);
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  // Hero based transition
  static Route heroTransition(Widget page, String heroTag) {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return page;
      },
    );
  }
}