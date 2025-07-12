import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_utils.dart';

class ProductsLoadingState extends StatelessWidget {
  final String? categoryTitle;

  const ProductsLoadingState({super.key, this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 32.0),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 24.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
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
                  width: ResponsiveUtils.getResponsiveSpacing(context, 80.0),
                  height: ResponsiveUtils.getResponsiveSpacing(context, 80.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveSpacing(context, 40.0),
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth:
                          ResponsiveUtils.isTablet(context) ? 4.0 : 3.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
                ),
                Text(
                  'Loading products...'.tr(),
                  style: TextStyle(
                    fontSize:
                        18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                ),
                Text(
                  '${'Please wait while we fetch products from'.tr()} ${categoryTitle ?? 'this category'.tr()}',
                  style: TextStyle(
                    fontSize:
                        15.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    color: const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
