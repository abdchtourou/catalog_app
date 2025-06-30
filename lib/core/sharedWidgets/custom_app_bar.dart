import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/responsive_utils.dart';
import '../../features/currency/presentation/widgets/currency_widget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String searchHint;
  final VoidCallback? onMenuPressed;
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;
  final bool showSearch;
  final bool showDrawer;
  final Color backgroundColor;
  final Color textColor;

  const CustomAppBar({
    super.key,
    this.title,
    this.searchHint = 'ابحث عن المنتج الذي تريده',
    this.onMenuPressed,
    this.onSearchChanged,
    this.searchController,
    this.showSearch = true,
    this.showDrawer = true,
    this.backgroundColor = const Color(0xFFFFC1D4),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                ResponsiveUtils.isTablet(context) ||
                        ResponsiveUtils.isDesktop(context)
                    ? 24
                    : 16,
            vertical:
                showSearch
                    ? 8
                    : 4, // Less vertical padding for non-search AppBars
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevent unnecessary expansion
            children: [
              // Top row with logo, title, currency, and menu
              SizedBox(
                height: 56, // Fixed height for top row
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        16,
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(context, 8),
                    ),
                    Expanded(
                      child: Text(
                        title ?? "Logo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize:
                              16 *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                        ),
                        maxLines: 1, // Ensures text stays on one line
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Currency widget for admin users
                    if (AppConfig.isAdmin) ...[
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(context, 8),
                      ),
                      const CurrencyWidget(),
                    ],
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(context, 8),
                    ),
                  ],
                ),
              ),

              // Search bar (if enabled)
              if (showSearch) ...[
                SizedBox(height: 12),
                Container(
                  height: 48, // Fixed height for search bar
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          decoration: InputDecoration(
                            hintText: searchHint,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: TextStyle(
                              fontSize:
                                  14 *
                                  ResponsiveUtils.getFontSizeMultiplier(
                                    context,
                                  ),
                              color: Colors.grey[600],
                            ),
                          ),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize:
                                14 *
                                ResponsiveUtils.getFontSizeMultiplier(context),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          24,
                        ),
                      ),
                    ],
                  ),
                ),
               // Bottom padding
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    // Use responsive height calculation to prevent overflow
    if (showSearch) {
      // Base height + search bar height + padding
      return Size.fromHeight(140); // Optimized for search with proper spacing
    } else {
      // For non-search AppBars, use compact height
      return Size.fromHeight(70); // Compact height for better tablet experience
    }
  }
}

// Extension to make it easier to get responsive app bar height
extension CustomAppBarExtension on CustomAppBar {
  static double getAppBarHeight(
    BuildContext context, {
    bool showSearch = true,
  }) {
    return ResponsiveUtils.isTablet(context) ||
            ResponsiveUtils.isDesktop(context)
        ? (showSearch ? 140 : 80)
        : (showSearch ? 200 : 60);
  }
}
