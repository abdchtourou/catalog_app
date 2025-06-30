import 'package:catalog_app/core/route/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/sharedWidgets/custom_app_bar.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/shared_widgets/confirmation_dialog.dart';
import '../../domain/entities/product.dart';
import '../cubit/products_cubit.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/widgets.dart';

class ProductsScreen extends StatefulWidget {
  final String? categoryTitle;
  final String? categoryId;

  const ProductsScreen({super.key, this.categoryTitle, this.categoryId});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product product) {
    ConfirmationDialog.show(
      context,
      title: 'Delete Product'.tr(),
      message:
          '${'Are you sure you want to delete'.tr()} "${product.name}"?\n\n${'This action cannot be undone.'.tr()}',
      confirmText: 'Delete'.tr(),
      cancelText: 'Cancel'.tr(),
      confirmColor: const Color(0xFFEF4444),
      icon: Icons.delete_outline_rounded,
      iconColor: const Color(0xFFEF4444),
      onConfirm: () {
        context.read<ProductsCubit>().deleteProduct(product.id);
      },
    );
  }

  void _onSearchChanged(String query) {
    if (query != _currentSearchQuery) {
      _currentSearchQuery = query;
      // Debounce search to avoid too many API calls
      Future.delayed(const Duration(milliseconds: 500), () {
        if (query == _currentSearchQuery && mounted) {
          context.read<ProductsCubit>().searchProducts(
            widget.categoryId ?? '',
            query.trim(),
            isInitialLoad: true,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use global admin configuration
    final isAdmin = AppConfig.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: widget.categoryTitle ?? AppStrings.allProducts,
        searchController: _searchController,
        onMenuPressed: () {},
        onSearchChanged: _onSearchChanged,
        searchHint:
            '${'Search products in'.tr()} ${widget.categoryTitle ?? 'category'.tr()}...',
      ),
      floatingActionButton:
          isAdmin ? _buildFloatingActionButton(context) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8FAFC),
              const Color(0xFFE2E8F0).withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getMaxContentWidth(context),
            ),
            child: BlocListener<ProductsCubit, ProductsState>(
              listener: (context, state) {
                if (state is ProductDeleted) {
                  _showSuccessSnackBar('Product deleted successfully'.tr());
                  // Refresh the products list after successful deletion
                  if (_currentSearchQuery.isNotEmpty) {
                    context.read<ProductsCubit>().searchProducts(
                      widget.categoryId ?? '',
                      _currentSearchQuery,
                      isInitialLoad: true,
                    );
                  } else {
                    context.read<ProductsCubit>().getProducts(
                      widget.categoryId ?? '',
                      isInitialLoad: true,
                    );
                  }
                } else if (state is ProductDeleteError) {
                  _showErrorSnackBar(
                    '${'Failed to delete product: '.tr()}${state.message}',
                  );
                }
              },
              child: BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return _buildLoadingState(context);
                  }

                  if (state is ProductsError) {
                    return _buildErrorState(context, state.message);
                  }

                  if (state is ProductsLoaded) {
                    if (state.products.isEmpty) {
                      return _currentSearchQuery.isNotEmpty
                          ? _buildSearchEmptyState(context)
                          : _buildEmptyState(context);
                    } else {
                      return _buildProductsContent(context, state);
                    }
                  }

                  return _buildEmptyState(context);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return SizedBox(
      width: ResponsiveUtils.getResponsiveFABSize(context),
      height: ResponsiveUtils.getResponsiveFABSize(context),
      child: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(
            AppRoutes.productForm,
            extra: {'product': null, 'categoryId': widget.categoryId},
          );

          if (result == true && mounted) {
            context.read<ProductsCubit>().getProducts(
              widget.categoryId ?? '',
              isInitialLoad: true,
            );
          }
        },
        backgroundColor: const Color(0xFFFF8A95),
        foregroundColor: Colors.white,
        elevation: ResponsiveUtils.getResponsiveElevation(context, 6.0),
        child: Icon(
          Icons.add_rounded,
          size: ResponsiveUtils.getResponsiveIconSize(context, 28.0),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
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
                  '${'Please wait while we fetch products from'.tr()} ${widget.categoryTitle ?? 'this category'.tr()}',
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

  Widget _buildErrorState(BuildContext context, String message) {
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
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      32.0,
                    ),
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 24.0),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.1),
                          Colors.red.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(
                          context,
                          20.0,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        72.0,
                      ),
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 28.0),
                  ),
                  Text(
                    'Oops! Something went wrong'.tr(),
                    style: TextStyle(
                      fontSize:
                          22.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize:
                          16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 36.0),
                  ),
                  _buildRetryButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ResponsiveUtils.getResponsiveButtonHeight(context),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A95).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_currentSearchQuery.isNotEmpty) {
            context.read<ProductsCubit>().searchProducts(
              widget.categoryId ?? '',
              _currentSearchQuery,
              isInitialLoad: true,
            );
          } else {
            context.read<ProductsCubit>().getProducts(
              widget.categoryId ?? '',
              isInitialLoad: true,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: ResponsiveUtils.getResponsiveButtonPadding(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh_rounded,
              size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
            Text(
              'Try Again'.tr(),
              style: TextStyle(
                fontSize: 17.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState(
      categoryTitle: widget.categoryTitle!,
      categoryId: widget.categoryId!,
    );
  }

  Widget _buildSearchEmptyState(BuildContext context) {
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
                    '${'No products found for'.tr()} "$_currentSearchQuery" ${'in'.tr()} ${widget.categoryTitle}\n${'Try searching with different keywords'.tr()}',
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

  Widget _buildProductsContent(BuildContext context, ProductsLoaded state) {
    return Column(
      children: [
        // Header section with enhanced tablet styling
        Container(
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
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${state.products.length} ${'Products'.tr()}',
                      style: TextStyle(
                        fontSize:
                            20.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      _currentSearchQuery.isNotEmpty
                          ? '${'Search results in'.tr()} ${widget.categoryTitle}'
                          : '${'Products in'.tr()} ${widget.categoryTitle}',
                      style: TextStyle(
                        fontSize:
                            14.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Products list with pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (_currentSearchQuery.isNotEmpty) {
                context.read<ProductsCubit>().searchProducts(
                  widget.categoryId ?? '',
                  _currentSearchQuery,
                  isInitialLoad: true,
                );
              } else {
                context.read<ProductsCubit>().getProducts(
                  widget.categoryId ?? '',
                  isInitialLoad: true,
                );
              }
            },
            color: const Color(0xFFFF8A95),
            backgroundColor: Colors.white,
            strokeWidth: ResponsiveUtils.isTablet(context) ? 3.0 : 2.5,
            child: PaginatedProductsList(
              products: state.products,
              isLoadingMore: state.isLoadingMore,
              hasMore: state.hasMore,
              categoryTitle: widget.categoryTitle,
              categoryId: widget.categoryId,
              onEndReached: () {
                if (_currentSearchQuery.isNotEmpty) {
                  context.read<ProductsCubit>().searchProducts(
                    widget.categoryId ?? '',
                    _currentSearchQuery,
                  );
                } else {
                  context.read<ProductsCubit>().getProducts(
                    widget.categoryId ?? '',
                  );
                }
              },
              onProductUpdated: () {
                // Refresh the products list after successful edit
                if (_currentSearchQuery.isNotEmpty) {
                  context.read<ProductsCubit>().searchProducts(
                    widget.categoryId ?? '',
                    _currentSearchQuery,
                    isInitialLoad: true,
                  );
                } else {
                  context.read<ProductsCubit>().getProducts(
                    widget.categoryId ?? '',
                    isInitialLoad: true,
                  );
                }
              },
              onProductDeleted: (product) {
                // Show confirmation dialog and delete product
                _showDeleteConfirmationDialog(context, product);
              },
            ),
          ),
        ),

        // Loading more indicator
        if (state.isLoadingMore) _buildLoadingMoreIndicator(context),
      ],
    );
  }

  Widget _buildLoadingMoreIndicator(BuildContext context) {
    return Container(
      margin: ResponsiveUtils.getResponsiveMargin(context),
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 20.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
            height: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF8A95),
              ),
              strokeWidth: ResponsiveUtils.isTablet(context) ? 3.0 : 2.5,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          Text(
            'Loading more products...'.tr(),
            style: TextStyle(
              fontSize: 15.0 * ResponsiveUtils.getFontSizeMultiplier(context),
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveIconSize(context, 20.0),
            ),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
            ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize:
                      15.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
          ),
        ),
        margin: ResponsiveUtils.getResponsiveMargin(context),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveIconSize(context, 20.0),
            ),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
            ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize:
                      15.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
          ),
        ),
        margin: ResponsiveUtils.getResponsiveMargin(context),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
