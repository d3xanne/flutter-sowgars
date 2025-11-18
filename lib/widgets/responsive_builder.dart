import 'package:flutter/material.dart';

/// Comprehensive responsive utility widget for all platforms
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? smallMobile;
  final Widget? largeDesktop;

  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.smallMobile,
    this.largeDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Small mobile (phones in portrait, very small screens)
        if (smallMobile != null && width < 360) {
          return smallMobile!;
        }
        
        // Mobile (phones)
        if (width < 600) {
          return mobile;
        }
        
        // Tablet
        if (width < 1200) {
          return tablet ?? mobile;
        }
        
        // Desktop
        if (width < 1920) {
          return desktop ?? tablet ?? mobile;
        }
        
        // Large desktop (4K and above)
        return largeDesktop ?? desktop ?? tablet ?? mobile;
      },
    );
  }
}

/// Responsive utility class with helper methods
class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;
  static const double desktopBreakpoint = 1920;
  
  // Check device type
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
  
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  // Responsive padding
  static EdgeInsets getPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }
  
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
  }
  
  static EdgeInsets getVerticalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(vertical: 12);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(vertical: 16);
    } else {
      return const EdgeInsets.symmetric(vertical: 24);
    }
  }
  
  // Responsive font sizes
  static double getFontSize(BuildContext context, double baseSize) {
    if (isSmallMobile(context)) {
      return baseSize * 0.85;
    } else if (isMobile(context)) {
      return baseSize * 0.9;
    } else if (isTablet(context)) {
      return baseSize;
    } else if (isLargeDesktop(context)) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.1;
    }
  }
  
  // Responsive icon sizes
  static double getIconSize(BuildContext context, double baseSize) {
    if (isSmallMobile(context)) {
      return baseSize * 0.75;
    } else if (isMobile(context)) {
      return baseSize * 0.85;
    } else if (isTablet(context)) {
      return baseSize;
    } else if (isLargeDesktop(context)) {
      return baseSize * 1.3;
    } else {
      return baseSize * 1.15;
    }
  }
  
  // Responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing * 0.75;
    } else if (isTablet(context)) {
      return baseSpacing;
    } else {
      return baseSpacing * 1.25;
    }
  }
  
  // Responsive grid columns
  static int getGridColumns(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }
  
  // Responsive card width
  static double getCardWidth(BuildContext context, {double? maxWidth}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth - 24; // Account for padding
    } else if (isTablet(context)) {
      return (screenWidth - 48) / 2; // 2 columns with padding
    } else {
      final width = maxWidth ?? 400.0;
      return width;
    }
  }
  
  // Responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return screenWidth * 0.7;
    } else {
      return 500;
    }
  }
  
  // Responsive table columns
  static int getTableColumns(BuildContext context, {int mobile = 2, int tablet = 4, int desktop = 6}) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }
  
  // Responsive button height
  static double getButtonHeight(BuildContext context) {
    if (isSmallMobile(context)) {
      return 40;
    } else if (isMobile(context)) {
      return 44;
    } else {
      return 48;
    }
  }
  
  // Responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return kToolbarHeight;
    } else {
      return kToolbarHeight + 8;
    }
  }
  
  // Check if screen is in landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  // Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  // Responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 1200;
    } else {
      return 1400;
    }
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 12,
    this.runSpacing = 12,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ResponsiveUtils.getGridColumns(
          context,
          mobile: mobileColumns,
          tablet: tabletColumns,
          desktop: desktopColumns,
        );
        
        return Padding(
          padding: padding ?? ResponsiveUtils.getPadding(context),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
              childAspectRatio: 1.0,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        );
      },
    );
  }
}

/// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    Key? key,
    required this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveUtils.getFontSize(context, fontSize),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

