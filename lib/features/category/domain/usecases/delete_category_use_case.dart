import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/category/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteCategory(id);
  }
}
