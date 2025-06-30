import 'package:flutter/material.dart';

/// Responsive utility class to handle different screen sizes
class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1000;
  static const double desktopBreakpoint = 1200;

  /// Check if the current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if the current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if the current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 20);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  /// Get responsive card width for grid layouts
  static double getCardWidth(BuildContext context, {int columns = 2}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getResponsivePadding(context);
    final availableWidth = screenWidth - padding.horizontal;

    if (isMobile(context)) {
      return (availableWidth - (16 * (columns - 1))) / columns;
    } else if (isTablet(context)) {
      final tabletColumns = columns + 1;
      return (availableWidth - (20 * (tabletColumns - 1))) / tabletColumns;
    } else {
      final desktopColumns = columns + 2;
      return (availableWidth - (24 * (desktopColumns - 1))) / desktopColumns;
    }
  }

  /// Get responsive grid columns count
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    if (isMobile(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.15;
    } else {
      return 1.3;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing;
    } else if (isTablet(context)) {
      return baseSpacing * 1.3;
    } else {
      return baseSpacing * 1.6;
    }
  }

  /// Get responsive container max width for content
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      return screenWidth;
    } else if (isTablet(context)) {
      return screenWidth * 0.9; // Use 90% of screen width on tablet
    } else {
      return 1200;
    }
  }

  /// Get responsive ad card width for horizontal lists
  static double getAdCardWidth(BuildContext context) {
    if (isMobile(context)) {
      return 200;
    } else if (isTablet(context)) {
      return 280;
    } else {
      return 320;
    }
  }

  /// Get responsive ad card height for horizontal lists
  static double getAdCardHeight(BuildContext context) {
    if (isMobile(context)) {
      return 320;
    } else if (isTablet(context)) {
      return 400;
    } else {
      return 450;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final multiplier = getFontSizeMultiplier(context);
    return baseSize * multiplier;
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context,
    double baseRadius,
  ) {
    if (isMobile(context)) {
      return baseRadius;
    } else if (isTablet(context)) {
      return baseRadius * 1.3;
    } else {
      return baseRadius * 1.6;
    }
  }

  /// Get responsive grid cross axis count for GridView
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 2; // 2 columns on mobile
    } else if (isTablet(context)) {
      return 3; // 3 columns on tablet
    } else {
      return 4; // 4 columns on desktop
    }
  }

  /// Get responsive grid child aspect ratio for GridView items
  static double getGridChildAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 0.75; // Slightly taller than wide on mobile for better product display
    } else if (isTablet(context)) {
      return 0.8; // Balanced ratio on tablet
    } else {
      return 0.85; // More square-like on desktop
    }
  }

  /// Get responsive card elevation
  static double getResponsiveElevation(
    BuildContext context,
    double baseElevation,
  ) {
    if (isMobile(context)) {
      return baseElevation;
    } else if (isTablet(context)) {
      return baseElevation * 1.2;
    } else {
      return baseElevation * 1.5;
    }
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48.0;
    } else if (isTablet(context)) {
      return 56.0;
    } else {
      return 64.0;
    }
  }

  /// Get responsive button padding
  static EdgeInsets getResponsiveButtonPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }

  /// Get responsive dialog width
  static double getResponsiveDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return 500.0;
    } else {
      return 600.0;
    }
  }

  /// Get responsive list tile height
  static double getResponsiveListTileHeight(BuildContext context) {
    if (isMobile(context)) {
      return 72.0;
    } else if (isTablet(context)) {
      return 88.0;
    } else {
      return 96.0;
    }
  }

  /// Get responsive category card height
  static double getResponsiveCategoryCardHeight(BuildContext context) {
    if (isMobile(context)) {
      return 120.0;
    } else if (isTablet(context)) {
      return 160.0;
    } else {
      return 200.0;
    }
  }

  /// Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return kToolbarHeight;
    } else if (isTablet(context)) {
      return kToolbarHeight + 16;
    } else {
      return kToolbarHeight + 24;
    }
  }

  /// Get responsive floating action button size
  static double getResponsiveFABSize(BuildContext context) {
    if (isMobile(context)) {
      return 56.0;
    } else if (isTablet(context)) {
      return 64.0;
    } else {
      return 72.0;
    }
  }
}
