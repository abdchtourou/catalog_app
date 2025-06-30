part of 'product_cubit.dart';

@immutable
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final Product product;

  const ProductLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

// Legacy states - kept for backward compatibility
class ProductImageDeleting extends ProductState {}

@Deprecated('Use ProductAttachmentDeleted instead')
class ProductImageDeleted extends ProductState {
  final int imageIndex;
  const ProductImageDeleted({required this.imageIndex});

  @override
  List<Object?> get props => [imageIndex];
}

// New attachment management states
class ProductAttachmentAdding extends ProductState {}

class ProductAttachmentAdded extends ProductState {
  final Attachment attachment;
  const ProductAttachmentAdded({required this.attachment});

  @override
  List<Object?> get props => [attachment];
}

class ProductAttachmentDeleted extends ProductState {
  final int attachmentId;
  const ProductAttachmentDeleted({required this.attachmentId});

  @override
  List<Object?> get props => [attachmentId];
}

// ✅ NEW: Single Attachment operations
class AttachmentLoading extends ProductState {}

class AttachmentLoaded extends ProductState {
  final Attachment attachment;
  const AttachmentLoaded(this.attachment);

  @override
  List<Object?> get props => [attachment];
}

class AttachmentError extends ProductState {
  final String message;
  const AttachmentError(this.message);

  @override
  List<Object?> get props => [message];
}

// Product deletion states
class SingleProductDeleting extends ProductState {}

class SingleProductDeleted extends ProductState {
  final int productId;
  const SingleProductDeleted({required this.productId});

  @override
  List<Object?> get props => [productId];
}
