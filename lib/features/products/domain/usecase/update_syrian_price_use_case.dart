import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateSyrianPriceUseCase {
  final ProductRepository repository;

  UpdateSyrianPriceUseCase(this.repository);

  Future<Either<Failure, Product>> call(
    int productId,
    String syrianPoundPrice,
  ) async {
    // First get the current product to preserve other details
    final productResult = await repository.getProduct(productId);

    return productResult.fold((failure) => Left(failure), (product) async {
      // Update the product with the new Syrian price while preserving other details
      return await repository.updateProduct(
        product.id,
        product.name,
        product.description,
        product.price,
        product.categoryId.toString(),
        syrianPoundPrice,
      );
    });
  }
}
