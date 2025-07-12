import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/product.dart';

class OfflineActionDialog {
  static void showDeleteError(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                    ),
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.orange,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                ),
                Expanded(
                  child: Text(
                    'Offline Mode'.tr(),
                    style: TextStyle(
                      fontSize:
                          18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cannot delete "${product.name}" while offline.'.tr(),
                  style: TextStyle(
                    fontSize:
                        16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                ),
                Text(
                  'Please connect to the internet and try again.'.tr(),
                  style: TextStyle(
                    fontSize:
                        14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    color: const Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF8A95),
                  padding: ResponsiveUtils.getResponsiveButtonPadding(context),
                ),
                child: Text(
                  'OK'.tr(),
                  style: TextStyle(
                    fontSize:
                        16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  static void showActionError(BuildContext context, String action) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                    ),
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.orange,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                ),
                Expanded(
                  child: Text(
                    'Offline Mode'.tr(),
                    style: TextStyle(
                      fontSize:
                          18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cannot $action while offline.'.tr(),
                  style: TextStyle(
                    fontSize:
                        16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                ),
                Text(
                  'Please connect to the internet and try again.'.tr(),
                  style: TextStyle(
                    fontSize:
                        14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    color: const Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF8A95),
                  padding: ResponsiveUtils.getResponsiveButtonPadding(context),
                ),
                child: Text(
                  'OK'.tr(),
                  style: TextStyle(
                    fontSize:
                        16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
