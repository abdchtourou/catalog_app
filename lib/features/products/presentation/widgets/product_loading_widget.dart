import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/sharedWidgets/custom_app_bar.dart';

class ProductLoadingWidget extends StatefulWidget {
  const ProductLoadingWidget({super.key});

  @override
  State<ProductLoadingWidget> createState() => _ProductLoadingWidgetState();
}

class _ProductLoadingWidgetState extends State<ProductLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Loading Icon
            AnimatedBuilder(
              animation: Listenable.merge([
                _pulseAnimation,
                _rotationAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: Container(
                      width: ResponsiveUtils.getResponsiveIconSize(context, 80),
                      height: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        80,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFC1D4),
                            const Color(0xFFFF8A95),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFC1D4).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          40,
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),

            // Loading Text with Fade Animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'Loading Product...'.tr(),
                    style: TextStyle(
                      fontSize:
                          20 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),

            // Subtitle with Delayed Animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'Please wait while we fetch the details'.tr(),
                    style: TextStyle(
                      fontSize:
                          14 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 40)),

            // Animated Progress Dots
            _buildProgressDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final delay = index * 0.3;
            final animationValue = (_pulseController.value + delay) % 1.0;
            final opacity =
                (animationValue < 0.5)
                    ? animationValue * 2
                    : (1.0 - animationValue) * 2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A95).withOpacity(opacity),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        );
      }),
    );
  }
}
