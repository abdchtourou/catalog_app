import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class SnackBarUtils {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveIconSize(context, 20.0),
            ),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
            ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize:
                      15.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
          ),
        ),
        margin: ResponsiveUtils.getResponsiveMargin(context),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveIconSize(context, 20.0),
            ),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
            ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize:
                      15.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
          ),
        ),
        margin: ResponsiveUtils.getResponsiveMargin(context),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
