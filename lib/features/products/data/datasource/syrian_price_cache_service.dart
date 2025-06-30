import 'package:hive/hive.dart';
import '../model/product_model.dart';

/// Service to handle Syrian price caching specifically
/// This ensures that both admin and normal users see consistent prices
class SyrianPriceCacheService {
  final Box box;
  static const String _syrianPricePrefix = 'syrian_price_';
  static const String _timestampPrefix = 'syrian_timestamp_';
  static const int _cacheExpirationHours = 24; // Cache expires after 24 hours

  SyrianPriceCacheService(this.box);

  /// Cache Syrian price for a specific product
  Future<void> cacheSyrianPrice(int productId, String syrianPrice) async {
    try {
      final priceKey = '$_syrianPricePrefix$productId';
      final timestampKey = '$_timestampPrefix$productId';

      await box.put(priceKey, syrianPrice);
      await box.put(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail to avoid breaking the app
      // Syrian prices will be fetched from server as fallback
    }
  }

  /// Get cached Syrian price for a specific product
  Future<String?> getCachedSyrianPrice(int productId) async {
    try {
      if (await isSyrianPriceCacheValid(productId)) {
        final priceKey = '$_syrianPricePrefix$productId';
        final cachedPrice = box.get(priceKey);

        if (cachedPrice != null &&
            cachedPrice.toString().isNotEmpty &&
            cachedPrice.toString() != '0') {
          return cachedPrice.toString();
        }
      }

      // Remove expired or invalid cache
      await removeCachedSyrianPrice(productId);
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if Syrian price cache is still valid
  Future<bool> isSyrianPriceCacheValid(int productId) async {
    try {
      final timestampKey = '$_timestampPrefix$productId';
      final timestamp = box.get(timestampKey);

      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      return difference.inHours < _cacheExpirationHours;
    } catch (e) {
      return false;
    }
  }

  /// Remove cached Syrian price for a specific product
  Future<void> removeCachedSyrianPrice(int productId) async {
    try {
      final priceKey = '$_syrianPricePrefix$productId';
      final timestampKey = '$_timestampPrefix$productId';

      await box.delete(priceKey);
      await box.delete(timestampKey);
    } catch (e) {
      // Ignore errors when removing cache
    }
  }

  /// Bulk cache Syrian prices from product models
  Future<void> cacheSyrianPricesFromProducts(
    List<ProductModel> products,
  ) async {
    for (final product in products) {
      if (product.syrianPoundPrice.isNotEmpty &&
          product.syrianPoundPrice != '0') {
        await cacheSyrianPrice(product.id, product.syrianPoundPrice);
      }
    }
  }

  /// Clear all Syrian price cache
  Future<void> clearAllSyrianPriceCache() async {
    try {
      final keys = box.keys.toList();
      final syrianPriceKeys =
          keys
              .where(
                (key) =>
                    key.toString().startsWith(_syrianPricePrefix) ||
                    key.toString().startsWith(_timestampPrefix),
              )
              .toList();

      for (final key in syrianPriceKeys) {
        await box.delete(key);
      }
    } catch (e) {
      // Ignore errors when clearing cache
    }
  }

  /// Clear expired Syrian price cache entries
  Future<void> clearExpiredSyrianPriceCache() async {
    try {
      final keys = box.keys.toList();
      final expiredKeys = <String>[];

      for (final key in keys) {
        if (key.toString().startsWith(_syrianPricePrefix)) {
          final productIdStr = key.toString().substring(
            _syrianPricePrefix.length,
          );
          final productId = int.tryParse(productIdStr);

          if (productId != null && !await isSyrianPriceCacheValid(productId)) {
            expiredKeys.add(key.toString());
            expiredKeys.add('$_timestampPrefix$productId');
          }
        }
      }

      for (final key in expiredKeys) {
        await box.delete(key);
      }
    } catch (e) {
      // Ignore errors when clearing expired cache
    }
  }
}
