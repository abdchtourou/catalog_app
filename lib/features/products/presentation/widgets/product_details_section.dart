import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/product.dart';
import '../../../currency/presentation/cubit/currency_cubit.dart';
import '../../../currency/presentation/cubit/currency_state.dart';

class ProductDetailsSection extends StatelessWidget {
  final Product product;
  final Animation<double> contentFadeAnimation;

  const ProductDetailsSection({
    super.key,
    required this.product,
    required this.contentFadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: contentFadeAnimation,
      child: Container(
        width: double.infinity,
        padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
          top: ResponsiveUtils.getResponsiveSpacing(context, 32),
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with   product name and price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name (left side)
                Expanded(child: _buildProductName(context)),

                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 16),
                ),

                // Price section (right side)
                _buildPriceSection(context),
              ],
            ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),

            // Product description with clean layout
            _buildProductDescription(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductName(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Text(
              product.name,
              style: TextStyle(
                fontSize: 24 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
                letterSpacing: -0.3,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductDescription(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Text(
              product.description.isNotEmpty
                  ? product.description
                  : 'Premium quality product with excellent features and modern design.'
                      .tr(),
              style: TextStyle(
                fontSize: 16 * ResponsiveUtils.getFontSizeMultiplier(context),
                color: Colors.grey[600],
                height: 1.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, currencyState) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 15 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // USD Price
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          20,
                        ),
                        vertical: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          12,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC1D4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(
                            context,
                            25,
                          ),
                        ),
                        border: Border.all(
                          color: const Color(0xFFFFC1D4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${product.price}',
                            style: TextStyle(
                              fontSize:
                                  20 *
                                  ResponsiveUtils.getFontSizeMultiplier(
                                    context,
                                  ),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF8A95),
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              4,
                            ),
                          ),
                          Text(
                            'USD'.tr(),
                            style: TextStyle(
                              fontSize:
                                  12 *
                                  ResponsiveUtils.getFontSizeMultiplier(
                                    context,
                                  ),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFF8A95).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, 8),
                    ),

                    // Syrian Pound Price - Always show
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          16,
                        ),
                        vertical: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          8,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(
                            context,
                            20,
                          ),
                        ),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getSyrianPrice(currencyState),
                            style: TextStyle(
                              fontSize:
                                  16 *
                                  ResponsiveUtils.getFontSizeMultiplier(
                                    context,
                                  ),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF059669),
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              4,
                            ),
                          ),
                          Text(
                            'SYP'.tr(),
                            style: TextStyle(
                              fontSize:
                                  12 *
                                  ResponsiveUtils.getFontSizeMultiplier(
                                    context,
                                  ),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF059669).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getSyrianPrice(CurrencyState currencyState) {
    // Always use the server-provided Syrian price from cache
    // This ensures consistency between admin and normal users
    if (product.syrianPoundPrice.isNotEmpty &&
        product.syrianPoundPrice != '0') {
      return '₪ ${product.syrianPoundPrice}';
    }

    // If no Syrian price is available from server, show placeholder
    // This will prompt admins to set the price and ensure normal users
    // see the same cached value
    return '₪ --';
  }
}
