import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/products_response.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllProductsWithSearchUseCase {
  final ProductRepository productRepository;

  GetAllProductsWithSearchUseCase(this.productRepository);

  Future<Either<Failure, ProductsResponse>> call({
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  }) async {
    return await productRepository.getAllProductsWithSearch(
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchQuery: searchQuery,
    );
  }
}
