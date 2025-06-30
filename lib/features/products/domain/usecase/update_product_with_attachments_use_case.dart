import 'dart:io';
import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateProductWithAttachmentsUseCase {
  final ProductRepository repository;

  UpdateProductWithAttachmentsUseCase(this.repository);

  Future<Either<Failure, Product>> call(
    int id, {
    String? name,
    String? description,
    String? price,
    int? categoryId,
    List<File>? images,
  }) async {
    return await repository.updateProductWithAttachments(
      id,
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      images: images,
    );
  }
}
