import 'package:flutter/material.dart';

/// Standardized UI Components for consistent design across the app
class StandardizedUI {
  // Standard spacing constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Standard border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  
  // Standard elevations
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  
  // Minimum touch target size (accessibility)
  static const double minTouchTarget = 48.0;
  
  /// Standardized Elevated Button Style
  static ButtonStyle elevatedButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? const Color(0xFF2E7D32),
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
      ),
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: spacingL,
        vertical: spacingM,
      ),
      minimumSize: const Size(minTouchTarget, minTouchTarget),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  /// Standardized Text Button Style
  static ButtonStyle textButtonStyle({
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return TextButton.styleFrom(
      foregroundColor: foregroundColor ?? const Color(0xFF2E7D32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
      ),
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingS,
      ),
      minimumSize: const Size(minTouchTarget, minTouchTarget),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  /// Standardized Outlined Button Style
  static ButtonStyle outlinedButtonStyle({
    Color? foregroundColor,
    Color? borderColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor ?? const Color(0xFF2E7D32),
      side: BorderSide(
        color: borderColor ?? const Color(0xFF2E7D32),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
      ),
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: spacingL,
        vertical: spacingM,
      ),
      minimumSize: const Size(minTouchTarget, minTouchTarget),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  /// Standardized Card Widget
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? elevation,
    double? borderRadius,
    VoidCallback? onTap,
    Gradient? gradient,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(spacingM),
      child: Material(
        elevation: elevation ?? elevationMedium,
        borderRadius: BorderRadius.circular(borderRadius ?? radiusL),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? radiusL),
          child: Container(
            padding: padding ?? const EdgeInsets.all(spacingM),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(borderRadius ?? radiusL),
              gradient: gradient,
              boxShadow: elevation != null && elevation > 0
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: elevation * 2,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
  
  /// Responsive padding based on screen size
  static EdgeInsetsGeometry responsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return const EdgeInsets.all(spacingS);
    } else if (screenWidth < 600) {
      return const EdgeInsets.all(spacingM);
    } else {
      return const EdgeInsets.all(spacingL);
    }
  }
  
  /// Responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double baseSize,
    double? smallFactor,
    double? largeFactor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return baseSize * (smallFactor ?? 0.85);
    } else if (screenWidth > 1024) {
      return baseSize * (largeFactor ?? 1.15);
    }
    return baseSize;
  }
  
  /// Responsive dialog width
  static double dialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return screenWidth * 0.9;
    } else if (screenWidth < 1024) {
      return screenWidth * 0.7;
    } else {
      return 600;
    }
  }
  
  /// Standardized loading indicator
  static Widget loadingIndicator({
    Color? color,
    double? size,
    String? message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? const Color(0xFF2E7D32),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: spacingM),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: color ?? const Color(0xFF2E7D32),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Standardized error widget
  static Widget errorWidget({
    required String message,
    VoidCallback? onRetry,
    IconData? icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: spacingM),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: spacingL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: elevatedButtonStyle(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Standardized empty state widget
  static Widget emptyState({
    required String message,
    String? subtitle,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: spacingL),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: spacingS),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: spacingL),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel),
                style: elevatedButtonStyle(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

