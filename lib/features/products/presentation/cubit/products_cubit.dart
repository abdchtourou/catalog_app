import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:catalog_app/core/utils/logger.dart';
import 'package:catalog_app/features/products/domain/entities/attachment.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/usecase/create_attachment_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/create_product_with_images_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/delete_attachment_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/delete_product_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_products_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_products_with_search_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/update_product_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/update_product_with_attachments_use_case.dart';
import 'package:catalog_app/core/cache/product_cache_service.dart';
import 'package:catalog_app/core/network/network_info.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductsWithSearchUseCase getProductsWithSearchUseCase;
  final CreateProductWithImagesUseCase createProductWithImagesUseCase;
  final CreateAttachmentUseCase createAttachmentUseCase;
  final DeleteAttachmentUseCase deleteAttachmentUseCase;
  final DeleteAttachmentsUseCase deleteAttachmentsUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final UpdateProductWithAttachmentsUseCase updateProductWithAttachmentsUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final NetworkInfo networkInfo;

  int _currentPage = 1;
  bool _isFetching = false;
  final int _pageSize = 20;
  bool _hasMore = true;
  final List<Product> _products = [];
  String? _currentCategoryId;
  String? _currentSearchQuery;

  ProductsCubit(
    this.getProductsUseCase,
    this.getProductsWithSearchUseCase,
    this.createProductWithImagesUseCase,
    this.createAttachmentUseCase,
    this.deleteAttachmentUseCase,
    this.deleteAttachmentsUseCase,
    this.updateProductUseCase,
    this.updateProductWithAttachmentsUseCase,
    this.deleteProductUseCase,
    this.networkInfo,
  ) : super(ProductsInitial());

  Future<void> getProducts(
    String categoryId, {
    bool isInitialLoad = false,
    String? searchQuery,
  }) async {
    // ✅ FIX: Validate categoryId
    AppLogger.info(
      '🛍️ ProductsCubit.getProducts called with categoryId: "$categoryId"',
    );
    if (categoryId.isEmpty) {
      AppLogger.error('❌ Invalid category ID: categoryId cannot be empty');
      emit(
        ProductsError(
          message: "Invalid category ID: categoryId cannot be empty",
        ),
      );
      return;
    }

    if (_isFetching) {
      return;
    }

    if (!_hasMore && !isInitialLoad) {
      return;
    }

    _isFetching = true;

    // Will be set to true if we emit a cached list before network fetch completes
    bool servedCached = false;

    if (isInitialLoad ||
        _currentCategoryId != categoryId ||
        _currentSearchQuery != searchQuery) {
      _currentPage = 1;
      _products.clear();
      _currentCategoryId = categoryId;
      _currentSearchQuery = searchQuery;

      // 👉 Try to serve cached data immediately while we fetch fresh data
      final cachedProducts = await ProductCacheService.getCachedProductList(
        categoryId: int.tryParse(categoryId),
        searchQuery: searchQuery,
        page: _currentPage,
        limit: _pageSize,
      );

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        _products.addAll(cachedProducts);
        servedCached = true;
        emit(
          ProductsLoaded(
            products: List.from(_products),
            isLoadingMore: true, // indicate that fresh data is on the way
            hasMore: true,
          ),
        );
      } else {
        emit(ProductsLoading());
      }

      // 🚫 If offline, don't attempt remote fetch. Decide what to show.
      final connected = await networkInfo.isConnected;
      if (!connected) {
        _isFetching = false;

        if (servedCached) {
          // We already displayed cached data marked as loadingMore=true. Turn off loading flag.
          emit(
            ProductsLoaded(
              products: List.from(_products),
              isLoadingMore: false,
              hasMore: false,
            ),
          );
        } else {
          // No cached data; show a friendly offline error instead of infinite loader.
          emit(ProductsError(message: "No internet connection"));
        }

        return;
      }
    } else {
      emit(
        ProductsLoaded(
          products: List.from(_products),
          isLoadingMore: true,
          hasMore: _hasMore,
        ),
      );
    }

    try {
      final int pageToRequest = _currentPage;

      // Use search use case if search query is provided, otherwise use regular use case
      final result =
          searchQuery != null && searchQuery.isNotEmpty
              ? await getProductsWithSearchUseCase(
                categoryId,
                pageNumber: pageToRequest,
                pageSize: _pageSize,
                searchQuery: searchQuery,
              )
              : await getProductsUseCase(
                categoryId,
                pageNumber: pageToRequest,
                pageSize: _pageSize,
              );

      result.fold(
        (failure) => emit(ProductsError(message: "Failed to load: $failure")),
        (response) async {
          final newProducts = response.products;

          // Handle scenarios when we already displayed cached data
          if (servedCached && pageToRequest == 1) {
            if (newProducts.isNotEmpty) {
              // Replace cached with fresh to avoid duplicates
              _products
                ..clear()
                ..addAll(newProducts);
            } else {
              // Fresh call returned nothing (offline or no data). Keep the cached list.
              // No further state emission needed.
              _isFetching = false;
              return;
            }
          } else {
            _products.addAll(newProducts);
          }
          _hasMore = newProducts.length == _pageSize;

          if (_hasMore) _currentPage++;

          emit(
            ProductsLoaded(
              products: List.from(_products),
              isLoadingMore: false,
              hasMore: _hasMore,
            ),
          );

          if (newProducts.isNotEmpty) {
            await ProductCacheService.cacheProductList(
              newProducts,
              categoryId: int.tryParse(categoryId),
              searchQuery: searchQuery,
              page: pageToRequest,
              limit: _pageSize,
              totalCount: null,
            );
          }
        },
      );
    } catch (e) {
      emit(ProductsError(message: "Exception: $e"));
    } finally {
      _isFetching = false;
    }
  }

  // New method for searching products
  Future<void> searchProducts(
    String categoryId,
    String searchQuery, {
    bool isInitialLoad = true,
  }) async {
    await getProducts(
      categoryId,
      isInitialLoad: isInitialLoad,
      searchQuery: searchQuery,
    );
  }

  // New method for creating products with images
  Future<void> createProductWithImages(
    String name,
    String description,
    String price,
    String categoryId,
    List<File> images,
  ) async {
    emit(ProductFormSubmitting());
    try {
      final result = await createProductWithImagesUseCase(
        name,
        description,
        price,
        categoryId,
        images,
      );
      result.fold(
        (failure) => emit(ProductFormError(message: failure.toString())),
        (product) => emit(ProductFormSuccess(product: product)),
      );
    } catch (e) {
      emit(ProductFormError(message: e.toString()));
    }
  }

  Future<void> updateProduct(
    int id,
    String name,
    String description,
    String price,
    String categoryId,
    String syrianPoundPrice,
  ) async {
    emit(ProductFormSubmitting());
    final result = await updateProductUseCase(
      id,
      name,
      description,
      price,
      categoryId,
      syrianPoundPrice,
    );
    result.fold(
      (failure) => emit(ProductFormError(message: failure.toString())),
      (product) => emit(ProductFormSuccess(product: product)),
    );
  }

  Future<void> deleteProduct(int id) async {
    emit(ProductDeleting());
    final result = await deleteProductUseCase(id);
    result.fold(
      (failure) => emit(ProductDeleteError(message: failure.toString())),
      (_) => emit(ProductDeleted()),
    );
  }

  Future<void> updateProductWithImages({
    required int id,
    String? name,
    String? description,
    String? price,
    int? categoryId,
    List<File>? images,
  }) async {
    emit(ProductFormSubmitting());

    try {
      final result = await updateProductWithAttachmentsUseCase(
        id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        images: images,
      );

      result.fold(
        (failure) => emit(ProductFormError(message: failure.toString())),
        (product) => emit(ProductFormSuccess(product: product)),
      );
    } catch (e) {
      emit(ProductFormError(message: e.toString()));
    }
  }

  // Attachment management methods
  Future<void> addAttachmentToProduct(int productId, File imageFile) async {
    emit(ProductFormSubmitting());
    try {
      final result = await createAttachmentUseCase(productId, imageFile);
      result.fold(
        (failure) => emit(ProductFormError(message: failure.toString())),
        (attachment) => emit(AttachmentAdded(attachment: attachment)),
      );
    } catch (e) {
      emit(ProductFormError(message: e.toString()));
    }
  }

  Future<void> removeAttachment(int attachmentId) async {
    emit(ProductFormSubmitting());
    try {
      final result = await deleteAttachmentUseCase(attachmentId);
      result.fold(
        (failure) => emit(ProductFormError(message: failure.toString())),
        (_) => emit(AttachmentDeleted(attachmentId: attachmentId)),
      );
    } catch (e) {
      emit(ProductFormError(message: e.toString()));
    }
  }

  Future<void> removeMultipleAttachments(List<int> attachmentIds) async {
    emit(ProductFormSubmitting());
    try {
      final result = await deleteAttachmentsUseCase(attachmentIds);
      result.fold(
        (failure) => emit(ProductFormError(message: failure.toString())),
        (_) => emit(AttachmentsDeleted(attachmentIds: attachmentIds)),
      );
    } catch (e) {
      emit(ProductFormError(message: e.toString()));
    }
  }
}
