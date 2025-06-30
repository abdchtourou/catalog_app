import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/cache/image_cache_service.dart';
import '../../../../core/cache/product_cache_service.dart';
import '../../../../core/utils/responsive_utils.dart';

class CacheManagementScreen extends StatefulWidget {
  const CacheManagementScreen({super.key});

  @override
  State<CacheManagementScreen> createState() => _CacheManagementScreenState();
}

class _CacheManagementScreenState extends State<CacheManagementScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _imageCacheInfo = {};
  Map<String, dynamic> _productCacheStats = {};

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imageCacheInfo = await ImageCacheService.getCacheInfo();
      final productCacheStats = ProductCacheService.getCacheStats();

      setState(() {
        _imageCacheInfo = imageCacheInfo;
        _productCacheStats = productCacheStats;
      });
    } catch (e) {
      debugPrint('Error loading cache info: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearImageCache() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ImageCacheService.clearCache();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image cache cleared successfully'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      await _loadCacheInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear image cache'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearProductCache() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ProductCacheService.clearAllCache();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product cache cleared successfully'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      await _loadCacheInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear product cache'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearExpiredCache() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ImageCacheService.clearExpiredCache();
      await ProductCacheService.clearExpiredCache();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expired cache cleared successfully'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      await _loadCacheInfo();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clear expired cache'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Cache Management'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadCacheInfo,
            tooltip: 'Refresh'.tr(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: ResponsiveUtils.getResponsivePadding(context),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          16,
                        ),
                      ),

                      // Header
                      _buildHeaderSection(),
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ),

                      // Image Cache Section
                      _buildImageCacheSection(),
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ),

                      // Product Cache Section
                      _buildProductCacheSection(),
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ),

                      // Actions Section
                      _buildActionsSection(),
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A95).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context, 12),
                  ),
                ),
                child: Icon(
                  Icons.storage,
                  color: const Color(0xFFFF8A95),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cache Management'.tr(),
                      style: TextStyle(
                        fontSize:
                            20.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your app cache to optimize performance and storage'
                          .tr(),
                      style: TextStyle(
                        fontSize:
                            14.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCacheSection() {
    return _buildCacheCard(
      title: 'Image Cache'.tr(),
      icon: Icons.image,
      iconColor: Colors.blue,
      stats: [
        _buildStatRow('Total Files', '${_imageCacheInfo['totalFiles'] ?? 0}'),
        _buildStatRow(
          'Total Size',
          '${_imageCacheInfo['totalSizeMB'] ?? '0'} MB',
        ),
        _buildStatRow(
          'Cache Entries',
          '${_imageCacheInfo['hiveEntries'] ?? 0}',
        ),
      ],
      onClear: _clearImageCache,
      clearButtonText: 'Clear Image Cache'.tr(),
      clearButtonColor: Colors.blue,
    );
  }

  Widget _buildProductCacheSection() {
    return _buildCacheCard(
      title: 'Product Cache'.tr(),
      icon: Icons.inventory,
      iconColor: Colors.orange,
      stats: [
        _buildStatRow(
          'Cached Products',
          '${_productCacheStats['singleProductsCached'] ?? 0}',
        ),
        _buildStatRow(
          'Product Lists',
          '${_productCacheStats['productListsCached'] ?? 0}',
        ),
        _buildStatRow(
          'Total Entries',
          '${_productCacheStats['totalMetadataEntries'] ?? 0}',
        ),
      ],
      onClear: _clearProductCache,
      clearButtonText: 'Clear Product Cache'.tr(),
      clearButtonColor: Colors.orange,
    );
  }

  Widget _buildCacheCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> stats,
    required VoidCallback onClear,
    required String clearButtonText,
    required Color clearButtonColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(context, 8),
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context, 8),
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize:
                      16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          ...stats,
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : onClear,
              style: ElevatedButton.styleFrom(
                backgroundColor: clearButtonColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context, 8),
                  ),
                ),
              ),
              child: Text(clearButtonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions'.tr(),
            style: TextStyle(
              fontSize: 16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _clearExpiredCache,
              icon: const Icon(Icons.cleaning_services),
              label: Text('Clear Expired Cache'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context, 8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.tr(),
            style: TextStyle(
              fontSize: 14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
