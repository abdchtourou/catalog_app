import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/category/domain/entities/category.dart';
import 'package:catalog_app/features/category/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class GetSingleCategoryUseCase {
  final CategoryRepository repository;

  GetSingleCategoryUseCase(this.repository);

  Future<Either<Failure, Category>> call(int categoryId) async {
    return await repository.getCategory(categoryId);
  }
}
