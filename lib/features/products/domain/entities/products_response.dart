import 'package:catalog_app/features/category/domain/entities/pagination.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

class ProductsResponse extends Equatable {
  final List<Product> products;
  final Pagination pagination;
  final bool isSuccessful;
  final String responseTime;
  final String error;

  const ProductsResponse({
    required this.products,
    required this.pagination,
    required this.isSuccessful,
    required this.responseTime,
    required this.error,
  });

  @override
  List<Object?> get props => [
    products,
    pagination,
    isSuccessful,
    responseTime,
    error,
  ];
}
