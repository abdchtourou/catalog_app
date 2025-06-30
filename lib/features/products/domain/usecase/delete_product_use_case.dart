import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteProduct(id);
  }
}
