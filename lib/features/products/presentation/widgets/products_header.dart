import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_utils.dart';

class ProductsHeader extends StatelessWidget {
  final int productCount;
  final String? categoryTitle;
  final String searchQuery;
  final bool isLoadingMore;

  const ProductsHeader({
    super.key,
    required this.productCount,
    this.categoryTitle,
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveUtils.getResponsiveMargin(context),
      padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
        top: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 12.0),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
              ),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveIconSize(context, 28.0),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$productCount ${'Products'.tr()}',
                      style: TextStyle(
                        fontSize:
                            20.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    // Show subtle loading indicator when refreshing cached data
                    if (isLoadingMore && productCount > 0) ...[
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          8.0,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          16.0,
                        ),
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          16.0,
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF8A95),
                          ),
                          strokeWidth: 2.0,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  _getSubtitle(),
                  style: TextStyle(
                    fontSize:
                        14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitle() {
    if (searchQuery.isNotEmpty) {
      return '${'Search results in'.tr()} ${categoryTitle ?? 'category'.tr()}';
    }
    return '${'Products in'.tr()} ${categoryTitle ?? 'category'.tr()}';
  }
}
