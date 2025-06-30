import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(
    int id,
    String name,
    String description,
    String price,
    String categoryId,
    String syrianPoundPrice,
  ) async {
    return await repository.updateProduct(
      id,
      name,
      description,
      price,
      categoryId,
      syrianPoundPrice,
    );
  }
}
