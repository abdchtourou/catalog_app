import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class AnimatedNavigationButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final double iconSize;
  final bool isSmall;

  const AnimatedNavigationButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.size,
    required this.iconSize,
    this.isSmall = false,
  });

  @override
  State<AnimatedNavigationButton> createState() =>
      _AnimatedNavigationButtonState();
}

class _AnimatedNavigationButtonState extends State<AnimatedNavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              margin: widget.isSmall
                  ? EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        8,
                      ),
                    )
                  : null,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: widget.isSmall ? 4 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: const Color(0xFFFF8A95),
                size: widget.iconSize,
              ),
            ),
          );
        },
      ),
    );
  }
}
