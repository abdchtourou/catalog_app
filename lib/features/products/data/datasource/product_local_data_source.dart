import 'package:hive/hive.dart';

import '../model/product_model.dart';
import 'syrian_price_cache_service.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProductsByCategory(
    String categoryId,
    List<ProductModel> products,
  );

  Future<List<ProductModel>> getCachedProductsByCategory(String categoryId);

  // Individual product caching
  Future<void> cacheProduct(ProductModel product);
  Future<ProductModel?> getCachedProduct(int productId);
  Future<void> removeCachedProduct(int productId);

  // Cache management
  Future<int> invalidateCache();
  Future<void> clearCorruptedCache();
  Future<void> clearExpiredCache();
  Future<bool> isProductCacheValid(int productId);

  // Syrian price specific caching
  Future<void> cacheSyrianPrice(int productId, String syrianPrice);
  Future<String?> getCachedSyrianPrice(int productId);
  Future<void> removeCachedSyrianPrice(int productId);
  Future<void> clearExpiredSyrianPriceCache();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box box;
  late final SyrianPriceCacheService _syrianPriceCacheService;
  static const String _productPrefix = 'product_';
  static const String _timestampPrefix = 'timestamp_';
  static const int _cacheExpirationDays =
      7; // Cache expires after 7 days (longer retention)

  ProductLocalDataSourceImpl(this.box) {
    _syrianPriceCacheService = SyrianPriceCacheService(box);
  }

  @override
  Future<void> cacheProductsByCategory(
    String categoryId,
    List<ProductModel> products,
  ) async {
    try {
      final productMaps = products.map((product) => product.toJson()).toList();
      await box.put(categoryId, productMaps);

      // Also cache Syrian prices separately for better performance
      await _syrianPriceCacheService.cacheSyrianPricesFromProducts(products);
    } catch (e) {
      // If there's an error (likely due to model changes), clear the cache
      await clearCorruptedCache();
      // Retry caching
      final productMaps = products.map((product) => product.toJson()).toList();
      await box.put(categoryId, productMaps);
      await _syrianPriceCacheService.cacheSyrianPricesFromProducts(products);
    }
  }

  @override
  Future<List<ProductModel>> getCachedProductsByCategory(
    String categoryId,
  ) async {
    try {
      final productMaps = box.get(categoryId);
      if (productMaps != null) {
        return (productMaps as List)
            .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      // If there's an error reading (likely due to model changes), clear the cache
      await clearCorruptedCache();
      return [];
    }
  }

  @override
  Future<int> invalidateCache() {
    return box.clear();
  }

  @override
  Future<void> clearCorruptedCache() async {
    try {
      await box.clear();
    } catch (e) {
      // If even clearing fails, we might need to delete the box entirely
      // This is handled by Hive automatically in most cases
    }
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    try {
      final productKey = '$_productPrefix${product.id}';
      final timestampKey = '$_timestampPrefix${product.id}';

      await box.put(productKey, product.toJson());
      await box.put(timestampKey, DateTime.now().millisecondsSinceEpoch);

      // Also cache Syrian price separately
      if (product.syrianPoundPrice.isNotEmpty &&
          product.syrianPoundPrice != '0') {
        await _syrianPriceCacheService.cacheSyrianPrice(
          product.id,
          product.syrianPoundPrice,
        );
      }
    } catch (e) {
      // If there's an error, clear corrupted cache and retry
      await clearCorruptedCache();
      final productKey = '$_productPrefix${product.id}';
      final timestampKey = '$_timestampPrefix${product.id}';

      await box.put(productKey, product.toJson());
      await box.put(timestampKey, DateTime.now().millisecondsSinceEpoch);

      // Also cache Syrian price separately
      if (product.syrianPoundPrice.isNotEmpty &&
          product.syrianPoundPrice != '0') {
        await _syrianPriceCacheService.cacheSyrianPrice(
          product.id,
          product.syrianPoundPrice,
        );
      }
    }
  }

  @override
  Future<ProductModel?> getCachedProduct(int productId) async {
    try {
      final productKey = '$_productPrefix$productId';
      final productData = box.get(productKey);

      if (productData != null && await isProductCacheValid(productId)) {
        return ProductModel.fromJson(Map<String, dynamic>.from(productData));
      } else {
        // Remove expired cache
        await removeCachedProduct(productId);
        return null;
      }
    } catch (e) {
      // If there's an error reading, clear corrupted cache
      await removeCachedProduct(productId);
      return null;
    }
  }

  @override
  Future<void> removeCachedProduct(int productId) async {
    try {
      final productKey = '$_productPrefix$productId';
      final timestampKey = '$_timestampPrefix$productId';

      await box.delete(productKey);
      await box.delete(timestampKey);
    } catch (e) {
      // Ignore errors when removing cache
    }
  }

  @override
  Future<bool> isProductCacheValid(int productId) async {
    try {
      final timestampKey = '$_timestampPrefix$productId';
      final timestamp = box.get(timestampKey);

      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      return difference.inDays < _cacheExpirationDays;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    try {
      final keys = box.keys.toList();
      final expiredKeys = <String>[];

      for (final key in keys) {
        if (key.toString().startsWith(_productPrefix)) {
          final productIdStr = key.toString().substring(_productPrefix.length);
          final productId = int.tryParse(productIdStr);

          if (productId != null && !await isProductCacheValid(productId)) {
            expiredKeys.add(key.toString());
            expiredKeys.add('$_timestampPrefix$productId');
          }
        }
      }

      for (final key in expiredKeys) {
        await box.delete(key);
      }

      // Also clear expired Syrian price cache
      await _syrianPriceCacheService.clearExpiredSyrianPriceCache();
    } catch (e) {
      // If there's an error, we can ignore it as this is cleanup
    }
  }

  // Syrian price specific caching methods
  @override
  Future<void> cacheSyrianPrice(int productId, String syrianPrice) async {
    await _syrianPriceCacheService.cacheSyrianPrice(productId, syrianPrice);
  }

  @override
  Future<String?> getCachedSyrianPrice(int productId) async {
    return await _syrianPriceCacheService.getCachedSyrianPrice(productId);
  }

  @override
  Future<void> removeCachedSyrianPrice(int productId) async {
    await _syrianPriceCacheService.removeCachedSyrianPrice(productId);
  }

  @override
  Future<void> clearExpiredSyrianPriceCache() async {
    await _syrianPriceCacheService.clearExpiredSyrianPriceCache();
  }
}
