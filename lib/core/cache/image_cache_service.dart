import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:catalog_app/core/constants/api_constants.dart';

class ImageCacheService {
  static const String _imageCacheBoxName = 'imageCacheBox';
  static const Duration _defaultCacheExpiry = Duration(days: 30);
  static Box<Map>? _cacheBox;

  static Future<void> initialize() async {
    try {
      _cacheBox = await Hive.openBox<Map>(_imageCacheBoxName);
    } catch (e) {
      debugPrint('Failed to initialize image cache: $e');
    }
  }

  // Generate a cache key from URL
  static String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Check if image is cached and not expired
  static bool _isCacheValid(String cacheKey) {
    if (_cacheBox == null) return false;

    final cacheData = _cacheBox!.get(cacheKey);
    if (cacheData == null) return false;

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(
      cacheData['expiry'] ?? 0,
    );

    return DateTime.now().isBefore(expiryTime);
  }

  // Store cache metadata
  static Future<void> _storeCacheMetadata(
    String cacheKey,
    String url,
    int fileSize,
  ) async {
    if (_cacheBox == null) return;

    final expiryTime = DateTime.now().add(_defaultCacheExpiry);

    await _cacheBox!.put(cacheKey, {
      'url': url,
      'fileSize': fileSize,
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiryTime.millisecondsSinceEpoch,
    });
  }

  // Get cached image widget with comprehensive error handling
  static Widget getCachedImage({
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    Duration placeholderFadeInDuration = const Duration(milliseconds: 300),
    Map<String, String>? httpHeaders,
    bool useOldImageOnUrlChange = false,
    Color? color,
    BlendMode? colorBlendMode,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    // Normalize URL
    final normalizedUrl = _normalizeImageUrl(imageUrl);
    final cacheKey = _generateCacheKey(normalizedUrl);

    return CachedNetworkImage(
      imageUrl: normalizedUrl,
      key: ValueKey(cacheKey),
      fit: fit,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      filterQuality: filterQuality,
      fadeInDuration: fadeInDuration,
      placeholderFadeInDuration: placeholderFadeInDuration,
      httpHeaders: httpHeaders,
      useOldImageOnUrlChange: useOldImageOnUrlChange,

      // Progressive loading indicator
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return _buildProgressIndicator(context, downloadProgress);
      },

      // Enhanced error widget
      errorWidget: (context, url, error) {
        debugPrint('Failed to load cached image: $url - Error: $error');
        return errorWidget ?? _buildDefaultErrorWidget(context, error);
      },

      // Cache configuration
      cacheManager: DefaultCacheManager(),
      memCacheWidth: width != null && width.isFinite ? width.toInt() : null,
      memCacheHeight: height != null && height.isFinite ? height.toInt() : null,

      // Callback when image is successfully loaded
      imageBuilder: (context, imageProvider) {
        // Update cache metadata
        _updateCacheMetadata(cacheKey, normalizedUrl);

        return Image(
          image: imageProvider,
          fit: fit,
          width: width,
          height: height,
          color: color,
          colorBlendMode: colorBlendMode,
          filterQuality: filterQuality,
        );
      },
    );
  }

  // Normalize image URL
  static String _normalizeImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    // Use the centralized base image URL from ApiConstants
    final normalizedPath = imageUrl.replaceAll('\\', '/');
    final cleanPath =
        normalizedPath.startsWith('/')
            ? normalizedPath.substring(1)
            : normalizedPath;

    return '${ApiConstants.baseImageUrl}$cleanPath';
  }

  // Update cache metadata when image loads successfully
  static void _updateCacheMetadata(String cacheKey, String url) {
    Future.microtask(() async {
      try {
        final file = await DefaultCacheManager().getSingleFile(url);
        if (file.existsSync()) {
          final fileSize = await file.length();
          await _storeCacheMetadata(cacheKey, url, fileSize);
        }
      } catch (e) {
        debugPrint('Failed to update cache metadata: $e');
      }
    });
  }

  // Default placeholder widget
  static Widget _buildDefaultPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 32),
      ),
    );
  }

  // Progress indicator for loading
  static Widget _buildProgressIndicator(
    BuildContext context,
    DownloadProgress downloadProgress,
  ) {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            if (downloadProgress.progress != null) ...[
              const SizedBox(height: 8),
              Text(
                '${(downloadProgress.progress! * 100).toInt()}%',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Default error widget
  static Widget _buildDefaultErrorWidget(BuildContext context, dynamic error) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 32),
          const SizedBox(height: 4),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Preload image into cache
  static Future<void> preloadImage(String imageUrl) async {
    try {
      final normalizedUrl = _normalizeImageUrl(imageUrl);
      await DefaultCacheManager().downloadFile(normalizedUrl);
      debugPrint('Successfully preloaded image: $normalizedUrl');
    } catch (e) {
      debugPrint('Failed to preload image: $imageUrl - Error: $e');
    }
  }

  // Preload multiple images
  static Future<void> preloadImages(List<String> imageUrls) async {
    final futures = imageUrls.map((url) => preloadImage(url));
    await Future.wait(futures);
  }

  // Get cache information
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final cacheDir = await getTemporaryDirectory();

      int totalFiles = 0;
      int totalSize = 0;

      if (cacheDir.existsSync()) {
        final files = cacheDir.listSync(recursive: true);
        for (final file in files) {
          if (file is File) {
            totalFiles++;
            totalSize += await file.length();
          }
        }
      }

      final hiveEntries = _cacheBox?.length ?? 0;

      return {
        'totalFiles': totalFiles,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'hiveEntries': hiveEntries,
        'cacheDirectory': cacheDir.path,
      };
    } catch (e) {
      debugPrint('Failed to get cache info: $e');
      return {'error': e.toString()};
    }
  }

  // Clear all cached images
  static Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      await _cacheBox?.clear();
      debugPrint('Successfully cleared image cache');
    } catch (e) {
      debugPrint('Failed to clear image cache: $e');
    }
  }

  // Clear expired cache entries
  static Future<void> clearExpiredCache() async {
    try {
      if (_cacheBox == null) return;

      final keysToDelete = <String>[];

      for (final key in _cacheBox!.keys) {
        if (!_isCacheValid(key)) {
          keysToDelete.add(key);
        }
      }

      for (final key in keysToDelete) {
        await _cacheBox!.delete(key);
      }

      debugPrint('Cleared ${keysToDelete.length} expired cache entries');
    } catch (e) {
      debugPrint('Failed to clear expired cache: $e');
    }
  }

  // Get specific image from cache
  static Future<File?> getCachedImageFile(String imageUrl) async {
    try {
      final normalizedUrl = _normalizeImageUrl(imageUrl);
      final file = await DefaultCacheManager().getSingleFile(normalizedUrl);
      return file.existsSync() ? file : null;
    } catch (e) {
      debugPrint('Failed to get cached image file: $e');
      return null;
    }
  }

  // Check if image is cached
  static Future<bool> isImageCached(String imageUrl) async {
    try {
      final normalizedUrl = _normalizeImageUrl(imageUrl);
      final fileInfo = await DefaultCacheManager().getFileFromCache(
        normalizedUrl,
      );
      return fileInfo != null && fileInfo.file.existsSync();
    } catch (e) {
      debugPrint('Failed to check if image is cached: $e');
      return false;
    }
  }
}
