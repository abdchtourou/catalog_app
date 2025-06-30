import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/route/app_routes.dart';
import '../../domain/entities/product.dart';
import '../cubit/products_cubit.dart';
import 'simple_product_card.dart';
import 'add_product_card.dart';

class ProductsGridWithAdd extends StatelessWidget {
  final List<Product> products;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final String? categoryId;
  final VoidCallback? onProductUpdated;
  final Function(Product)? onProductDeleted;

  const ProductsGridWithAdd({
    super.key,
    required this.products,
    required this.scrollController,
    this.isLoadingMore = false,
    this.categoryId,
    this.onProductUpdated,
    this.onProductDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = AppConfig.isAdmin;
    final totalItems =
        products.length + (isAdmin ? 1 : 0) + (isLoadingMore ? 1 : 0);

    return Container(
      constraints: BoxConstraints(
        maxWidth: ResponsiveUtils.getMaxContentWidth(context),
      ),
      child: GridView.builder(
        controller: scrollController,
        padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
          top: ResponsiveUtils.getResponsiveSpacing(context, 16),
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        itemCount: totalItems,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtils.getGridColumns(context),
          crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12),
          mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
          childAspectRatio:
              ResponsiveUtils.isTablet(context) ||
                      ResponsiveUtils.isDesktop(context)
                  ? 0.75
                  : 0.6,
        ),
        itemBuilder: (context, index) {
          if (isAdmin && index == 0) {
            return AddProductCard(
              onTap: () async {
                final result = await context.push(
                  AppRoutes.productForm,
                  extra: {'product': null, 'categoryId': categoryId},
                );

                if (result == true && context.mounted) {
                  context.read<ProductsCubit>().getProducts(
                    categoryId ?? '',
                    isInitialLoad: true,
                  );
                }
              },
            );
          }

          final productIndex = isAdmin ? index - 1 : index;

          if (productIndex < products.length) {
            final product = products[productIndex];
            return SizedBox(
              child: SimpleProductCard(
                product: product,
                onTap: () async {
                  final result = await context.push(
                    AppRoutes.product,
                    extra: {'productId': product.id},
                  );

                  if (result == true && context.mounted) {
                    // Refresh the products list after product details actions
                    onProductUpdated?.call();
                  }
                },
                onEdit:
                    isAdmin
                        ? () async {
                          final result = await context.push(
                            AppRoutes.productForm,
                            extra: {
                              'product': product,
                              'categoryId': product.categoryId.toString(),
                            },
                          );

                          if (result == true && context.mounted) {
                            // Refresh the products list after successful edit
                            onProductUpdated?.call();
                          }
                        }
                        : null,
                onDelete:
                    isAdmin
                        ? () {
                          onProductDeleted?.call(product);
                        }
                        : null,
              ),
            );
          }
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
