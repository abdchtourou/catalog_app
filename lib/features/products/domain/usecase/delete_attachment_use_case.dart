import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteAttachmentUseCase {
  final ProductRepository repository;

  DeleteAttachmentUseCase(this.repository);

  Future<Either<Failure, void>> call(int attachmentId) async {
    return await repository.deleteAttachment(attachmentId);
  }
}

class DeleteAttachmentsUseCase {
  final ProductRepository repository;

  DeleteAttachmentsUseCase(this.repository);

  Future<Either<Failure, void>> call(List<int> attachmentIds) async {
    return await repository.deleteAttachments(attachmentIds);
  }
}
