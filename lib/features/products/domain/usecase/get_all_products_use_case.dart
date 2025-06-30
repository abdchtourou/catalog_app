import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/products_response.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllProductsUseCase {
  final ProductRepository productRepository;

  GetAllProductsUseCase(this.productRepository);

  Future<Either<Failure, ProductsResponse>> call({
    int? pageNumber,
    int? pageSize,
  }) async {
    return await productRepository.getAllProducts(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
