import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/products_cubit.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.categoryTitle,
    required this.categoryId,
  });
  final String categoryTitle;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final isAdmin = AppConfig.isAdmin;

    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Empty State Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: ResponsiveUtils.getResponsiveIconSize(context, 120),
                    height: ResponsiveUtils.getResponsiveIconSize(context, 120),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFC1D4).withOpacity(0.1),
                          const Color(0xFFFF8A95).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: const Color(0xFFFFC1D4).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 60),
                      color: const Color(0xFFFF8A95),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),

            // Title with Fade Animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    AppStrings.noProductsFound,
                    style: TextStyle(
                      fontSize:
                          24 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),

            // Subtitle with Delayed Animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    categoryTitle != null
                        ? 'No products found in this category yet.'.tr()
                        : 'No products available at the moment.'.tr(),
                    style: TextStyle(
                      fontSize:
                          16 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            if (isAdmin) ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 32),
              ),

              // Add Product Button for Admin
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1400),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await context.push(
                            AppRoutes.productForm,
                            extra: {'product': null, 'categoryId': categoryId},
                          );

                          // Refresh products list if product was created successfully
                          if (result == true && context.mounted) {
                            context.read<ProductsCubit>().getProducts(
                              categoryId ?? '',
                              isInitialLoad: true,
                            );
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A95),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              24,
                            ),
                            vertical: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              16,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFFFF8A95).withOpacity(0.3),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context, 32),
              ),

              // Refresh Button for Users
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1400),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<ProductsCubit>().getProducts(
                            categoryId ?? '',
                            isInitialLoad: true,
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF8A95),
                          side: const BorderSide(
                            color: Color(0xFFFF8A95),
                            width: 2,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              24,
                            ),
                            vertical: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              16,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
