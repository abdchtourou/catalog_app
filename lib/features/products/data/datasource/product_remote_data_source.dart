import 'dart:io';
import 'package:catalog_app/core/error/exception.dart';
import 'package:catalog_app/core/network/api_service.dart';
import 'package:catalog_app/core/utils/logger.dart';
import 'package:catalog_app/features/products/data/model/attachment_model.dart';
import 'package:catalog_app/features/products/data/model/product_model.dart';
import 'package:catalog_app/features/products/data/model/product_response_model.dart';
import 'package:dio/dio.dart';

abstract class ProductRemoteDataSource {
  // Product operations
  Future<ProductResponseModel> getProducts(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
  });

  // Get products with search functionality
  Future<ProductResponseModel> getProductsWithSearch(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  });

  // Get all products across all categories
  Future<ProductResponseModel> getAllProducts({int? pageNumber, int? pageSize});

  // Get all products with search functionality across all categories
  Future<ProductResponseModel> getAllProductsWithSearch({
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  });

  Future<ProductModel> getProduct(int id);

  // Create product with images (POST /products with files)
  Future<ProductModel> createProductWithImages(
    String name,
    String description,
    String price,
    String categoryId,
    List<File> images,
  );

  // Update product data only (PUT /products without images)
  Future<ProductModel> updateProduct(
    int id,
    String name,
    String description,
    String price,
    String categoryId,
    String syrianPoundPrice,
  );

  // Update product with attachments (POST /products/UpdateWithAttachments)
  Future<ProductModel> updateProductWithAttachments(
    int id, {
    String? name,
    String? description,
    String? price,
    int? categoryId,
    List<File>? images,
  });

  Future<void> deleteProduct(int id);

  // Attachment operations
  // Get single attachment (GET /attachments/{id})
  Future<AttachmentModel> getAttachment(int attachmentId);

  // Create attachment for existing product (POST /attachments)
  Future<AttachmentModel> createAttachment(int productId, File imageFile);

  // Delete specific attachment (DELETE /attachments/{id})
  Future<void> deleteAttachment(int attachmentId);

  // Delete multiple attachments (DELETE /attachments with list)
  Future<void> deleteAttachments(List<int> attachmentIds);
}

class ProductRemoteDataSourceImpl extends ProductRemoteDataSource {
  final ApiService apiService;
  ProductRemoteDataSourceImpl(this.apiService);

  @override
  Future<ProductResponseModel> getProducts(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final endpoint = '/Categories/$categoryId/products';
      final queryParams = {
        'pageNumber': pageNumber ?? 1,
        'pageSize': pageSize ?? 10,
      };

      AppLogger.info('🔍 Fetching products for categoryId: $categoryId');
      AppLogger.info('📡 API Endpoint: $endpoint');
      AppLogger.info('📋 Query Parameters: $queryParams');

      final response = await apiService.get(
        endpoint,
        queryParameters: queryParams,
      );

      AppLogger.info('✅ Get products response status: ${response.statusCode}');
      AppLogger.info('📦 Get products response data: ${response.data}');

      return ProductResponseModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error(
        '❌ Error getting products for categoryId: $categoryId',
        e,
      );
      throw ServerException();
    }
  }

  @override
  Future<ProductResponseModel> getProductsWithSearch(
    String categoryId, {
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'pageNumber': pageNumber ?? 1,
        'pageSize': pageSize ?? 10,
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParameters['searchQuery'] = searchQuery;
      }

      final response = await apiService.get(
        '/Categories/$categoryId/products',
        queryParameters: queryParameters,
      );
      AppLogger.info(
        'Get products with search response: ${response.toString()}',
      );
      return ProductResponseModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Error getting products with search', e);
      throw ServerException();
    }
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await apiService.get('/products/$id');

      AppLogger.info('Get product response: ${response.toString()}');

      // Extract the 'data' field from the API response
      final productData = response.data['data'];
      if (productData == null) {
        AppLogger.error('Product data is null in API response', null);
        throw ServerException();
      }

      AppLogger.info('Parsing product data: ${productData.toString()}');
      return ProductModel.fromJson(productData);
    } catch (e) {
      AppLogger.error('Error getting product', e);
      throw ServerException();
    }
  }

  @override
  Future<ProductModel> updateProduct(
    int id,
    String name,
    String description,
    String price,
    String categoryId,
    String syrianPoundPrice,
  ) async {
    var body = ProductModel(
      hiveId: id,
      hiveName: name,
      hiveDescription: description,
      hivePrice: price,
      hiveCategoryId: int.parse(categoryId),
      hiveSyrianPoundPrice: syrianPoundPrice,
      hiveAttachments:
          [], // Empty attachments for update (images handled separately)
    );

    try {
      final response = await apiService.put(
        '/products/$id',
        data: body.toJson(),
      );

      AppLogger.info('Update product response: ${response.toString()}');

      // Check if response has 'data' field like individual product response
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        return ProductModel.fromJson(responseData['data']);
      } else {
        // Fallback to direct parsing if no 'data' field
        return ProductModel.fromJson(responseData);
      }
    } catch (e) {
      AppLogger.error('Error updating product', e);
      throw ServerException();
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      final response = await apiService.delete('/products/$id');

      AppLogger.info('Delete product response: ${response.toString()}');
      return;
    } catch (e) {
      AppLogger.error('Error deleting product', e);
      throw ServerException();
    }
  }

  @override
  Future<ProductModel> createProductWithImages(
    String name,
    String description,
    String price,
    String categoryId,
    List<File> images,
  ) async {
    try {
      // Create FormData with only images (product data goes in query parameters)
      final Map<String, dynamic> formDataMap = {};

      // Add images to form data as a list
      final List<MultipartFile> imageFiles = [];
      for (int i = 0; i < images.length; i++) {
        imageFiles.add(
          await MultipartFile.fromFile(
            images[i].path,
            filename: 'image_$i.jpg',
          ),
        );
      }

      if (imageFiles.isNotEmpty) {
        formDataMap['Images'] = imageFiles;
      }

      final formData = FormData.fromMap(formDataMap);

      // Product data goes as query parameters, not form data
      final queryParameters = {
        'Name': name,
        'Description': description,
        'Price': price,
        'CategoryId': categoryId,
      };

      // Create options without any Content-Type header to let Dio handle FormData properly
      final response = await apiService.post(
        '/products',
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          contentType: null, // Let Dio determine content type automatically
          headers: {}, // Empty headers to avoid conflicts
        ),
      );

      AppLogger.info(
        'Create product with images response: ${response.toString()}',
      );

      // Check if response has 'data' field like individual product response
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        return ProductModel.fromJson(responseData['data']);
      } else {
        // Fallback to direct parsing if no 'data' field
        return ProductModel.fromJson(responseData);
      }
    } catch (e) {
      AppLogger.error('Error creating product with images', e);
      throw ServerException();
    }
  }

  @override
  Future<AttachmentModel> createAttachment(
    int productId,
    File imageFile,
  ) async {
    try {
      final formData = FormData.fromMap({
        'ProductId': productId,
        'File': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'attachment.jpg',
        ),
      });

      final response = await apiService.post(
        '/attachments',
        data: formData,
        options: Options(
          contentType: null, // Let Dio determine content type automatically
          headers: {}, // Empty headers to avoid conflicts
        ),
      );

      AppLogger.info('Create attachment response: ${response.toString()}');

      // Check if response has 'data' field like individual product response
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        return AttachmentModel.fromJson(responseData['data']);
      } else {
        // Fallback to direct parsing if no 'data' field
        return AttachmentModel.fromJson(responseData);
      }
    } catch (e) {
      AppLogger.error('Error creating attachment', e);
      throw ServerException();
    }
  }

  @override
  Future<void> deleteAttachment(int attachmentId) async {
    try {
      final response = await apiService.delete('/attachments/$attachmentId');

      AppLogger.info('Delete attachment response: ${response.toString()}');
      return;
    } catch (e) {
      AppLogger.error('Error deleting attachment', e);
      throw ServerException();
    }
  }

  @override
  Future<AttachmentModel> getAttachment(int attachmentId) async {
    try {
      final response = await apiService.get('/attachments/$attachmentId');

      AppLogger.info('Get attachment response: ${response.toString()}');

      // Extract the 'data' field from the API response
      final attachmentData = response.data['data'];
      if (attachmentData == null) {
        AppLogger.error('Attachment data is null in API response', null);
        throw ServerException();
      }

      AppLogger.info('Parsing attachment data: ${attachmentData.toString()}');
      return AttachmentModel.fromJson(attachmentData);
    } catch (e) {
      AppLogger.error('Error getting attachment', e);
      throw ServerException();
    }
  }

  @override
  Future<void> deleteAttachments(List<int> attachmentIds) async {
    try {
      final response = await apiService.delete(
        '/attachments',
        data: attachmentIds,
      );

      AppLogger.info('Delete attachments response: ${response.toString()}');
      return;
    } catch (e) {
      AppLogger.error('Error deleting attachments', e);
      throw ServerException();
    }
  }

  @override
  Future<ProductModel> updateProductWithAttachments(
    int id, {
    String? name,
    String? description,
    String? price,
    int? categoryId,
    List<File>? images,
  }) async {
    try {
      AppLogger.info('Updating product $id with attachments');
      AppLogger.info('Images count: ${images?.length ?? 0}');

      // Create FormData with all images
      final Map<String, dynamic> formDataMap = {};
      final List<MultipartFile> imageFiles = [];

      // Process all images uniformly as File objects
      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          try {
            imageFiles.add(
              await MultipartFile.fromFile(
                images[i].path,
                filename: 'image_$i.jpg',
              ),
            );
          } catch (e) {
            AppLogger.error('Error processing image $i: $e');
            // Continue with other images even if one fails
          }
        }
      }

      // Add all images to form data if we have any
      if (imageFiles.isNotEmpty) {
        formDataMap['Images'] = imageFiles;
        AppLogger.info('Total images to upload: ${imageFiles.length}');
      }

      final formData = FormData.fromMap(formDataMap);

      // Product data goes as form fields
      final Map<String, dynamic> requestData = {'Id': id};
      if (name != null) requestData['Name'] = name;
      if (description != null) requestData['Description'] = description;
      if (price != null) requestData['Price'] = price;
      if (categoryId != null) requestData['CategoryId'] = categoryId;

      // Add product data to form data
      requestData.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      AppLogger.info('Sending update request with data: $requestData');

      final response = await apiService.post(
        '/products/UpdateWithAttachments',
        data: formData,
        options: Options(
          contentType: null, // Let Dio determine content type automatically
          headers: {}, // Empty headers to avoid conflicts
        ),
      );

      AppLogger.info('Update product response status: ${response.statusCode}');
      AppLogger.info('Update product response data: ${response.data}');

      // Handle 204 No Content response
      if (response.statusCode == 204) {
        AppLogger.info('Received 204 No Content - update successful');

        // Since we don't get the updated product back, we need to fetch it
        // or construct it from the request data
        try {
          // Fetch the updated product to return the latest data
          final updatedProduct = await getProduct(id);
          AppLogger.info(
            'Successfully fetched updated product after 204 response',
          );
          return updatedProduct;
        } catch (e) {
          AppLogger.error(
            'Error fetching updated product after 204 response: $e',
          );

          // Fallback: construct a basic product model from available data
          // This is a last resort if we can't fetch the updated product
          return ProductModel(
            hiveId: id,
            hiveName: name ?? 'Updated Product',
            hiveDescription: description ?? 'Updated Description',
            hivePrice: price ?? '0',
            hiveCategoryId: categoryId ?? 0,
            hiveSyrianPoundPrice:
                '0', // Default value, will be calculated by API
            hiveAttachments:
                [], // Will be empty since we can't determine the final state
          );
        }
      }

      // Handle responses with content (200, 201, etc.)
      final responseData = response.data;
      if (responseData != null) {
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            AppLogger.info('Parsing response from data field');
            return ProductModel.fromJson(responseData['data']);
          } else {
            AppLogger.info('Parsing response directly');
            return ProductModel.fromJson(responseData);
          }
        }
      }

      // If we reach here, something unexpected happened
      AppLogger.error('Unexpected response format: ${response.data}');
      throw ServerException();
    } catch (e) {
      AppLogger.error('Error updating product with attachments: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<ProductResponseModel> getAllProducts({
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final endpoint = '/products';
      final queryParams = {
        'pageNumber': pageNumber ?? 1,
        'pageSize': pageSize ?? 10,
      };

      final response = await apiService.get(
        endpoint,
        queryParameters: queryParams,
      );
      AppLogger.info('Get all products response: ${response.toString()}');
      return ProductResponseModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Error getting all products', e);
      throw ServerException();
    }
  }

  @override
  Future<ProductResponseModel> getAllProductsWithSearch({
    int? pageNumber,
    int? pageSize,
    String? searchQuery,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'pageNumber': pageNumber ?? 1,
        'pageSize': pageSize ?? 10,
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParameters['searchQuery'] = searchQuery;
      }

      final response = await apiService.get(
        '/products',
        queryParameters: queryParameters,
      );
      AppLogger.info(
        'Get all products with search response: ${response.toString()}',
      );
      return ProductResponseModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Error getting all products with search', e);
      throw ServerException();
    }
  }
}
