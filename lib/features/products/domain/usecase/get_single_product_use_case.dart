import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class GetSingleProductUseCase {
  final ProductRepository productRepository;

  GetSingleProductUseCase(this.productRepository);

  Future<Either<Failure, Product>> call(int productId) async {
    return await productRepository.getProduct(productId);
  }
}
