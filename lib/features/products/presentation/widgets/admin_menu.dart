import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/shared_widgets/confirmation_dialog.dart';
import '../../domain/entities/product.dart';
import '../cubit/products_cubit.dart';

class AdminMenu extends StatelessWidget {
  const AdminMenu({
    super.key,
    this.onEdit,
    this.onDelete,
    required this.product,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Product product;

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: ResponsiveUtils.getResponsiveSpacing(context, 8),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        icon: Container(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsiveSpacing(context, 8),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 8),
            ),
          ),
          child: Icon(
            Icons.more_vert_rounded,
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(context, 20),
          ),
        ),
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, 16),
          ),
        ),
        offset: Offset(0, ResponsiveUtils.getResponsiveSpacing(context, 12)),
        elevation: ResponsiveUtils.getResponsiveElevation(context, 8.0),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _editProduct(context);
              break;
            case 'delete':
              _showDeleteConfirmation(context);
              break;
          }
        },
        itemBuilder:
            (context) => [
              PopupMenuItem<String>(
                value: 'edit',
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20),
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getResponsiveSpacing(context, 8),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.1),
                            Colors.blue.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context, 8),
                        ),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          18,
                        ),
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(context, 12),
                    ),
                    Text(
                      'Edit Product',
                      style: TextStyle(
                        fontSize:
                            16 * ResponsiveUtils.getFontSizeMultiplier(context),
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20),
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getResponsiveSpacing(context, 8),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withOpacity(0.1),
                            Colors.red.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context, 8),
                        ),
                      ),
                      child: Icon(
                        Icons.delete_rounded,
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          18,
                        ),
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(context, 12),
                    ),
                    Text(
                      'Delete Product',
                      style: TextStyle(
                        fontSize:
                            16 * ResponsiveUtils.getFontSizeMultiplier(context),
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
      ),
    );
  }

  void _editProduct(BuildContext context) {
    if (onEdit != null) {
      onEdit!();
    } else {
      context.push(
        AppRoutes.productForm,
        extra: {
          'product': product,
          'categoryId': product.categoryId.toString(),
        },
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    // If onDelete callback is provided, use it directly (parent will handle dialog)
    if (onDelete != null) {
      onDelete!();
      return;
    }

    // Use the enhanced ConfirmationDialog
    ConfirmationDialog.show(
      context,
      title: 'Delete Product',
      message: _buildDeleteMessage(),
      confirmText: 'Delete Product',
      cancelText: 'Keep Product',
      confirmColor: const Color(0xFFEF4444),
      icon: Icons.delete_forever_rounded,
      iconColor: const Color(0xFFEF4444),
      onConfirm: () {
        context.read<ProductsCubit>().deleteProduct(product.id);
      },
    );
  }

  String _buildDeleteMessage() {
    return 'Are you sure you want to delete "${product.name}"?\n\n'
        'Product Details:\n'
        '• Name: ${product.name}\n'
        '• Price: \$${product.price}\n'
        '• Images: ${product.attachments.length} attachment(s)\n\n'
        'This action cannot be undone and will permanently remove the product from your catalog.';
  }
}
