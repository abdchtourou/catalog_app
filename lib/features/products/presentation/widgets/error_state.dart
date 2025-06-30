import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/products_cubit.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.categoryId,
    required this.message,
  });
  final String categoryId;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Error Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: ResponsiveUtils.getResponsiveIconSize(context, 100),
                    height: ResponsiveUtils.getResponsiveIconSize(context, 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.1),
                          Colors.orange.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 50),
                      color: Colors.red[400],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),

            // Error Title
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'Oops! Something went wrong'.tr(),
                    style: TextStyle(
                      fontSize:
                          20 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),

            // Error Message
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 16),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize:
                            14 * ResponsiveUtils.getFontSizeMultiplier(context),
                        color: Colors.red[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<ProductsCubit>().getProducts(
                          categoryId ?? '',
                          isInitialLoad: true,
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(AppStrings.retry),
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
          ],
        ),
      ),
    );
  }
}
