import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_utils.dart';

class LoadingMoreIndicator extends StatelessWidget {
  const LoadingMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveUtils.getResponsiveMargin(context),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(context, 18.0),
            height: ResponsiveUtils.getResponsiveSpacing(context, 18.0),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A95)),
              strokeWidth: 2.0,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 10.0)),
          Text(
            'Loading more...'.tr(),
            style: TextStyle(
              fontSize: 13.0 * ResponsiveUtils.getFontSizeMultiplier(context),
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
