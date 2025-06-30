import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import '../cache/image_cache_service.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String? title;
  final String? description;
  final String? price;
  final VoidCallback? onTap;
  final bool showPrice;
  final bool showDescription;

  const ProductCard({
    super.key,
    required this.image,
    this.title,
    this.description,
    this.price,
    this.onTap,
    this.showPrice = true,
    this.showDescription = true,
  });

  // Widget _buildRatingStars(BuildContext context, double rating) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       ...List.generate(5, (index) {
  //         if (index < rating.floor()) {
  //           return Icon(
  //             Icons.star,
  //             size: ResponsiveUtils.getResponsiveIconSize(context, 12),
  //             color: Colors.amber,
  //           );
  //         } else if (index < rating) {
  //           return Icon(
  //             Icons.star_half,
  //             size: ResponsiveUtils.getResponsiveIconSize(context, 12),
  //             color: Colors.amber,
  //           );
  //         } else {
  //           return Icon(
  //             Icons.star_border,
  //             size: ResponsiveUtils.getResponsiveIconSize(context, 12),
  //             color: Colors.grey[400],
  //           );
  //         }
  //       }),
  //       SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4)),
  //       Text(
  //         rating.toStringAsFixed(1),
  //         style: TextStyle(
  //           fontSize: 10 * ResponsiveUtils.getFontSizeMultiplier(context),
  //           color: Colors.grey[600],
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 12),
                    ),
                    topRight: Radius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 12),
                    ),
                  ),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 12),
                    ),
                    topRight: Radius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 12),
                    ),
                  ),
                  child: ImageCacheService.getCachedImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Product Details
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 12),
                    ),
                    bottomRight: Radius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 12),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Title
                    Text(
                      title ?? "Product name here lorem ip...",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:
                            14 * ResponsiveUtils.getFontSizeMultiplier(context),
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Product Description (if enabled)
                    if (showDescription) ...[
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          4,
                        ),
                      ),
                      Text(
                        description ?? "Lorem ipsum dolor sit amet...",
                        style: TextStyle(
                          fontSize:
                              12 *
                              ResponsiveUtils.getFontSizeMultiplier(context),
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Rating and Price Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating (if enabled)
                        // if (showRating && rating != null) ...[
                        //   SizedBox(
                        //     height: ResponsiveUtils.getResponsiveSpacing(
                        //       context,
                        //       6,
                        //     ),
                        //   ),
                        //   _buildRatingStars(context, rating!),
                        // ],

                        // Product Price (if enabled)
                        if (showPrice && price != null) ...[
                          SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              4,
                            ),
                          ),
                          Text(
                            price!,
                            style: TextStyle(
                              fontSize:
                                  16 *
                                  ResponsiveUtils.getFontSizeMultiplier(
                                    context,
                                  ),
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFC1D4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
