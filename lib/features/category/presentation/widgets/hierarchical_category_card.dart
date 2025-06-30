import 'package:catalog_app/core/constants/api_constants.dart';
import 'package:catalog_app/core/route/app_routes.dart';
import 'package:catalog_app/core/utils/logger.dart';
import 'package:catalog_app/features/category/domain/entities/category.dart';
import 'package:catalog_app/features/category/presentation/cubit/categories_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/cache/image_cache_service.dart';

class HierarchicalCategoryCard extends StatelessWidget {
  final Category category;
  final int index;
  final bool isAdmin;
  final VoidCallback? onTap;
  final bool enableHierarchicalNavigation;

  const HierarchicalCategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.isAdmin,
    this.onTap,
    this.enableHierarchicalNavigation = true,
  });

  double _getCardHeight(BuildContext context) {
    return ResponsiveUtils.isMobile(context)
        ? 120.0 // Increased from 100.0 to accommodate icons
        : ResponsiveUtils.isTablet(context)
        ? 140.0
        : 180.0;
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      // Fallback colors if no color is provided
      final List<Color> fallbackColors = [
        Color(0xFF9ED9D5), // Teal
        Color(0xFFFEC78F), // Orange
        Color(0xFFFFE38F), // Yellow
        Color(0xFFFDB9A7), // Peach
        Color(0xFFE7DDCB), // Beige
        Color(0xFFAED6C1), // Green
        Color(0xFFD7BDE2), // Purple
        Color(0xFFAED6F1), // Blue
      ];
      final colorIndex = index % fallbackColors.length;
      return fallbackColors[colorIndex];
    }

    try {
      // Remove # if present and ensure it's 6 characters
      String cleanColor = colorString.replaceAll('#', '');
      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      }
    } catch (e) {
      // If parsing fails, use fallback
    }

    // Fallback to a default color
    return Color(0xFF9ED9D5);
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _parseColor(category.color);

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
      ),
      height: _getCardHeight(context),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
            ),
            onTap:
                onTap ??
                (enableHierarchicalNavigation
                    ? () => _handleCategoryTap(context)
                    : null),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              ),
              child: Row(
                children: [
                  // Left side - Text content
                  Expanded(flex: 2, child: _buildTextContent(context)),
                  // Center - Image (no overlapping icons)
                  Expanded(flex: 2, child: _buildImageSection(context)),
                  // Right side - Action icons
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      ResponsiveUtils.isMobile(context) ? 50.0 : 60.0,
                    ),
                    child: _buildActionIcons(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          category.name,
          style: TextStyle(
            fontSize: 18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      height: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
        ),
        child: _buildImageContent(context),
      ),
    );
  }

  Widget _buildActionIcons(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final iconSize = ResponsiveUtils.getResponsiveIconSize(
      context,
      isMobile ? 18.0 : 20.0,
    );
    final iconPadding = ResponsiveUtils.getResponsiveSpacing(
      context,
      isMobile ? 6.0 : 8.0,
    );
    final spacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      isMobile ? 4.0 : 8.0,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize:
          MainAxisSize.min, // Important: Don't take more space than needed
      children: [
        // Navigation/Expand icon
        Container(
          padding: EdgeInsets.all(iconPadding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _hasSubcategories() ? Icons.expand_more : Icons.arrow_forward_ios,
            color: Colors.black87,
            size: iconSize,
          ),
        ),

        // Admin menu (if admin)
        if (isAdmin) ...[
          SizedBox(height: spacing),
          _buildAdminMenuIcon(
            context,
            iconSize: iconSize,
            iconPadding: iconPadding,
          ),
        ],
      ],
    );
  }

  Widget _buildImageContent(BuildContext context) {
    final imageUrl = _getImageUrl(category.imagePath);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
        ),
        child: ImageCacheService.getCachedImage(
          imageUrl: category.imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Convert backslashes to forward slashes for URL
    final normalizedPath = imagePath.replaceAll('\\', '/');

    // Remove leading slash if present to avoid double slashes
    final cleanPath =
        normalizedPath.startsWith('/')
            ? normalizedPath.substring(1)
            : normalizedPath;

    return '${ApiConstants.baseImageUrl}$cleanPath';
  }

  Widget _buildAdminMenuIcon(
    BuildContext context, {
    required double iconSize,
    required double iconPadding,
  }) {
    return PopupMenuButton(
      icon: Container(
        padding: EdgeInsets.all(iconPadding),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.more_vert, size: iconSize, color: Colors.black87),
      ),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              onTap: () => _handleEdit(context),
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => _handleAddSubcategory(context),
              child: Row(
                children: [
                  Icon(Icons.add_box, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Add Subcategory'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => _handleDelete(context),
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'.tr()),
                ],
              ),
            ),
          ],
    );
  }

  void _handleCategoryTap(BuildContext context) async {
    final cubit = context.read<CategoriesCubit>();

    AppLogger.info(
      '🎯 HierarchicalCategoryCard tapped: ${category.name} (ID: ${category.id})',
    );

    // Check if this category has subcategories by trying to fetch them
    final hasSubcategories = await _checkForSubcategories(context, category.id);

    if (!context.mounted) return; // Guard against async context usage

    if (hasSubcategories) {
      // Navigate to subcategories
      AppLogger.info(
        '📂 Navigating to subcategories of: ${category.name} (ID: ${category.id})',
      );
      cubit.navigateToSubcategories(category);
    } else {
      // Navigate to products page
      AppLogger.info(
        '🛍️ Navigating to products for category: ${category.name} (ID: ${category.id})',
      );
      context.push(
        AppRoutes.products,
        extra: {
          'categoryId': category.id.toString(),
          'categoryName': category.name,
        },
      );
    }
  }

  Future<bool> _checkForSubcategories(
    BuildContext context,
    int categoryId,
  ) async {
    try {
      final cubit = context.read<CategoriesCubit>();
      // Use the repository to check if there are subcategories
      final result = await cubit.checkHasSubcategories(categoryId);
      return result;
    } catch (e) {
      // If there's an error, assume no subcategories and navigate to products
      AppLogger.error(
        'Error checking subcategories for category $categoryId: $e',
      );
      return false;
    }
  }

  void _handleEdit(BuildContext context) {
    final cubit = context.read<CategoriesCubit>();
    context
        .push(
          AppRoutes.categoryForm,
          extra: {'category': category, 'parentId': cubit.currentParentId},
        )
        .then((_) {
          if (context.mounted) {
            // Refresh current level
            if (cubit.isAtRootLevel) {
              cubit.getCategories(isInitialLoad: true);
            } else {
              cubit.getCategoriesByParent(
                cubit.currentParentId!,
                isInitialLoad: true,
              );
            }
          }
        });
  }

  void _handleAddSubcategory(BuildContext context) {
    final cubit = context.read<CategoriesCubit>();
    context
        .push(
          AppRoutes.categoryForm,
          extra: {'category': null, 'parentId': category.id},
        )
        .then((_) {
          if (context.mounted) {
            // Refresh current level to show any new subcategories
            if (cubit.isAtRootLevel) {
              cubit.getCategories(isInitialLoad: true);
            } else {
              cubit.getCategoriesByParent(
                cubit.currentParentId!,
                isInitialLoad: true,
              );
            }
          }
        });
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Category'.tr()),
          content: Text(
            '${'Are you sure you want to delete'.tr()} "${category.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<CategoriesCubit>().deleteCategory(category.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'.tr()),
            ),
          ],
        );
      },
    );
  }

  bool _hasSubcategories() {
    // This is a placeholder - the real check happens in _handleCategoryTap
    // The actual subcategory check is done asynchronously when tapped
    return true; // Always show as explorable, real check happens on tap
  }
}
