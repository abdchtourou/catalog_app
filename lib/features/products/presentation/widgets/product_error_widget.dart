import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/sharedWidgets/custom_app_bar.dart';

class ProductErrorWidget extends StatelessWidget {
  final String message;

  const ProductErrorWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize:
                          16 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
