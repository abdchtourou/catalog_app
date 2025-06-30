import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/category/domain/entities/categories_response.dart';
import 'package:catalog_app/features/category/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, CategoriesResponse>> call({
    int? pageNumber,
    int? pageSize,
  }) async {
    return await repository.getCategories(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
