import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/products_response.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class GetProductsUseCase {
  final ProductRepository productRepository;

  GetProductsUseCase(this.productRepository);

  Future<Either<Failure, ProductsResponse>> call(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
  }) async {
    return await productRepository.getProducts(
      categoryId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
