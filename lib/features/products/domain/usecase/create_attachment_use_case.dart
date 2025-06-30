import 'dart:io';
import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/attachment.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class CreateAttachmentUseCase {
  final ProductRepository repository;

  CreateAttachmentUseCase(this.repository);

  Future<Either<Failure, Attachment>> call(
    int productId,
    File imageFile,
  ) async {
    return await repository.createAttachment(productId, imageFile);
  }
}
