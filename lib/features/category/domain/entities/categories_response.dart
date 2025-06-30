import 'category.dart';
import 'package:equatable/equatable.dart';

import 'pagination.dart';

class CategoriesResponse extends Equatable {
  final List<Category> categories;
  final Pagination pagination;
  final bool isSuccessful;
  final String responseTime;

  const CategoriesResponse({
    required this.categories,
    required this.pagination,
    required this.isSuccessful,
    required this.responseTime,
  });

  @override
  List<Object?> get props => [
    categories,
    pagination,
    isSuccessful,
    responseTime,
  ];

  @override
  String toString() {
    return 'CategoriesResponse(categories: $categories, pagination: $pagination, error: , isSuccessful: $isSuccessful, responseTime: $responseTime)';
  }
}
