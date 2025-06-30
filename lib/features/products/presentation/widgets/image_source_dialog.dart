import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/utils/responsive_utils.dart';

class ImageSourceDialog extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

  const ImageSourceDialog({
    super.key,
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onCameraSelected,
    required VoidCallback onGallerySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ImageSourceDialog(
          onCameraSelected: onCameraSelected,
          onGallerySelected: onGallerySelected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, 16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
            ),
            Text(
              'Select Image Source'.tr(),
              style: TextStyle(
                fontSize: 18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
            ),
            _buildResponsiveSourceOptions(context),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveSourceOptions(BuildContext context) {
    final isWideScreen =
        ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);

    if (isWideScreen) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSourceOption(
            context: context,
            icon: Icons.camera_alt,
            label: 'Camera'.tr(),
            onTap: () {
              Navigator.pop(context);
              onCameraSelected();
            },
          ),
          _buildSourceOption(
            context: context,
            icon: Icons.photo_library,
            label: 'Gallery'.tr(),
            onTap: () {
              Navigator.pop(context);
              onGallerySelected();
            },
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildSourceOption(
            context: context,
            icon: Icons.camera_alt,
            label: 'Camera'.tr(),
            onTap: () {
              Navigator.pop(context);
              onCameraSelected();
            },
            isFullWidth: true,
          ),
          const SizedBox(height: 12),
          _buildSourceOption(
            context: context,
            icon: Icons.photo_library,
            label: 'Gallery'.tr(),
            onTap: () {
              Navigator.pop(context);
              onGallerySelected();
            },
            isFullWidth: true,
          ),
        ],
      );
    }
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    final buttonWidth =
        isFullWidth
            ? double.infinity
            : ResponsiveUtils.getAdCardWidth(context) * 0.8;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
          ),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child:
            isFullWidth
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        24.0,
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize:
                            16.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Icon(
                      icon,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        40.0,
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize:
                            16.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
