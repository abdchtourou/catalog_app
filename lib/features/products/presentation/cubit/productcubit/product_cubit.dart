import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:catalog_app/features/products/domain/entities/attachment.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/domain/usecase/create_attachment_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/delete_attachment_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/delete_product_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_single_attachment_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_single_product_use_case.dart';
import 'package:catalog_app/core/cache/product_cache_service.dart';
import 'package:catalog_app/core/network/network_info.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetSingleProductUseCase getSingleProductUseCase;
  final GetSingleAttachmentUseCase getSingleAttachmentUseCase;
  final CreateAttachmentUseCase createAttachmentUseCase;
  final DeleteAttachmentUseCase deleteAttachmentUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final NetworkInfo networkInfo;

  ProductCubit(
    this.getSingleProductUseCase,
    this.getSingleAttachmentUseCase,
    this.createAttachmentUseCase,
    this.deleteAttachmentUseCase,
    this.deleteProductUseCase,
    this.networkInfo,
  ) : super(ProductInitial());

  int currentIndex = 0;

  Future<void> getProduct(int productId) async {
    // 1. Try cached product first
    final cached = ProductCacheService.getCachedProduct(productId);
    if (cached != null) {
      emit(ProductLoaded(cached));
    } else {
      emit(ProductLoading());
    }

    // 2. If offline and no cached data -> error
    final connected = await networkInfo.isConnected;
    if (!connected) {
      if (cached == null) {
        emit(ProductError("No internet connection"));
      }
      return;
    }

    try {
      final result = await getSingleProductUseCase(productId);
      result.fold(
        (failure) => emit(ProductError("Failed to load product: $failure")),
        (product) async {
          emit(ProductLoaded(product));
          // cache for future offline
          await ProductCacheService.cacheProduct(product);
        },
      );
    } catch (e) {
      if (cached == null) {
        emit(ProductError("Exception: $e"));
      }
    }
  }

  Future<void> getAttachment(int attachmentId) async {
    emit(AttachmentLoading());
    try {
      final result = await getSingleAttachmentUseCase(attachmentId);
      result.fold(
        (failure) =>
            emit(AttachmentError("Failed to load attachment: $failure")),
        (attachment) => emit(AttachmentLoaded(attachment)),
      );
    } catch (e) {
      emit(AttachmentError("Exception: $e"));
    }
  }

  void setImageIndex(int index) {
    if (state is ProductLoaded) {
      final loaded = state as ProductLoaded;
      emit(ProductLoaded(loaded.product));
    }
  }

  // New method for deleting specific attachment by ID
  Future<void> deleteAttachment(int attachmentId) async {
    emit(ProductImageDeleting());

    try {
      final result = await deleteAttachmentUseCase(attachmentId);

      result.fold(
        (failure) {
          emit(
            ProductError('Failed to delete attachment: ${failure.toString()}'),
          );
          // Re-emit loaded state to restore UI
          _reloadCurrentProduct();
        },
        (_) {
          emit(ProductAttachmentDeleted(attachmentId: attachmentId));
          // Reload product to get updated attachments
          _reloadCurrentProduct();
        },
      );
    } catch (e) {
      emit(ProductError('Error deleting attachment: ${e.toString()}'));
      _reloadCurrentProduct();
    }
  }

  // New method for adding attachment to product
  Future<void> addAttachment(int productId, File imageFile) async {
    emit(ProductAttachmentAdding());

    try {
      final result = await createAttachmentUseCase(productId, imageFile);

      result.fold(
        (failure) {
          emit(ProductError('Failed to add attachment: ${failure.toString()}'));
          _reloadCurrentProduct();
        },
        (attachment) {
          emit(ProductAttachmentAdded(attachment: attachment));
          // Reload product to get updated attachments
          _reloadCurrentProduct();
        },
      );
    } catch (e) {
      emit(ProductError('Error adding attachment: ${e.toString()}'));
      _reloadCurrentProduct();
    }
  }

  // Method for deleting the entire product
  Future<void> deleteProduct(int productId) async {
    emit(SingleProductDeleting());

    try {
      final result = await deleteProductUseCase(productId);

      result.fold(
        (failure) {
          emit(ProductError('Failed to delete product: ${failure.toString()}'));
        },
        (_) {
          emit(SingleProductDeleted(productId: productId));
        },
      );
    } catch (e) {
      emit(ProductError('Error deleting product: ${e.toString()}'));
    }
  }

  // Helper method to reload current product
  void _reloadCurrentProduct() {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      getProduct(currentState.product.id);
    }
  }
}
