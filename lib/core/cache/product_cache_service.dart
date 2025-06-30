import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/products/data/model/product_model.dart';
import '../../features/products/domain/entities/product.dart';

class ProductCacheService {
  static const String _productCacheBoxName = 'productCacheBox';
  static const String _productMetadataBoxName = 'productMetadataBox';
  static const Duration _defaultCacheExpiry = Duration(hours: 6);

  static Box<ProductModel>? _cacheBox;
  static Box<Map>? _metadataBox;

  static Future<void> initialize() async {
    try {
      _cacheBox = await Hive.openBox<ProductModel>(_productCacheBoxName);
      _metadataBox = await Hive.openBox<Map>(_productMetadataBoxName);
      debugPrint('Product cache initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize product cache: $e');
    }
  }

  // Generate cache key for product
  static String _generateProductKey(int productId) {
    return 'product_$productId';
  }

  // Generate cache key for product list
  static String _generateListKey({
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 10,
  }) {
    final parts = [
      'products',
      if (categoryId != null) 'cat_$categoryId',
      if (searchQuery != null && searchQuery.isNotEmpty)
        'search_${searchQuery.toLowerCase()}',
      'page_$page',
      'limit_$limit',
    ];
    return parts.join('_');
  }

  // Check if cache is valid
  static bool _isCacheValid(String cacheKey) {
    if (_metadataBox == null) return false;

    final metadata = _metadataBox!.get(cacheKey);
    if (metadata == null) return false;

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(
      metadata['expiry'] ?? 0,
    );

    return DateTime.now().isBefore(expiryTime);
  }

  // Store cache metadata
  static Future<void> _storeCacheMetadata(
    String cacheKey, {
    Map<String, dynamic>? extraData,
  }) async {
    if (_metadataBox == null) return;

    final expiryTime = DateTime.now().add(_defaultCacheExpiry);

    final metadata = {
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiryTime.millisecondsSinceEpoch,
      'version': 1,
      ...?extraData,
    };

    await _metadataBox!.put(cacheKey, metadata);
  }

  // Cache single product
  static Future<void> cacheProduct(Product product) async {
    try {
      if (_cacheBox == null) return;

      final productModel = ProductModel.fromEntity(product);

      final key = _generateProductKey(product.id);
      await _cacheBox!.put(key, productModel);

      await _storeCacheMetadata(
        key,
        extraData: {'type': 'single_product', 'productId': product.id},
      );

      debugPrint('Cached product: ${product.name} (ID: ${product.id})');
    } catch (e) {
      debugPrint('Failed to cache product: $e');
    }
  }

  // Cache product list
  static Future<void> cacheProductList(
    List<Product> products, {
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 10,
    int? totalCount,
  }) async {
    try {
      if (_cacheBox == null) return;

      // Cache individual products
      for (final product in products) {
        await cacheProduct(product);
      }

      // Cache list metadata
      final listKey = _generateListKey(
        categoryId: categoryId,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
      );

      await _storeCacheMetadata(
        listKey,
        extraData: {
          'type': 'product_list',
          'categoryId': categoryId,
          'searchQuery': searchQuery,
          'page': page,
          'limit': limit,
          'count': products.length,
          'totalCount': totalCount,
          'productIds': products.map((p) => p.id).toList(),
        },
      );

      debugPrint('Cached product list: ${products.length} products');
    } catch (e) {
      debugPrint('Failed to cache product list: $e');
    }
  }

  // Get cached product
  static Product? getCachedProduct(int productId) {
    try {
      if (_cacheBox == null) return null;

      final key = _generateProductKey(productId);

      if (!_isCacheValid(key)) {
        return null;
      }

      final productModel = _cacheBox!.get(key);
      if (productModel == null) return null;

      return Product(
        id: productModel.id,
        name: productModel.name,
        description: productModel.description,
        price: productModel.price,
        categoryId: productModel.categoryId,
        attachments: productModel.attachments.cast(),
        syrianPoundPrice: productModel.syrianPoundPrice,
      );
    } catch (e) {
      debugPrint('Failed to get cached product: $e');
      return null;
    }
  }

  // Get cached product list
  static Future<List<Product>?> getCachedProductList({
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      if (_cacheBox == null || _metadataBox == null) return null;

      final listKey = _generateListKey(
        categoryId: categoryId,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
      );

      if (!_isCacheValid(listKey)) {
        return null;
      }

      final metadata = _metadataBox!.get(listKey);
      if (metadata == null) return null;

      final productIds = List<int>.from(metadata['productIds'] ?? []);
      final products = <Product>[];

      for (final productId in productIds) {
        final product = getCachedProduct(productId);
        if (product != null) {
          products.add(product);
        }
      }

      // Return null if we don't have all cached products
      if (products.length != productIds.length) {
        return null;
      }

      debugPrint('Retrieved ${products.length} cached products');
      return products;
    } catch (e) {
      debugPrint('Failed to get cached product list: $e');
      return null;
    }
  }

  // Check if product is cached
  static bool isProductCached(int productId) {
    if (_cacheBox == null) return false;

    final key = _generateProductKey(productId);
    return _isCacheValid(key) && _cacheBox!.containsKey(key);
  }

  // Check if product list is cached
  static bool isProductListCached({
    int? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 10,
  }) {
    if (_metadataBox == null) return false;

    final listKey = _generateListKey(
      categoryId: categoryId,
      searchQuery: searchQuery,
      page: page,
      limit: limit,
    );

    return _isCacheValid(listKey);
  }

  // Remove product from cache
  static Future<void> removeCachedProduct(int productId) async {
    try {
      if (_cacheBox == null) return;

      final key = _generateProductKey(productId);
      await _cacheBox!.delete(key);
      await _metadataBox?.delete(key);

      debugPrint('Removed cached product: $productId');
    } catch (e) {
      debugPrint('Failed to remove cached product: $e');
    }
  }

  // Clear all cached products
  static Future<void> clearAllCache() async {
    try {
      await _cacheBox?.clear();
      await _metadataBox?.clear();
      debugPrint('Cleared all product cache');
    } catch (e) {
      debugPrint('Failed to clear product cache: $e');
    }
  }

  // Clear expired cache entries
  static Future<void> clearExpiredCache() async {
    try {
      if (_metadataBox == null) return;

      final keysToDelete = <String>[];

      for (final key in _metadataBox!.keys) {
        if (!_isCacheValid(key)) {
          keysToDelete.add(key);
        }
      }

      // Remove expired metadata
      for (final key in keysToDelete) {
        await _metadataBox!.delete(key);

        // If it's a single product, also remove from product cache
        if (key.startsWith('product_')) {
          await _cacheBox?.delete(key);
        }
      }

      debugPrint('Cleared ${keysToDelete.length} expired cache entries');
    } catch (e) {
      debugPrint('Failed to clear expired cache: $e');
    }
  }

  // Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    try {
      final productCount = _cacheBox?.length ?? 0;
      final metadataCount = _metadataBox?.length ?? 0;

      // Count different types of cached items
      int singleProducts = 0;
      int productLists = 0;

      if (_metadataBox != null) {
        for (final key in _metadataBox!.keys) {
          final metadata = _metadataBox!.get(key);
          if (metadata != null) {
            final type = metadata['type'];
            if (type == 'single_product') singleProducts++;
            if (type == 'product_list') productLists++;
          }
        }
      }

      return {
        'totalProductsInCache': productCount,
        'totalMetadataEntries': metadataCount,
        'singleProductsCached': singleProducts,
        'productListsCached': productLists,
        'isInitialized': _cacheBox != null && _metadataBox != null,
      };
    } catch (e) {
      debugPrint('Failed to get cache stats: $e');
      return {'error': e.toString()};
    }
  }

  // Invalidate cache for specific category
  static Future<void> invalidateCategoryCache(int categoryId) async {
    try {
      if (_metadataBox == null) return;

      final keysToDelete = <String>[];

      for (final key in _metadataBox!.keys) {
        final metadata = _metadataBox!.get(key);
        if (metadata != null &&
            metadata['type'] == 'product_list' &&
            metadata['categoryId'] == categoryId) {
          keysToDelete.add(key);
        }
      }

      for (final key in keysToDelete) {
        await _metadataBox!.delete(key);
      }

      debugPrint('Invalidated cache for category $categoryId');
    } catch (e) {
      debugPrint('Failed to invalidate category cache: $e');
    }
  }

  // Preload products for offline use
  static Future<void> preloadProductsForOffline(List<Product> products) async {
    try {
      for (final product in products) {
        await cacheProduct(product);
      }
      debugPrint('Preloaded ${products.length} products for offline use');
    } catch (e) {
      debugPrint('Failed to preload products: $e');
    }
  }

  // Get all cached products (for offline mode)
  static List<Product> getAllCachedProducts() {
    try {
      if (_cacheBox == null) return [];

      final products = <Product>[];

      for (final key in _cacheBox!.keys) {
        if (key.startsWith('product_') && _isCacheValid(key)) {
          final productModel = _cacheBox!.get(key);
          if (productModel != null) {
            products.add(
              Product(
                id: productModel.id,
                name: productModel.name,
                description: productModel.description,
                price: productModel.price,
                categoryId: productModel.categoryId,
                attachments: productModel.attachments.cast(),
                syrianPoundPrice: productModel.syrianPoundPrice,
              ),
            );
          }
        }
      }

      debugPrint(
        'Retrieved ${products.length} cached products for offline use',
      );
      return products;
    } catch (e) {
      debugPrint('Failed to get all cached products: $e');
      return [];
    }
  }
}
