import 'package:catalog_app/core/route/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/sharedWidgets/custom_app_bar.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/shared_widgets/confirmation_dialog.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/service_locator.dart';
import '../../domain/entities/product.dart';
import '../cubit/products_cubit.dart';
import '../widgets/empty_state.dart';
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
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivityChanges();
  }

  Future<void> _checkConnectivity() async {
    final networkInfo = sl<NetworkInfo>();
    final isConnected = await networkInfo.isConnected;
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });
    }
  }

  void _listenToConnectivityChanges() {
    final networkInfo = sl<NetworkInfo>();
    networkInfo.connectivityStream.listen((result) {
      if (mounted) {
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Product product,
  ) async {
    // Check cached connectivity state
    if (!_isConnected) {
      OfflineActionDialog.showDeleteError(context, product);
      return;
    }

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
        isUpdate: false,
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
        child: Column(
          children: [
            // Main content
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                  ),
                  child: BlocListener<ProductsCubit, ProductsState>(
                    listener: (context, state) {
                      if (state is ProductDeleted) {
                        SnackBarUtils.showSuccess(
                          context,
                          'Product deleted successfully'.tr(),
                        );
                        // Refresh the products list after successful deletion
                        _refreshProductsList();
                      } else if (state is ProductDeleteError) {
                        SnackBarUtils.showError(
                          context,
                          '${'Failed to delete product: '.tr()}${state.message}',
                        );
                      }
                    },
                    child: BlocBuilder<ProductsCubit, ProductsState>(
                      builder: (context, state) {
                        // Handle loading states
                        if (state is ProductsLoading) {
                          return ProductsLoadingState(
                            categoryTitle: widget.categoryTitle,
                          );
                        }

                        if (state is ProductsError) {
                          return ProductsErrorState(
                            message: state.message,
                            onRetry: _refreshProductsList,
                          );
                        }

                        if (state is ProductsLoaded) {
                          if (state.products.isEmpty) {
                            // Show loading state for empty results that are still loading
                            if (state.isLoadingMore) {
                              return ProductsLoadingState(
                                categoryTitle: widget.categoryTitle,
                              );
                            }
                            return _currentSearchQuery.isNotEmpty
                                ? SearchEmptyState(
                                  searchQuery: _currentSearchQuery,
                                  categoryTitle: widget.categoryTitle ?? '',
                                )
                                : EmptyState(
                                  categoryTitle: widget.categoryTitle!,
                                  categoryId: widget.categoryId!,
                                );
                          } else {
                            // Show products with optional loading overlay
                            return _buildProductsContentWithLoading(
                              context,
                              state,
                            );
                          }
                        }

                        return EmptyState(
                          categoryTitle: widget.categoryTitle!,
                          categoryId: widget.categoryId!,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          // Check cached connectivity state
          if (!_isConnected) {
            OfflineActionDialog.showActionError(context, 'add product');
            return;
          }

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

  Widget _buildProductsContentWithLoading(
    BuildContext context,
    ProductsLoaded state,
  ) {
    return Column(
      children: [
        // Header section
        ProductsHeader(
          productCount: state.products.length,
          categoryTitle: widget.categoryTitle,
          searchQuery: _currentSearchQuery,
          isLoadingMore: state.isLoadingMore,
        ),

        // Products list with pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshProductsList();
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
                _refreshProductsList();
              },
              onProductDeleted: (product) {
                // Show confirmation dialog and delete product
                _showDeleteConfirmationDialog(context, product);
              },
            ),
          ),
        ),

        // Professional loading indicator for pagination
        if (state.isLoadingMore && state.hasMore) const LoadingMoreIndicator(),
      ],
    );
  }

  void _refreshProductsList() {
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
  }
}
