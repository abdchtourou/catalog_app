import 'package:catalog_app/features/category/domain/entities/pagination.dart';

class PaginationModel extends Pagination {
  const PaginationModel({
    required super.page,
    required super.totalCount,
    required super.resultCount,
    required super.resultsPerPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'],
      totalCount: json['totalCount'],
      resultCount: json['resultCount'],
      resultsPerPage: json['resultsPerPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'totalCount': totalCount,
      'resultCount': resultCount,
      'resultsPerPage': resultsPerPage,
    };
  }
}
