import 'package:equatable/equatable.dart';

class Pagination extends Equatable {
  final int page;
  final int totalCount;
  final int resultCount;
  final int resultsPerPage;

  const Pagination({
    required this.page,
    required this.totalCount,
    required this.resultCount,
    required this.resultsPerPage,
  });

  bool get hasNextPage => page * resultsPerPage < totalCount;
  bool get hasPreviousPage => page > 1;
  int get totalPages => (totalCount / resultsPerPage).ceil();

  @override
  List<Object?> get props => [page, totalCount, resultCount, resultsPerPage];

  @override
  String toString() {
    return 'Pagination(page: $page, totalCount: $totalCount, resultCount: $resultCount, resultsPerPage: $resultsPerPage)';
  }
}
