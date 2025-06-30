import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/core/network/network_info.dart';
import 'package:catalog_app/features/category/data/datasources/local/category_local_data_source.dart';
import 'package:catalog_app/features/category/data/datasources/remote/category_remote_data_source.dart';
import 'package:catalog_app/features/category/data/models/categories_response_model.dart';
import 'package:catalog_app/features/category/data/models/category_model.dart';
import 'package:catalog_app/features/category/data/models/pagination_model.dart';
import 'package:catalog_app/features/category/domain/entities/category.dart';
import 'package:catalog_app/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;
  final CategoryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CategoriesResponseModel>> getCategories({
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteResponse = await remoteDataSource.getCategories(
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
        // Cache only the category list
        await localDataSource.cacheCategories(
          remoteResponse.categories.cast<CategoryModel>(),
        );
        return Right(remoteResponse);
      } else {
        final cachedCategories = await localDataSource.getCachedCategories();

        // Build a minimal response from cache
        return Right(
          CategoriesResponseModel(
            categories: cachedCategories,
            pagination: PaginationModel(
              page: 1,
              totalCount: cachedCategories.length,
              resultCount: cachedCategories.length,
              resultsPerPage: cachedCategories.length,
            ),
            success: true,
            responseTime: DateTime.now().toIso8601String(),
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CategoriesResponseModel>> getCategoriesByParent({
    int? parentId,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteResponse = await remoteDataSource.getCategoriesByParent(
          parentId: parentId,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
        // Cache the categories
        await localDataSource.cacheCategories(
          remoteResponse.categories.cast<CategoryModel>(),
        );
        return Right(remoteResponse);
      } else {
        final cachedCategories = await localDataSource.getCachedCategories();
        // Filter cached categories by parentId
        final filteredCategories =
            cachedCategories.where((category) {
              return parentId == null
                  ? category.parentId == null
                  : category.parentId == parentId;
            }).toList();

        return Right(
          CategoriesResponseModel(
            categories: filteredCategories,
            pagination: PaginationModel(
              page: 1,
              totalCount: filteredCategories.length,
              resultCount: filteredCategories.length,
              resultsPerPage: filteredCategories.length,
            ),
            success: true,
            responseTime: DateTime.now().toIso8601String(),
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int id) async {
    try {
      if (await networkInfo.isConnected) {
        var response = await remoteDataSource.deleteCategory(id);

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Category>> getCategory(int id) async {
    try {
      if (await networkInfo.isConnected) {
        var response = await remoteDataSource.getCategory(id);

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Category>> postCategory(
    String name,
    File image, {
    int? parentId,
    String? nameArabic,
    String? color,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        var response = await remoteDataSource.postCategory(
          name,
          image,
          parentId: parentId,
          nameArabic: nameArabic,
          color: color,
        );

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(
    int id,
    String name,
    File image, {
    int? parentId,
    String? nameArabic,
    String? color,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        var response = await remoteDataSource.updateCategory(
          id,
          name,
          image,
          parentId: parentId,
          nameArabic: nameArabic,
          color: color,
        );

        return Right(response);
      }
      return Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
