import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/attachment.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:dartz/dartz.dart';

class GetSingleAttachmentUseCase {
  final ProductRepository repository;

  GetSingleAttachmentUseCase(this.repository);

  Future<Either<Failure, Attachment>> call(int attachmentId) async {
    return await repository.getAttachment(attachmentId);
  }
}
