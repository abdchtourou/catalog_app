import 'dart:io';

import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/category/domain/entities/category.dart';
import 'package:catalog_app/features/category/domain/repositories/category_repository.dart';
import 'package:dartz/dartz.dart';

class CreateCategoryUseCase {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<Either<Failure, Category>> call(
    String name,
    File image, {
    int? parentId,
    String? nameArabic,
    String? color,
  }) async {
    return await repository.postCategory(
      name,
      image,
      parentId: parentId,
      nameArabic: nameArabic,
      color: color,
    );
  }
}
