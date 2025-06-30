import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:catalog_app/core/utils/logger.dart';
import 'package:catalog_app/features/category/domain/entities/category.dart';
import 'package:catalog_app/features/category/domain/usecases/create_category_use_case.dart';
import 'package:catalog_app/features/category/domain/usecases/delete_category_use_case.dart';
import 'package:catalog_app/features/category/domain/usecases/get_categories_by_parent_use_case.dart';
import 'package:catalog_app/features/category/domain/usecases/get_categories_use_case.dart';
import 'package:catalog_app/features/category/domain/usecases/get_single_category_use_case.dart';
import 'package:catalog_app/features/category/domain/usecases/update_category_use_case.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase _getCategories;
  final GetCategoriesByParentUseCase _getCategoriesByParent;
  final GetSingleCategoryUseCase _getSingleCategory;
  final CreateCategoryUseCase _createCategory;
  final UpdateCategoryUseCase _updateCategory;
  final DeleteCategoryUseCase _deleteCategory;

  int _currentPage = 1;
  bool _isFetching = false;
  final int _pageSize = 30;
  bool _hasMore = true;
  final List<Category> _categories = [];

  // ✅ NEW: Hierarchical navigation state
  final List<Category> _navigationStack = []; // Stack of parent categories
  int? _currentParentId; // Current parent category ID (null for root level)

  CategoriesCubit(
    this._getCategories,
    this._getCategoriesByParent,
    this._getSingleCategory,
    this._createCategory,
    this._updateCategory,
    this._deleteCategory,
  ) : super(CategoriesInitial());

  List<Category> get currentCategories => List.from(_categories);
  List<Category> get navigationStack => List.from(_navigationStack);
  int? get currentParentId => _currentParentId;
  bool get isAtRootLevel => _currentParentId == null;

  // ✅ NEW: Refresh method for pull-to-refresh
  Future<void> refresh() async {
    if (_currentParentId == null) {
      // At root level
      await getCategories(isInitialLoad: true);
    } else {
      // At subcategory level
      await getCategoriesByParent(_currentParentId!, isInitialLoad: true);
    }
  }

  Future<void> getSingleCategory(int categoryId) async {
    emit(CategoryLoading());
    try {
      final result = await _getSingleCategory(categoryId);
      result.fold(
        (failure) => emit(CategoryError("Failed to load category: $failure")),
        (category) => emit(CategoryLoaded(category)),
      );
    } catch (e) {
      emit(CategoryError("Exception: $e"));
    }
  }

  // ✅ NEW: Navigate to subcategories of a parent category
  Future<void> navigateToSubcategories(Category parentCategory) async {
    AppLogger.info(
      '🔍 Navigating to subcategories of: ${parentCategory.name} (ID: ${parentCategory.id})',
    );
    _navigationStack.add(parentCategory);
    _currentParentId = parentCategory.id;
    await getCategoriesByParent(parentCategory.id, isInitialLoad: true);
  }

  // ✅ NEW: Navigate back to parent level
  Future<void> navigateBack() async {
    if (_navigationStack.isNotEmpty) {
      _navigationStack.removeLast();
      _currentParentId =
          _navigationStack.isNotEmpty ? _navigationStack.last.id : null;

      if (_currentParentId == null) {
        // Back to root level
        await getCategories(isInitialLoad: true);
      } else {
        // Back to parent level
        await getCategoriesByParent(_currentParentId!, isInitialLoad: true);
      }
    }
  }

  // ✅ NEW: Reset to root level
  Future<void> navigateToRoot() async {
    _navigationStack.clear();
    _currentParentId = null;
    await getCategories(isInitialLoad: true);
  }

  // ✅ NEW: Check if a category has subcategories
  Future<bool> checkHasSubcategories(int categoryId) async {
    try {
      AppLogger.info(
        '🔍 Checking for subcategories of category ID: $categoryId',
      );
      final result = await _getCategoriesByParent(
        parentId: categoryId,
        pageNumber: 1,
        pageSize: 1, // Just check if any exist
      );
      return result.fold(
        (failure) {
          AppLogger.error('❌ Failed to check subcategories: $failure');
          return false; // If error, assume no subcategories
        },
        (response) {
          final hasSubcategories = response.categories.isNotEmpty;
          AppLogger.info(
            '✅ Category $categoryId has subcategories: $hasSubcategories (found ${response.categories.length})',
          );
          return hasSubcategories;
        },
      );
    } catch (e) {
      AppLogger.error('❌ Exception checking subcategories: $e');
      return false; // If error, assume no subcategories
    }
  }

  // ✅ NEW: Get categories by parent ID (for hierarchical navigation)
  Future<void> getCategoriesByParent(
    int parentId, {
    bool isInitialLoad = false,
  }) async {
    if (_isFetching) {
      return;
    }

    if (!_hasMore && !isInitialLoad) {
      return;
    }

    _isFetching = true;

    if (isInitialLoad) {
      _currentPage = 1;
      _categories.clear();
      emit(CategoriesLoading());
    } else {
      emit(
        CategoriesLoaded(
          categories: List.from(_categories),
          isLoadingMore: true,
          hasMore: _hasMore,
        ),
      );
    }

    try {
      final result = await _getCategoriesByParent(
        parentId: parentId,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );
      result.fold((failure) => emit(CategoriesError("Failed to load: $failure")), (
        response,
      ) {
        final newCategories = response.categories;

        // ✅ LOG: Track what subcategories are being loaded
        AppLogger.info(
          '📦 Loaded ${newCategories.length} subcategories for parent $parentId:',
        );
        for (final category in newCategories) {
          AppLogger.info(
            '  - ${category.name} (ID: ${category.id}, ParentID: ${category.parentId})',
          );
        }

        _categories.addAll(newCategories);
        _hasMore = newCategories.length == _pageSize;

        if (_hasMore) _currentPage++;

        emit(
          CategoriesLoaded(
            categories: List.from(_categories),
            isLoadingMore: false,
            hasMore: _hasMore,
          ),
        );
      });
    } catch (e) {
      emit(CategoriesError("Exception: $e"));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> getCategories({bool isInitialLoad = false}) async {
    if (_isFetching) return;
    if (!_hasMore && !isInitialLoad) return;

    _isFetching = true;

    if (isInitialLoad) {
      _currentPage = 1;
      _categories.clear();
      emit(CategoriesLoading());
    } else {
      emit(
        CategoriesLoaded(
          categories: currentCategories,
          isLoadingMore: true,
          hasMore: _hasMore,
        ),
      );
    }

    try {
      final result = await _getCategories(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      result.fold(
        (failure) => emit(CategoriesError("Failed to load: $failure")),
        (response) {
          final newCategories = response.categories;
          _categories.addAll(newCategories);
          _hasMore = newCategories.length == _pageSize;
          if (_hasMore) _currentPage++;

          emit(
            CategoriesLoaded(
              categories: currentCategories,
              isLoadingMore: false,
              hasMore: _hasMore,
            ),
          );
        },
      );
    } catch (e) {
      emit(CategoriesError("Exception: $e"));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> createCategory(
    String name,
    File imageFile, {
    int? parentId,
    String? nameArabic,
    String? color,
  }) async {
    emit(CategoriesFormSubmitting());
    final result = await _createCategory(
      name,
      imageFile,
      parentId: parentId,
      nameArabic: nameArabic,
      color: color,
    );
    result.fold(
      (failure) => emit(CategoriesFormError("Failed to create: $failure")),
      (category) async {
        emit(CategoriesFormSuccess(category));
        // Refresh the current view after successful creation
        await refresh();
      },
    );
  }

  Future<void> updateCategory(
    int id,
    String name,
    File imageFile, {
    int? parentId,
    String? nameArabic,
    String? color,
  }) async {
    emit(CategoriesFormSubmitting());
    final result = await _updateCategory(
      id,
      name,
      imageFile,
      parentId: parentId,
      nameArabic: nameArabic,
      color: color,
    );
    result.fold(
      (failure) => emit(CategoriesFormError("Failed to update: $failure")),
      (voidcategory) async {
        emit(
          CategoriesFormSuccess(
            Category(
              id: id,
              name: name,
              imagePath: imageFile.path,
              parentId: parentId,
              nameArabic: nameArabic,
              color: color,
            ),
          ),
        );
        // Refresh the current view after successful update
        await refresh();
      },
    );
  }

  Future<void> deleteCategory(int id) async {
    emit(CategoryDeleting());
    final result = await _deleteCategory(id);
    result.fold(
      (failure) {
        emit(CategoryDeleteError(failure.toString()));
        // Re-emit the loaded state with current data
        emit(
          CategoriesLoaded(
            categories: currentCategories,
            isLoadingMore: false,
            hasMore: _hasMore,
          ),
        );
      },
      (_) {
        // Remove the deleted category from the list
        _categories.removeWhere((category) => category.id == id);
        // Emit deleted state first (for any UI feedback)
        emit(CategoryDeleted());
        // Then update with the current list
        emit(
          CategoriesLoaded(
            categories: currentCategories,
            isLoadingMore: false,
            hasMore: _hasMore,
          ),
        );
      },
    );
  }
}
