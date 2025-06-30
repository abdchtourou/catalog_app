import 'dart:io';
import 'package:catalog_app/core/error/failure.dart';
import 'package:catalog_app/features/products/domain/entities/attachment.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/entities/products_response.dart';
import 'package:dartz/dartz.dart';

abstract class ProductRepository {
  // Product operations
  Future<Either<Failure, ProductsResponse>> getProducts(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
  });

  // Get products with search functionality
  Future<Either<Failure, ProductsResponse>> getProductsWithSearch(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  });

  // Get all products across all categories
  Future<Either<Failure, ProductsResponse>> getAllProducts({
    int? pageNumber,
    int? pageSize,
  });

  // Get all products with search functionality across all categories
  Future<Either<Failure, ProductsResponse>> getAllProductsWithSearch({
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  });

  Future<Either<Failure, Product>> getProduct(int id);

  // Create product with images (POST /products with files)
  Future<Either<Failure, Product>> createProductWithImages(
    String name,
    String description,
    String price,
    String categoryId,
    String syrianPoundPrice,
    List<File> images,
  );

  // Update product data only (PUT /products without images)
  Future<Either<Failure, Product>> updateProduct(
    int id,
    String name,
    String description,
    String price,
    String categoryId,
    String syrianPoundPrice,
  );

  // Update product with attachments (POST /products/UpdateWithAttachments)
  Future<Either<Failure, Product>> updateProductWithAttachments(
    int id, {
    String? name,
    String? description,
    String? price,
    int? categoryId,
    List<File>? images,
  });

  Future<Either<Failure, void>> deleteProduct(int id);

  // Attachment operations
  // Get single attachment (GET /attachments/{id})
  Future<Either<Failure, Attachment>> getAttachment(int attachmentId);

  // Create attachment for existing product (POST /attachments)
  Future<Either<Failure, Attachment>> createAttachment(
    int productId,
    File imageFile,
  );

  // Delete specific attachment (DELETE /attachments/{id})
  Future<Either<Failure, void>> deleteAttachment(int attachmentId);

  // Delete multiple attachments
  Future<Either<Failure, void>> deleteAttachments(List<int> attachmentIds);
}
