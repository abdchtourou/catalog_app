import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../widgets/products_grid_with_add.dart';

class PaginatedProductsList extends StatefulWidget {
  final List<Product> products;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onEndReached;
  final String? categoryTitle;
  final String? categoryId;
  final VoidCallback? onProductUpdated;
  final Function(Product)? onProductDeleted;

  const PaginatedProductsList({
    super.key,
    required this.products,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onEndReached,
    this.categoryTitle,
    this.categoryId,
    this.onProductUpdated,
    this.onProductDeleted,
  });

  @override
  State<PaginatedProductsList> createState() => _PaginatedProductsListState();
}

class _PaginatedProductsListState extends State<PaginatedProductsList> {
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
    return ProductsGridWithAdd(
      products: widget.products,
      scrollController: _scrollController,
      isLoadingMore: widget.isLoadingMore,
      categoryId: widget.categoryId,
      onProductUpdated: widget.onProductUpdated,
      onProductDeleted: widget.onProductDeleted,
    );
  }
}
