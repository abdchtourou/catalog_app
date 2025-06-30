import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionText,
    this.onAction,
    this.padding,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: iconSize ?? 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              title.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateVariants {
  static Widget categories({VoidCallback? onAddCategory}) {
    return EmptyStateWidget(
      title: 'No Categories Found',
      subtitle: 'Start by creating your first category to organize your products.',
      icon: Icons.category_outlined,
      actionText: onAddCategory != null ? 'Add Category' : null,
      onAction: onAddCategory,
    );
  }

  static Widget products({VoidCallback? onAddProduct}) {
    return EmptyStateWidget(
      title: 'No Products Found',
      subtitle: 'Add your first product to get started with your catalog.',
      icon: Icons.inventory_2_outlined,
      actionText: onAddProduct != null ? 'Add Product' : null,
      onAction: onAddProduct,
    );
  }

  static Widget search({required String searchTerm}) {
    return EmptyStateWidget(
      title: 'No Results Found',
      subtitle: 'No items match your search for "$searchTerm". Try different keywords.',
      icon: Icons.search_off,
    );
  }

  static Widget images() {
    return EmptyStateWidget(
      title: 'No Images',
      subtitle: 'Add images to showcase your product better.',
      icon: Icons.image_outlined,
      iconSize: 60,
      padding: const EdgeInsets.all(24.0),
    );
  }

  static Widget attachments() {
    return EmptyStateWidget(
      title: 'No Attachments',
      subtitle: 'Upload files to provide additional information.',
      icon: Icons.attach_file_outlined,
      iconSize: 60,
      padding: const EdgeInsets.all(24.0),
    );
  }

  static Widget subcategories({VoidCallback? onAddSubcategory}) {
    return EmptyStateWidget(
      title: 'No Subcategories',
      subtitle: 'Create subcategories to better organize your products.',
      icon: Icons.folder_outlined,
      actionText: onAddSubcategory != null ? 'Add Subcategory' : null,
      onAction: onAddSubcategory,
      iconSize: 60,
      padding: const EdgeInsets.all(24.0),
    );
  }

  static Widget favorites() {
    return EmptyStateWidget(
      title: 'No Favorites',
      subtitle: 'Items you mark as favorites will appear here.',
      icon: Icons.favorite_border,
    );
  }

  static Widget cart() {
    return EmptyStateWidget(
      title: 'Your Cart is Empty',
      subtitle: 'Add some products to your cart to get started.',
      icon: Icons.shopping_cart_outlined,
    );
  }

  static Widget orders() {
    return EmptyStateWidget(
      title: 'No Orders',
      subtitle: 'Your order history will appear here.',
      icon: Icons.receipt_long_outlined,
    );
  }

  static Widget notifications() {
    return EmptyStateWidget(
      title: 'No Notifications',
      subtitle: 'You\'re all caught up! New notifications will appear here.',
      icon: Icons.notifications_none,
    );
  }

  static Widget generic({
    required String title,
    String? subtitle,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
    );
  }

  static Widget list({
    required String title,
    String? subtitle,
    IconData? icon,
  }) {
    return SliverToBoxAdapter(
      child: EmptyStateWidget(
        title: title,
        subtitle: subtitle,
        icon: icon,
        padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 32.0),
      ),
    );
  }
}
