import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MobileTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),
        brightness: Brightness.light,
      ),
      
      // Enhanced smooth animations
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CustomPageTransitionBuilder(),
          TargetPlatform.iOS: CustomPageTransitionBuilder(),
        },
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
        displayMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
        displaySmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
        headlineLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
        ),
        headlineMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
        ),
        headlineSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 10,
          color: Colors.black54,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(0xFF2E7D32),
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 1,
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF2E7D32);
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF2E7D32).withValues(alpha: 0.3);
          }
          return Colors.grey[300]!;
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF2E7D32);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF2E7D32);
          }
          return Colors.grey;
        }),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF2E7D32),
        inactiveTrackColor: Colors.grey[300]!,
        thumbColor: const Color(0xFF2E7D32),
        overlayColor: const Color(0xFF2E7D32).withValues(alpha: 0.2),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF2E7D32),
        linearTrackColor: Colors.grey,
        circularTrackColor: Colors.grey,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100]!,
        selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
        labelStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2E7D32),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2E7D32),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF2E7D32),
        unselectedLabelColor: Colors.grey,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
      ),
    );
  }
  
  // Responsive breakpoints
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
  
  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(20);
    }
  }
  
  // Responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize * 0.9;
    } else if (isTablet(context)) {
      return baseSize;
    } else {
      return baseSize * 1.1;
    }
  }
  
  // Responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize * 0.8;
    } else if (isTablet(context)) {
      return baseSize;
    } else {
      return baseSize * 1.2;
    }
  }
}

// Custom tilted_transition_builder.dart
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  const CustomPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideAndFadeTransition(
      animation: animation,
      child: child,
    );
  }
}

// Staggered animated list for smooth item transitions
class StaggeredAnimatedList extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;

  const StaggeredAnimatedList({
    Key? key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400) + (staggerDelay * index),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}

// Smooth slide and fade transition
class SlideAndFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const SlideAndFadeTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}
