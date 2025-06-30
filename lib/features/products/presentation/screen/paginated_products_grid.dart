import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/sharedWidgets/product_card.dart';

class PaginatedProductsGrid extends StatefulWidget {
  final List<Product> products;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onEndReached;

  const PaginatedProductsGrid({
    super.key,
    required this.products,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onEndReached,
  });

  @override
  State<PaginatedProductsGrid> createState() => _PaginatedProductsGridState();
}

class _PaginatedProductsGridState extends State<PaginatedProductsGrid> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoadingMore) {
        widget.onEndReached();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
        top: ResponsiveUtils.getResponsiveSpacing(context, 16),
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
      ),
      itemCount: widget.products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getGridColumns(context),
        crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
        mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
        childAspectRatio:
            ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context)
                ? 0.75
                : 0.7,
      ),
      itemBuilder: (context, index) {
        final product = widget.products[index];
        return ProductCard(
          image: 'product.image',
          title: product.name,
          description: product.description,
          showDescription: true,
          onTap: () {},
        );
      },
    );
  }
}
