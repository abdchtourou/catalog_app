import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/shared_widgets/confirmation_dialog.dart';
import '../../../../core/cache/image_cache_service.dart';
import '../../domain/entities/product.dart';
import '../cubit/productcubit/product_cubit.dart';
import '../cubit/products_cubit.dart';

import 'animated_navigation_button.dart';

class ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final bool isAdmin;
  final Function(int)? onImageDeleted;
  final Product? product;

  const ProductImageCarousel({
    super.key,
    required this.images,
    required this.fadeAnimation,
    required this.slideAnimation,
    this.isAdmin = false,
    this.onImageDeleted,
    this.product,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late CarouselSliderController carouselController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    carouselController = CarouselSliderController();
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Convert backslashes to forward slashes for URL
    final normalizedPath = imagePath.replaceAll('\\', '/');

    // Remove leading slash if present to avoid double slashes
    final cleanPath =
        normalizedPath.startsWith('/')
            ? normalizedPath.substring(1)
            : normalizedPath;

    return '${ApiConstants.baseImageUrl}$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = widget.images.length > 1;

    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: SlideTransition(
        position: widget.slideAnimation,
        child: Container(
          width: double.infinity,
          // Remove fixed height - let parent container control the height
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: ResponsiveUtils.getResponsiveSpacing(context, 20),
                    bottom: ResponsiveUtils.getResponsiveSpacing(context, 60),
                    left: ResponsiveUtils.getResponsiveSpacing(context, 16),
                    right: ResponsiveUtils.getResponsiveSpacing(context, 16),
                  ),
                  child:
                      hasMultipleImages
                          ? CarouselSlider(
                            carouselController: carouselController,
                            options: CarouselOptions(
                              height: double.infinity,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: widget.images.length > 2,
                              autoPlay: false,
                              enlargeCenterPage: false,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
                                });
                              },
                            ),
                            items:
                                widget.images.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final url = entry.value;
                                  return Hero(
                                    tag: 'product_image_$index',
                                    child: _buildCarouselItem(
                                      context,
                                      url,
                                      index,
                                    ),
                                  );
                                }).toList(),
                          )
                          : Hero(
                            tag: 'product_image_0',
                            child: _buildCarouselItem(
                              context,
                              widget.images.first,
                              0,
                            ),
                          ),
                ),
              ),

              if (!ResponsiveUtils.isMobile(context) && hasMultipleImages)
                Positioned(
                  left: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  top: 0,
                  bottom: ResponsiveUtils.getResponsiveSpacing(context, 60),
                  child: Center(
                    child: AnimatedNavigationButton(
                      onTap:
                          () => carouselController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          ),
                      icon: Icons.arrow_back_ios_new,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 40),
                      iconSize: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        18,
                      ),
                    ),
                  ),
                ),

              if (!ResponsiveUtils.isMobile(context) && hasMultipleImages)
                Positioned(
                  right: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  top: 0,
                  bottom: ResponsiveUtils.getResponsiveSpacing(context, 60),
                  child: Center(
                    child: AnimatedNavigationButton(
                      onTap:
                          () => carouselController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          ),
                      icon: Icons.arrow_forward_ios,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 40),
                      iconSize: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        18,
                      ),
                    ),
                  ),
                ),

              // Enhanced Admin Menu for product actions
              if (AppConfig.isAdmin && widget.product != null)
                Positioned(
                  top: ResponsiveUtils.getResponsiveSpacing(context, 16),
                  right: ResponsiveUtils.getResponsiveSpacing(context, 16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context, 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            12,
                          ),
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveBorderRadius(
                                context,
                                12,
                              ),
                            ),
                          ),
                          child: IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(
                                ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  8,
                                ),
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF3B82F6).withOpacity(0.1),
                                    const Color(0xFF3B82F6).withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.getResponsiveBorderRadius(
                                    context,
                                    8,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                color: const Color(0xFF3B82F6),
                                size: ResponsiveUtils.getResponsiveIconSize(
                                  context,
                                  20,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              final result = await context.push(
                                AppRoutes.productForm,
                                extra: {
                                  'product': widget.product,
                                  'categoryId':
                                      widget.product!.categoryId.toString(),
                                },
                              );

                              if (result == true && context.mounted) {
                                // Navigate back to refresh the previous screen
                                context.pop(true);
                              }
                            },
                            tooltip: 'Edit Product'.tr(),
                          ),
                        ),

                        // Divider
                        Container(
                          width: 1,
                          height: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            24,
                          ),
                          color: Colors.grey.withOpacity(0.3),
                          margin: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              4,
                            ),
                          ),
                        ),

                        // Delete button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveBorderRadius(
                                context,
                                12,
                              ),
                            ),
                          ),
                          child: Builder(
                            builder:
                                (context) => IconButton(
                                  icon: Container(
                                    padding: EdgeInsets.all(
                                      ResponsiveUtils.getResponsiveSpacing(
                                        context,
                                        8,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFFEF4444,
                                          ).withOpacity(0.1),
                                          const Color(
                                            0xFFEF4444,
                                          ).withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveUtils.getResponsiveBorderRadius(
                                          context,
                                          8,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.delete_rounded,
                                      color: const Color(0xFFEF4444),
                                      size:
                                          ResponsiveUtils.getResponsiveIconSize(
                                            context,
                                            20,
                                          ),
                                    ),
                                  ),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(context);
                                  },
                                  tooltip: 'Delete Product'.tr(),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Navigation Dots - only show if multiple images
              if (hasMultipleImages)
                Positioned(
                  bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
                  left: 0,
                  right: 0,
                  child: _buildNavigationDots(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, String url, int index) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveSpacing(context, 2),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 20),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: ImageCacheService.getCachedImage(
                    imageUrl: url,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationDots(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left arrow (mobile only) - only show if multiple images
                if (ResponsiveUtils.isMobile(context) &&
                    widget.images.length > 1)
                  AnimatedNavigationButton(
                    onTap:
                        () => carouselController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        ),
                    icon: Icons.arrow_back_ios_new,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 32),
                    iconSize: ResponsiveUtils.getResponsiveIconSize(
                      context,
                      14,
                    ),
                    isSmall: true,
                  ),

                // Dots container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      12,
                    ),
                    vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context, 16),
                    ),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        widget.images.asMap().entries.map((entry) {
                          final isActive = entry.key == currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width:
                                isActive
                                    ? ResponsiveUtils.getResponsiveSpacing(
                                      context,
                                      16,
                                    )
                                    : ResponsiveUtils.getResponsiveSpacing(
                                      context,
                                      8,
                                    ),
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              8,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                2,
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color:
                                  isActive
                                      ? const Color(0xFFFF8A95)
                                      : Colors.grey.withValues(alpha: 0.4),
                            ),
                          );
                        }).toList(),
                  ),
                ),

                // Right arrow (mobile only) - only show if multiple images
                if (ResponsiveUtils.isMobile(context) &&
                    widget.images.length > 1)
                  AnimatedNavigationButton(
                    onTap:
                        () => carouselController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        ),
                    icon: Icons.arrow_forward_ios,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 32),
                    iconSize: ResponsiveUtils.getResponsiveIconSize(
                      context,
                      14,
                    ),
                    isSmall: true,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteProduct(BuildContext context) {
    // Simply call the delete method - the ProductDetailsScreen will handle the result
    context.read<ProductCubit>().deleteProduct(widget.product!.id);
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    // Use the enhanced ConfirmationDialog for better tablet experience
    ConfirmationDialog.show(
      context,
      title: 'Delete Product'.tr(),
      message: _buildDeleteMessage(),
      confirmText: 'Delete Product'.tr(),
      cancelText: 'Keep Product'.tr(),
      confirmColor: const Color(0xFFEF4444),
      icon: Icons.delete_forever_rounded,
      iconColor: const Color(0xFFEF4444),
      onConfirm: () {
        if (widget.product != null) {
          _deleteProduct(context);
        }
      },
    );
  }

  String _buildDeleteMessage() {
    final product = widget.product!;
    return '${'Are you sure you want to delete'.tr()} "${product.name}"?\n\n'
        '${'Product Details:'.tr()}\n'
        '• ${'Name'.tr()}: ${product.name}\n'
        '• ${'Price'.tr()}: \$${product.price}\n'
        '• ${'Images'.tr()}: ${product.attachments.length} ${'attachment(s)'.tr()}\n\n'
        '${'This action cannot be undone and will permanently remove the product from your catalog.'.tr()}';
  }
}
