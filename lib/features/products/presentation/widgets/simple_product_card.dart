import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/cache/image_cache_service.dart';
import '../../domain/entities/product.dart';
import 'admin_menu.dart';

class SimpleProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SimpleProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    final normalizedPath = imagePath.replaceAll('\\', '/');

    // Remove leading slash if present to avoid double slashes
    final cleanPath =
        normalizedPath.startsWith('/')
            ? normalizedPath.substring(1)
            : normalizedPath;

    return '${ApiConstants.baseImageUrl}$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: ResponsiveUtils.getResponsiveSpacing(context, 8),
              offset: Offset(
                0,
                ResponsiveUtils.getResponsiveSpacing(context, 2),
              ),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  flex:
                      ResponsiveUtils.isTablet(context) ||
                              ResponsiveUtils.isDesktop(context)
                          ? 6
                          : 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(
                            context,
                            12,
                          ),
                        ),
                        topRight: Radius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(
                            context,
                            12,
                          ),
                        ),
                      ),
                      color: Colors.grey[50],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(
                            context,
                            12,
                          ),
                        ),
                        topRight: Radius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(
                            context,
                            12,
                          ),
                        ),
                      ),
                      child:
                          product.attachments.isNotEmpty
                              ? ImageCacheService.getCachedImage(
                                imageUrl: product.attachments.first.path,
                                fit: BoxFit.cover,
                              )
                              : _buildPlaceholderImage(context),
                    ),
                  ),
                ),
                // Product Details
                Expanded(
                  flex:
                      ResponsiveUtils.isTablet(context) ||
                              ResponsiveUtils.isDesktop(context)
                          ? 3
                          : 3,
                  child: Padding(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Product Name
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize:
                                14 *
                                ResponsiveUtils.getFontSizeMultiplier(context),
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          maxLines:
                              ResponsiveUtils.isTablet(context) ||
                                      ResponsiveUtils.isDesktop(context)
                                  ? 3
                                  : 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Price
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              8,
                            ),
                            vertical: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              4,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E8),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveBorderRadius(
                                context,
                                6,
                              ),
                            ),
                          ),
                          child: Text(
                            '\$${product.price}',
                            style: TextStyle(
                              fontSize:
                                  12 *
                                  ResponsiveUtils.getFontSizeMultiplier(
                                    context,
                                  ),
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF6B7A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Admin Menu Overlay
            if (AppConfig.isAdmin)
              Positioned(
                top: ResponsiveUtils.getResponsiveSpacing(context, 8),
                right: ResponsiveUtils.getResponsiveSpacing(context, 8),
                child: AdminMenu(
                  product: product,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: ResponsiveUtils.getResponsiveIconSize(context, 32),
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
          Text(
            'No Image'.tr(),
            style: TextStyle(
              fontSize: 12 * ResponsiveUtils.getFontSizeMultiplier(context),
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[50],
      child: Center(
        child: SizedBox(
          width: ResponsiveUtils.getResponsiveSpacing(context, 24),
          height: ResponsiveUtils.getResponsiveSpacing(context, 24),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }
}
