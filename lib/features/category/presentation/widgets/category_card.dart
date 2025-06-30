import 'package:catalog_app/core/constants/api_constants.dart';
import 'package:catalog_app/core/constants/app_strings.dart';
import 'package:catalog_app/core/route/app_routes.dart';
import 'package:catalog_app/features/category/domain/entities/category.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/cache/image_cache_service.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final int index;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  double _getCardHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) {
      return 220;
    } else if (ResponsiveUtils.isTablet(context)) {
      return 180;
    } else {
      return 120;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> categoryColors = [
      Color(0xFF9ED9D5), // New products
      Color(0xFFFEC78F), // Body lotions
      Color(0xFFFFE38F), // Skin care
      Color(0xFFFDB9A7), // Shampoo
      Color(0xFFE7DDCB), // Perfumes
      Color(0xFFAED6C1), // Make-up
    ];
    final i = index % categoryColors.length;

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
      ),
      height: _getCardHeight(context),
      decoration: BoxDecoration(
        color: categoryColors[i],
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 20),
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
              ResponsiveUtils.getResponsiveBorderRadius(context, 20),
            ),
            onTap: () {
              context.push(
                AppRoutes.products,
                extra: {
                  'categoryId': category.id.toString(),
                  'categoryName': category.name,
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    ResponsiveUtils.isTablet(context) ||
                            ResponsiveUtils.isDesktop(context)
                        ? 20
                        : 16,
                vertical:
                    ResponsiveUtils.isTablet(context) ||
                            ResponsiveUtils.isDesktop(context)
                        ? 16
                        : 12,
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: _buildTextContent(context)),
                  Expanded(flex: 2, child: _buildImageSection(context)),
                ],
              ),
            ),
          ),
          if (isAdmin) _buildAdminControls(context),
        ],
      ),
    );
  }

  Widget _buildAdminControls(BuildContext context) {
    return Positioned(
      top: ResponsiveUtils.getResponsiveSpacing(context, 8),
      left: ResponsiveUtils.getResponsiveSpacing(context, 8),
      child: PopupMenuButton(
        icon: Container(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsiveSpacing(context, 6),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.more_vert,
            size: ResponsiveUtils.getResponsiveIconSize(context, 20),
            color: Colors.black54,
          ),
        ),
        itemBuilder:
            (context) => [
              PopupMenuItem(onTap: onEdit, child: Text('Edit'.tr())),
              PopupMenuItem(onTap: onDelete, child: Text('Delete'.tr())),
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
            fontSize:
                ResponsiveUtils.isTablet(context) ||
                        ResponsiveUtils.isDesktop(context)
                    ? 22 * ResponsiveUtils.getFontSizeMultiplier(context)
                    : 18 * ResponsiveUtils.getFontSizeMultiplier(context),
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
        ),
        SizedBox(height: 4),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, {bool hasProducts = false}) {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 12),
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
              ResponsiveUtils.getResponsiveBorderRadius(context, 12),
            ),
            child:
                hasProducts
                    ? _buildProductImage(context)
                    : _buildNoProductsPlaceholder(context),
          ),
        ),
        _buildArrowIcon(context),
      ],
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return ImageCacheService.getCachedImage(
      imageUrl: category.name,
      fit: BoxFit.cover,
    );
  }

  Widget _buildNoProductsPlaceholder(BuildContext context) {
    return ImageCacheService.getCachedImage(
      imageUrl: category.imagePath,
      fit: BoxFit.cover,
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

  Widget _buildArrowIcon(BuildContext context) {
    return Positioned(
      right: ResponsiveUtils.getResponsiveSpacing(context, 10),
      top: ResponsiveUtils.getResponsiveSpacing(context, 20),
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, 10),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: ResponsiveUtils.getResponsiveIconSize(context, 20),
        ),
      ),
    );
  }
}
