import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/category/domain/entities/categories_response.dart';
import 'package:catalog_app/features/category/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class GetCategoriesByParentUseCase {
  final CategoryRepository repository;

  GetCategoriesByParentUseCase(this.repository);

  Future<Either<Failure, CategoriesResponse>> call({
    int? parentId,
    int? pageNumber,
    int? pageSize,
  }) async {
    return await repository.getCategoriesByParent(
      parentId: parentId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
