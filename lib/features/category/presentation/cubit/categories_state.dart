import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object> get props => [];
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;
  final bool isLoadingMore;
  final bool hasMore;

  const CategoriesLoaded({
    required this.categories,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  List<Object> get props => [categories, isLoadingMore, hasMore];

  CategoriesLoaded copyWith({
    List<Category>? categories,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return CategoriesLoaded(
      categories: categories ?? this.categories,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object> get props => [message];
}

// ✅ NEW: for Add/Update actions
class CategoriesFormSubmitting extends CategoriesState {}

class CategoriesFormSuccess extends CategoriesState {
  final Category category;
  const CategoriesFormSuccess(this.category);
}

class CategoriesFormError extends CategoriesState {
  final String message;
  const CategoriesFormError(this.message);
}

class CategoryDeleting extends CategoriesState {}

class CategoryDeleted extends CategoriesState {}

class CategoryDeleteError extends CategoriesState {
  final String message;
  const CategoryDeleteError(this.message);
}

// ✅ NEW: for Single Category operations
class CategoryLoading extends CategoriesState {}

class CategoryLoaded extends CategoriesState {
  final Category category;
  const CategoryLoaded(this.category);

  @override
  List<Object> get props => [category];
}

class CategoryError extends CategoriesState {
  final String message;
  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}

// ✅ NEW: Hierarchical Navigation States
class HierarchicalCategoriesLoaded extends CategoriesState {
  final List<Category> categories;
  final List<Category> navigationStack;
  final int? currentParentId;
  final bool isLoadingMore;
  final bool hasMore;

  const HierarchicalCategoriesLoaded({
    required this.categories,
    required this.navigationStack,
    this.currentParentId,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  @override
  List<Object> get props => [
    categories,
    navigationStack,
    currentParentId ?? 0,
    isLoadingMore,
    hasMore,
  ];

  bool get isAtRootLevel => currentParentId == null;
  String get breadcrumbText {
    if (isAtRootLevel) return 'Categories';
    return navigationStack.map((cat) => cat.name).join(' > ');
  }
}
