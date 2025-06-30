import 'package:catalog_app/core/route/app_routes.dart';
import 'package:catalog_app/features/category/presentation/cubit/categories_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/category.dart';
import 'category_card.dart';

class CategoriesList extends StatelessWidget {
  final List<Category> categories;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final bool isAdmin;

  const CategoriesList({
    super.key,
    required this.categories,
    required this.scrollController,
    this.isLoadingMore = false,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: ResponsiveUtils.getMaxContentWidth(context),
      ),
      child: ListView.builder(
        controller: scrollController,
        padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
          top: ResponsiveUtils.getResponsiveSpacing(context, 16),
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        itemCount: categories.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < categories.length) {
            final category = categories[index];
            return CategoryCard(
              category: category,
              index: index,
              isAdmin: isAdmin,
              onEdit:
                  () => context
                      .push(
                        AppRoutes.categoryForm,
                        extra: {'category': category},
                      )
                      .then((_) {
                        // This runs when returning to CategoriesScreen
                        if (context.mounted) {
                          context.read<CategoriesCubit>().getCategories(
                            isInitialLoad: true,
                          );
                        }
                      }),
              onDelete: () => _showDeleteDialog(context, category),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    // Get the cubit before showing the dialog
    final cubit = BlocProvider.of<CategoriesCubit>(context);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Delete Category'.tr()),
            content: Text(
              '${'Are you sure you want to delete'.tr()} ${category.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel'.tr()),
              ),
              TextButton(
                onPressed: () {
                  cubit.deleteCategory(category.id);
                  Navigator.pop(dialogContext);
                },
                child: Text('Delete'.tr()),
              ),
            ],
          ),
    );
  }
}
