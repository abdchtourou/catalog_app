part of 'all_products_cubit.dart';

@immutable
sealed class AllProductsState {}

final class AllProductsInitial extends AllProductsState {}

final class AllProductsLoading extends AllProductsState {}

final class AllProductsLoaded extends AllProductsState {
  final List<Product> products;
  final bool isLoadingMore;
  final bool hasMore;

  AllProductsLoaded({
    required this.products,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  AllProductsLoaded copyWith({
    List<Product>? products,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return AllProductsLoaded(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final class AllProductsError extends AllProductsState {
  final String message;

  AllProductsError({required this.message});
}

// Delete product states
final class AllProductDeleting extends AllProductsState {}

final class AllProductDeleted extends AllProductsState {}

final class AllProductDeleteError extends AllProductsState {
  final String message;

  AllProductDeleteError({required this.message});
}
