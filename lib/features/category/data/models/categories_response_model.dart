import 'package:catalog_app/features/category/data/models/category_model.dart';
import 'package:catalog_app/features/category/data/models/pagination_model.dart';
import 'package:catalog_app/features/category/domain/entities/categories_response.dart';

class CategoriesResponseModel extends CategoriesResponse {
  const CategoriesResponseModel({
    required List<CategoryModel> super.categories,
    required PaginationModel super.pagination,
    required bool success,
    required super.responseTime,
  }) : super(isSuccessful: success);

  factory CategoriesResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoriesResponseModel(
      categories: (json['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      pagination: PaginationModel.fromJson(json),
      success: json['isSuccessful'],
      responseTime: json['responseTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories
          .map((e) => (e as CategoryModel).toJson())
          .toList(),
      'pagination': (pagination as PaginationModel).toJson(),
      'success': isSuccessful,
      'responseTime': responseTime,
    };
  }
}
