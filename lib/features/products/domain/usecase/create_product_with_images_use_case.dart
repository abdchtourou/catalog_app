import 'dart:io';
import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class CreateProductWithImagesUseCase {
  final ProductRepository repository;

  CreateProductWithImagesUseCase(this.repository);

  Future<Either<Failure, Product>> call(
    String name,
    String description,
    String price,
    String categoryId,
    List<File> images,
  ) async {
    return await repository.createProductWithImages(
      name,
      description,
      price,
      categoryId,
      '0', // Default Syrian price, will be calculated by API
      images,
    );
  }
}
