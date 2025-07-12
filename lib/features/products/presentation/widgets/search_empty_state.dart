import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_utils.dart';

class SearchEmptyState extends StatelessWidget {
  final String searchQuery;
  final String categoryTitle;

  const SearchEmptyState({
    super.key,
    required this.searchQuery,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 40.0),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, 28.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      24.0,
                    ),
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 28.0),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF64748B).withOpacity(0.1),
                          const Color(0xFF64748B).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(
                          context,
                          24.0,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        88.0,
                      ),
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 28.0),
                  ),
                  Text(
                    'No results found'.tr(),
                    style: TextStyle(
                      fontSize:
                          26.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                  ),
                  Text(
                    '${'No products found for'.tr()} "$searchQuery" ${'in'.tr()} $categoryTitle\n${'Try searching with different keywords'.tr()}',
                    style: TextStyle(
                      fontSize:
                          17.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
