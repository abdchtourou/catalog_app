import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AddProductCard extends StatelessWidget {
  final VoidCallback? onTap;

  const AddProductCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: const Color(0xFFFFB3C1),
            strokeWidth: 2,
            dashWidth: 8,
            dashSpace: 6,
          ),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 32,
                    color: Color(0xFFFF6B7A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add new product'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF6B7A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final borderRadius = 12.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    _drawDashedRRect(canvas, rrect, paint);
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = pathMetric.extractPath(
          distance,
          nextDistance > pathMetric.length ? pathMetric.length : nextDistance,
        );
        canvas.drawPath(extractPath, paint);
        distance = nextDistance + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
