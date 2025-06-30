import 'dart:io';

import 'package:catalog_app/core/error/exception.dart';
import 'package:catalog_app/core/network/api_service.dart';
import 'package:catalog_app/core/utils/logger.dart';
import 'package:catalog_app/features/category/data/models/categories_response_model.dart';
import 'package:catalog_app/features/category/data/models/category_model.dart';
import 'package:catalog_app/features/category/data/models/pagination_model.dart';

abstract class CategoryRemoteDataSource {
  Future<CategoriesResponseModel> getCategories({
    int? pageNumber,
    int? pageSize,
  });

  // ✅ NEW: Get categories filtered by parentId
  Future<CategoriesResponseModel> getCategoriesByParent({
    int? parentId,
    int? pageNumber,
    int? pageSize,
  });

  Future<CategoryModel> getCategory(int id);
  Future<CategoryModel> postCategory(
    String name,
    File image, {
    int? parentId,
    String? nameArabic,
    String? color,
  });
  Future<void> updateCategory(
    int id,
    String name,
    File image, {
    int? parentId,
    String? nameArabic,
    String? color,
  });
  Future<void> deleteCategory(int id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiService apiService;

  CategoryRemoteDataSourceImpl(this.apiService);
  @override
  Future<CategoriesResponseModel> getCategories({
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final response = await apiService.get(
        '/Categories',
        queryParameters: {
          'pageNumber': pageNumber ?? 1,
          'pageSize': pageSize ?? 30,
        },
      );
      AppLogger.info('Get all categories response: ${response.toString()}');

      final categoriesResponse = CategoriesResponseModel.fromJson(
        response.data,
      );
      AppLogger.info(
        'Total categories fetched: ${categoriesResponse.categories.length}',
      );

      // Return all categories - filtering will be done at UI level
      return categoriesResponse;
    } catch (e) {
      AppLogger.error(e.toString());
      throw ServerException();
    }
  }

  @override
  Future<CategoriesResponseModel> getCategoriesByParent({
    int? parentId,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      AppLogger.info('Fetching categories with parentId: $parentId');

      // For now, we'll use the same endpoint and filter client-side
      // In a real implementation, the API should support parentId filtering
      final response = await apiService.get(
        '/Categories',
        queryParameters: {
          'pageNumber': pageNumber ?? 1,
          'pageSize': pageSize ?? 30,
        },
      );
      AppLogger.info(
        'Get categories by parent response: ${response.toString()}',
      );

      final categoriesResponse = CategoriesResponseModel.fromJson(
        response.data,
      );
      AppLogger.info(
        'Total categories fetched: ${categoriesResponse.categories.length}',
      );

      // Filter categories by parentId
      final filteredCategories =
          categoriesResponse.categories
              .where((category) {
                final matches =
                    parentId == null
                        ? category.parentId == null
                        : category.parentId == parentId;
                if (matches) {
                  AppLogger.info(
                    'Category ${category.id} (${category.name}) matches parentId filter',
                  );
                }
                return matches;
              })
              .toList()
              .cast<CategoryModel>();

      AppLogger.info('Filtered categories count: ${filteredCategories.length}');

      // Return filtered response
      return CategoriesResponseModel(
        categories: filteredCategories,
        pagination: categoriesResponse.pagination as PaginationModel,
        success: categoriesResponse.isSuccessful,
        responseTime: categoriesResponse.responseTime,
      );
    } catch (e) {
      AppLogger.error('Error getting categories by parent: ${e.toString()}');
      throw ServerException();
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      final response = await apiService.delete('/Categories/$id');

      AppLogger.info(response.toString());
      return;
    } catch (e) {
      AppLogger.error(e.toString());
      throw ServerException();
    }
  }

  @override
  Future<CategoryModel> getCategory(int id) async {
    try {
      final response = await apiService.get('/Categories/$id');

      AppLogger.info(response.toString());
      return CategoryModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error(e.toString());
      throw ServerException();
    }
  }

  @override
  Future<CategoryModel> postCategory(
    String name,
    File image, {
    int? parentId,
    String? nameArabic,
    String? color,
  }) async {
    try {
      final data = {'Id': 0, 'Name': name};

      if (parentId != null) {
        data['ParentId'] = parentId;
      }
      if (nameArabic != null) {
        data['NameArabic'] = nameArabic;
      }
      if (color != null) {
        data['Color'] = color;
      }

      final response = await apiService.uploadFile(
        '/Categories',
        image.path,
        data: data,
      );

      AppLogger.info(response.toString());
      return CategoryModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error(e.toString());
      throw ServerException();
    }
  }

  @override
  Future<void> updateCategory(
    int id,
    String name,
    File image, {
    int? parentId,
    String? nameArabic,
    String? color,
  }) async {
    try {
      final data = {'Id': id, 'Name': name};

      if (parentId != null) {
        data['ParentId'] = parentId;
      }
      if (nameArabic != null) {
        data['NameArabic'] = nameArabic;
      }
      if (color != null) {
        data['Color'] = color;
      }

      final response = await apiService.updateUploadedFile(
        '/Categories',
        image.path,
        data: data,
      );

      AppLogger.info(response.toString());
      return;
    } catch (e) {
      AppLogger.error(e.toString());
      throw ServerException();
    }
  }
}
