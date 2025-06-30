import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:catalog_app/core/utils/logger.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/usecase/delete_product_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_all_products_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_all_products_with_search_use_case.dart';

part 'all_products_state.dart';

class AllProductsCubit extends Cubit<AllProductsState> {
  final GetAllProductsUseCase getAllProductsUseCase;
  final GetAllProductsWithSearchUseCase getAllProductsWithSearchUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  int _currentPage = 1;
  bool _isFetching = false;
  final int _pageSize = 20;
  bool _hasMore = true;
  final List<Product> _products = [];
  String? _currentSearchQuery;

  AllProductsCubit(
    this.getAllProductsUseCase,
    this.getAllProductsWithSearchUseCase,
    this.deleteProductUseCase,
  ) : super(AllProductsInitial());

  Future<void> getAllProducts({
    bool isInitialLoad = false,
    String? searchQuery,
  }) async {
    AppLogger.info('🛍️ AllProductsCubit.getAllProducts called');

    if (_isFetching) {
      return;
    }

    if (!_hasMore && !isInitialLoad) {
      return;
    }

    // Reset pagination for initial load or search query change
    if (isInitialLoad || searchQuery != _currentSearchQuery) {
      _currentPage = 1;
      _hasMore = true;
      _products.clear();
      _currentSearchQuery = searchQuery;
    }

    _isFetching = true;

    if (isInitialLoad) {
      emit(AllProductsLoading());
    } else {
      // Show loading more indicator
      emit(
        AllProductsLoaded(
          products: List.from(_products),
          isLoadingMore: true,
          hasMore: _hasMore,
        ),
      );
    }

    try {
      // Use search use case if search query is provided, otherwise use regular use case
      final result = searchQuery != null && searchQuery.isNotEmpty
          ? await getAllProductsWithSearchUseCase(
              pageNumber: _currentPage,
              pageSize: _pageSize,
              searchQuery: searchQuery,
            )
          : await getAllProductsUseCase(
              pageNumber: _currentPage,
              pageSize: _pageSize,
            );

      result.fold(
        (failure) =>
            emit(AllProductsError(message: "Failed to load: $failure")),
        (response) {
          final newProducts = response.products;

          _products.addAll(newProducts);
          _hasMore = newProducts.length == _pageSize;

          if (_hasMore) _currentPage++;

          emit(
            AllProductsLoaded(
              products: List.from(_products),
              isLoadingMore: false,
              hasMore: _hasMore,
            ),
          );
        },
      );
    } catch (e) {
      emit(AllProductsError(message: "Exception: $e"));
    } finally {
      _isFetching = false;
    }
  }

  // Method for searching all products
  Future<void> searchAllProducts(
    String searchQuery, {
    bool isInitialLoad = true,
  }) async {
    await getAllProducts(
      isInitialLoad: isInitialLoad,
      searchQuery: searchQuery,
    );
  }

  Future<void> deleteProduct(int id) async {
    emit(AllProductDeleting());
    final result = await deleteProductUseCase(id);
    result.fold(
      (failure) => emit(AllProductDeleteError(message: failure.toString())),
      (_) => emit(AllProductDeleted()),
    );
  }

  void resetState() {
    _currentPage = 1;
    _isFetching = false;
    _hasMore = true;
    _products.clear();
    _currentSearchQuery = null;
    emit(AllProductsInitial());
  }
}
