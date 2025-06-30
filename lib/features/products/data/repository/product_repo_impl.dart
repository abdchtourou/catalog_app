import 'dart:io';
import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/core/network/network_info.dart';
import 'package:catalog_app/features/category/domain/entities/pagination.dart';
import 'package:catalog_app/features/products/data/datasource/product_local_data_source.dart';
import 'package:catalog_app/features/products/data/datasource/product_remote_data_source.dart';
import 'package:catalog_app/features/products/data/model/product_model.dart';
import 'package:catalog_app/features/products/data/model/product_response_model.dart';
import 'package:catalog_app/features/products/domain/entities/attachment.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/entities/products_response.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class ProductRepoImpl extends ProductRepository {
  final ProductRemoteDataSource productRemoteDataSource;
  final ProductLocalDataSource productLocalDataSource;
  final NetworkInfo networkInfo;
  ProductRepoImpl({
    required this.productRemoteDataSource,
    required this.productLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProductsResponse>> getProducts(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        return await _getAndCacheProducts(
          categoryId,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
      } else {
        return await _getCachedProducts(categoryId);
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
      if (await networkInfo.isConnected) {
        return await _getAndCacheProductsWithSearch(
          categoryId,
          pageNumber: pageNumber,
          pageSize: pageSize,
          searchQuery: searchQuery,
        );
      } else {
        return await _getCachedProducts(categoryId);
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, ProductsResponse>> _getAndCacheProducts(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
  }) async {
    final response = await productRemoteDataSource.getProducts(
      categoryId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    final productModels =
        response.products.map((e) => ProductModel.fromEntity(e)).toList();

    // Cache products by category
    await productLocalDataSource.cacheProductsByCategory(
      categoryId,
      productModels,
    );

    // Also cache individual products for faster detail access
    for (final productModel in productModels) {
      await productLocalDataSource.cacheProduct(productModel);
    }

    return Right(response);
  }

  Future<Either<Failure, ProductsResponse>> _getAndCacheProductsWithSearch(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  }) async {
    final response = await productRemoteDataSource.getProductsWithSearch(
      categoryId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchQuery: searchQuery,
    );

    final productModels =
        response.products.map((e) => ProductModel.fromEntity(e)).toList();

    // Cache products by category
    await productLocalDataSource.cacheProductsByCategory(
      categoryId,
      productModels,
    );

    // Also cache individual products for faster detail access
    for (final productModel in productModels) {
      await productLocalDataSource.cacheProduct(productModel);
    }

    return Right(response);
  }

  Future<Either<Failure, ProductsResponse>> _getCachedProducts(
    String categoryId,
  ) async {
    try {
      final cachedProducts = (await productLocalDataSource
          .getCachedProductsByCategory(categoryId));
      return Right(
        ProductResponseModel(
          products: cachedProducts,
          isSuccessful: true,
          responseTime: DateTime.now().toIso8601String(),
          pagination: Pagination(
            page: 1,
            totalCount: 1,
            resultCount: 1,
            resultsPerPage: 1,
          ),
          error: '',
        ),
      );
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(int id) async {
    try {
      // First, try to get from cache if it's valid
      final cachedProduct = await productLocalDataSource.getCachedProduct(id);
      if (cachedProduct != null) {
        // Return cached product immediately for better performance
        return Right(cachedProduct);
      }

      // If not in cache or expired, fetch from network only if connected
      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.getProduct(id);

        // Cache the fetched product for future use
        await productLocalDataSource.cacheProduct(
          ProductModel.fromEntity(response),
        );

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
        await productLocalDataSource.removeCachedProduct(id);
        await productLocalDataSource.invalidateCache();

        // Cache the updated product
        await productLocalDataSource.cacheProduct(
          ProductModel.fromEntity(response),
        );

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

        // Remove the specific product from cache and invalidate category cache
        await productLocalDataSource.removeCachedProduct(id);
        await productLocalDataSource.invalidateCache();

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  // New methods for proper backend integration
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

        await productLocalDataSource.invalidateCache();

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
    File imageFile,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final response = await productRemoteDataSource.createAttachment(
          productId,
          imageFile,
        );

        // Invalidate cache to refresh product data
        await productLocalDataSource.removeCachedProduct(productId);
        await productLocalDataSource.invalidateCache();

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
        await productRemoteDataSource.deleteAttachment(attachmentId);

        // Invalidate cache to refresh product data
        await productLocalDataSource.invalidateCache();

        return const Right(null);
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
        // Use the bulk delete method from remote data source
        await productRemoteDataSource.deleteAttachments(attachmentIds);

        // Invalidate cache to refresh product data
        await productLocalDataSource.invalidateCache();

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
        await productLocalDataSource.removeCachedProduct(id);
        await productLocalDataSource.invalidateCache();

        // Cache the updated product
        await productLocalDataSource.cacheProduct(
          ProductModel.fromEntity(response),
        );

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ProductsResponse>> getAllProducts({
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        return await _getAndCacheAllProducts(
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
      } else {
        return await _getCachedAllProducts();
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
      if (await networkInfo.isConnected) {
        return await _getAndCacheAllProductsWithSearch(
          pageNumber: pageNumber,
          pageSize: pageSize,
          searchQuery: searchQuery,
        );
      } else {
        return await _getCachedAllProducts();
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, ProductsResponse>> _getAndCacheAllProducts({
    int? pageNumber,
    int? pageSize,
  }) async {
    final response = await productRemoteDataSource.getAllProducts(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    final productModels =
        response.products.map((e) => ProductModel.fromEntity(e)).toList();

    // Cache individual products for faster detail access
    for (final productModel in productModels) {
      await productLocalDataSource.cacheProduct(productModel);
    }

    return Right(response);
  }

  Future<Either<Failure, ProductsResponse>> _getAndCacheAllProductsWithSearch({
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  }) async {
    final response = await productRemoteDataSource.getAllProductsWithSearch(
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchQuery: searchQuery,
    );

    final productModels =
        response.products.map((e) => ProductModel.fromEntity(e)).toList();

    // Cache individual products for faster detail access
    for (final productModel in productModels) {
      await productLocalDataSource.cacheProduct(productModel);
    }

    return Right(response);
  }

  Future<Either<Failure, ProductsResponse>> _getCachedAllProducts() async {
    try {
      // For now, return empty list since we don't have a method to get all cached products
      // This is a fallback for offline mode - in practice, users would need to visit
      // categories first to cache products
      final response = ProductResponseModel(
        products: const [],
        pagination: const Pagination(
          page: 1,
          totalCount: 0,
          resultCount: 0,
          resultsPerPage: 20,
        ),
        isSuccessful: true,
        responseTime: DateTime.now().toIso8601String(),
        error: '',
      );

      return Right(response);
    } catch (e) {
      return Left(EmptyCacheFailure());
    }
  }
}
