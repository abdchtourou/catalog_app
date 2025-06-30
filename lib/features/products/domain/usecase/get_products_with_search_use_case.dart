import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/products_response.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class GetProductsWithSearchUseCase {
  final ProductRepository productRepository;

  GetProductsWithSearchUseCase(this.productRepository);

  Future<Either<Failure, ProductsResponse>> call(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  }) async {
    return await productRepository.getProductsWithSearch(
      categoryId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchQuery: searchQuery,
    );
  }
}
