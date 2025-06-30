import 'package:catalog_app/features/category/data/models/pagination_model.dart';
import 'package:catalog_app/features/products/data/model/product_model.dart';
import 'package:catalog_app/features/products/domain/entities/products_response.dart';

class ProductResponseModel extends ProductsResponse {
  const ProductResponseModel({
    required super.products,
    required super.pagination,
    required super.isSuccessful,
    required super.responseTime,
    required super.error,
  });
  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductResponseModel(
      products:
          (json['data'] as List?)
              ?.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      pagination: PaginationModel.fromJson(json),
      isSuccessful: json['isSuccessful'] ?? false,
      responseTime: json['responseTime']?.toString() ?? '',
      error: json['error']?.toString() ?? '',
    );
  }
}
