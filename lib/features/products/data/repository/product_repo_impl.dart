import 'dart:io';
import 'package:catalog_app/core/cache/product_cache_service.dart';
import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/core/network/network_info.dart';
import 'package:catalog_app/features/category/domain/entities/pagination.dart';
import 'package:catalog_app/features/products/data/datasource/product_remote_data_source.dart';
import 'package:catalog_app/features/products/data/model/product_response_model.dart';
import 'package:catalog_app/features/products/domain/entities/attachment.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/entities/products_response.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class ProductRepoImpl extends ProductRepository {
  final ProductRemoteDataSource productRemoteDataSource;
  final NetworkInfo networkInfo;

  ProductRepoImpl({
    required this.productRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProductsResponse>> getProducts(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final page = pageNumber ?? 1;
      final limit = pageSize ?? 20;
      final categoryIdInt = int.tryParse(categoryId);

      // Check if we have cached data first
      final cachedProducts = await ProductCacheService.getCachedProductList(
        categoryId: categoryIdInt,
        page: page,
        limit: limit,
      );

      if (await networkInfo.isConnected) {
        // Fetch from network
        final response = await productRemoteDataSource.getProducts(
          categoryId,
          pageNumber: page,
          pageSize: limit,
        );

        // Cache the fresh data
        await ProductCacheService.cacheProductList(
          response.products,
          categoryId: categoryIdInt,
          page: page,
          limit: limit,
          totalCount: response.pagination.totalCount,
        );

        return Right(response);
      } else {
        // Return cached data if available, otherwise return empty
        if (cachedProducts != null && cachedProducts.isNotEmpty) {
          return Right(
            ProductResponseModel(
              products: cachedProducts,
              isSuccessful: true,
              responseTime: DateTime.now().toIso8601String(),
              pagination: Pagination(
                page: page,
                totalCount: cachedProducts.length,
                resultCount: cachedProducts.length,
                resultsPerPage: limit,
              ),
              error: '',
            ),
          );
        } else {
          return Left(OfflineFailure());
        }
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ProductsResponse>> getProductsWithSearch(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  }) async {
    try {
      final page = pageNumber ?? 1;
      final limit = pageSize ?? 20;
      final categoryIdInt = int.tryParse(categoryId);

      // Check if we have cached search results
      final cachedProducts = await ProductCacheService.getCachedProductList(
        categoryId: categoryIdInt,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
      );

      if (await networkInfo.isConnected) {
        // Fetch from network
        final response = await productRemoteDataSource.getProductsWithSearch(
          categoryId,
          pageNumber: page,
          pageSize: limit,
          searchQuery: searchQuery,
        );

        // Cache the fresh data
        await ProductCacheService.cacheProductList(
          response.products,
          categoryId: categoryIdInt,
          searchQuery: searchQuery,
          page: page,
          limit: limit,
          totalCount: response.pagination.totalCount,
        );

        return Right(response);
      } else {
        // Return cached data if available, otherwise return empty
        if (cachedProducts != null && cachedProducts.isNotEmpty) {
          return Right(
            ProductResponseModel(
              products: cachedProducts,
              isSuccessful: true,
              responseTime: DateTime.now().toIso8601String(),
              pagination: Pagination(
                page: page,
                totalCount: cachedProducts.length,
                resultCount: cachedProducts.length,
                resultsPerPage: limit,
              ),
              error: '',
            ),
          );
        } else {
          return Left(OfflineFailure());
        }
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(int id) async {
    try {
      // First, try to get from cache
      final cachedProduct = ProductCacheService.getCachedProduct(id);
      if (cachedProduct != null) {
        // Return cached product immediately for better performance
        return Right(cachedProduct);
      }

      // If not in cache or expired, fetch from network only if connected
      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.getProduct(id);

        // Cache the fetched product for future use
        await ProductCacheService.cacheProduct(response);

        return Right(response);
      } else {
        // If offline and no valid cache, return offline failure
        return Left(OfflineFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(
    int id,
    String name,
    String description,
    String price,
    String categoryId,
    String syrianPoundPrice,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.updateProduct(
          id,
          name,
          description,
          price,
          categoryId,
          syrianPoundPrice,
        );

        // Remove the specific product from cache and invalidate category cache
        await ProductCacheService.removeCachedProduct(id);
        await ProductCacheService.invalidateCategoryCache(
          int.parse(categoryId),
        );

        // Cache the updated product
        await ProductCacheService.cacheProduct(response);

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    try {
      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.deleteProduct(id);

        // Remove the specific product from cache
        await ProductCacheService.removeCachedProduct(id);

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> createProductWithImages(
    String name,
    String description,
    String price,
    String categoryId,
    String syrianPoundPrice,
    List<File> images,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.createProductWithImages(
          name,
          description,
          price,
          categoryId,
          images,
        );

        // Invalidate category cache to ensure fresh data is fetched
        await ProductCacheService.invalidateCategoryCache(
          int.parse(categoryId),
        );

        // Cache the new product
        await ProductCacheService.cacheProduct(response);

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Attachment>> createAttachment(
    int productId,
    File image,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.createAttachment(
          productId,
          image,
        );

        // Invalidate cached product to ensure fresh data is fetched
        await ProductCacheService.removeCachedProduct(productId);

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttachment(int attachmentId) async {
    try {
      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.deleteAttachment(
          attachmentId,
        );

        // Note: We don't have direct productId here, so we could either:
        // 1. Clear all cache (more aggressive)
        // 2. Keep track of attachment-to-product mapping
        // For now, we'll clear expired cache to be safe
        await ProductCacheService.clearExpiredCache();

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttachments(
    List<int> attachmentIds,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        await productRemoteDataSource.deleteAttachments(attachmentIds);

        // Clear expired cache after bulk deletion
        await ProductCacheService.clearExpiredCache();

        return const Right(null);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Attachment>> getAttachment(int attachmentId) async {
    try {
      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.getAttachment(
          attachmentId,
        );
        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> updateProductWithAttachments(
    int id, {
    String? name,
    String? description,
    String? price,
    int? categoryId,
    List<File>? images,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource
            .updateProductWithAttachments(
              id,
              name: name,
              description: description,
              price: price,
              categoryId: categoryId,
              images: images,
            );

        // Remove the specific product from cache and invalidate category cache
        await ProductCacheService.removeCachedProduct(id);
        if (categoryId != null) {
          await ProductCacheService.invalidateCategoryCache(categoryId);
        }

        // Cache the updated product
        await ProductCacheService.cacheProduct(response);

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  // Note: updateSyrianPrice is handled via updateProduct method
  // The Syrian price is part of the product update, not a separate endpoint

  @override
  Future<Either<Failure, ProductsResponse>> getAllProducts({
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final page = pageNumber ?? 1;
      final limit = pageSize ?? 20;

      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.getAllProducts(
          pageNumber: page,
          pageSize: limit,
        );

        // Cache individual products for faster detail access
        for (final product in response.products) {
          await ProductCacheService.cacheProduct(product);
        }

        return Right(response);
      } else {
        // For offline mode, return all cached products
        final cachedProducts = ProductCacheService.getAllCachedProducts();

        return Right(
          ProductResponseModel(
            products: cachedProducts,
            pagination: Pagination(
              page: page,
              totalCount: cachedProducts.length,
              resultCount: cachedProducts.length,
              resultsPerPage: limit,
            ),
            isSuccessful: true,
            responseTime: DateTime.now().toIso8601String(),
            error: '',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ProductsResponse>> getAllProductsWithSearch({
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  }) async {
    try {
      final page = pageNumber ?? 1;
      final limit = pageSize ?? 20;

      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.getAllProductsWithSearch(
          pageNumber: page,
          pageSize: limit,
          searchQuery: searchQuery,
        );

        // Cache individual products for faster detail access
        for (final product in response.products) {
          await ProductCacheService.cacheProduct(product);
        }

        return Right(response);
      } else {
        // For offline mode, return all cached products and filter locally
        final cachedProducts = ProductCacheService.getAllCachedProducts();

        // Simple local search if search query is provided
        List<Product> filteredProducts = cachedProducts;
        if (searchQuery != null && searchQuery.isNotEmpty) {
          filteredProducts =
              cachedProducts
                  .where(
                    (product) =>
                        product.name.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ) ||
                        product.description.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ),
                  )
                  .toList();
        }

        return Right(
          ProductResponseModel(
            products: filteredProducts,
            pagination: Pagination(
              page: page,
              totalCount: filteredProducts.length,
              resultCount: filteredProducts.length,
              resultsPerPage: limit,
            ),
            isSuccessful: true,
            responseTime: DateTime.now().toIso8601String(),
            error: '',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
