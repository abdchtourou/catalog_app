part of 'products_cubit.dart';

@immutable
sealed class ProductsState {}

final class ProductsInitial extends ProductsState {}

final class ProductsLoading extends ProductsState {}

final class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final bool isLoadingMore;
  final bool hasMore;

  ProductsLoaded({
    required this.products,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final class ProductsError extends ProductsState {
  final String message;

  ProductsError({required this.message});
}

class ProductFormSubmitting extends ProductsState {}

class ProductFormSuccess extends ProductsState {
  final Product product;

  ProductFormSuccess({required this.product});
}

class ProductFormError extends ProductsState {
  final String message;

  ProductFormError({required this.message});
}

class ProductDeleting extends ProductsState {}

class ProductDeleted extends ProductsState {}

class ProductDeleteError extends ProductsState {
  final String message;
  ProductDeleteError({required this.message});
}

// Attachment management states
class AttachmentAdded extends ProductsState {
  final Attachment attachment;
  AttachmentAdded({required this.attachment});
}

class AttachmentDeleted extends ProductsState {
  final int attachmentId;
  AttachmentDeleted({required this.attachmentId});
}

class AttachmentsDeleted extends ProductsState {
  final List<int> attachmentIds;
  AttachmentsDeleted({required this.attachmentIds});
}
