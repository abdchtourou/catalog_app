import 'package:catalog_app/core/config/app_config.dart';
import 'package:catalog_app/core/constants/app_strings.dart';
import 'package:catalog_app/core/network/service_locator.dart';
import 'package:catalog_app/core/route/app_routes.dart';
import 'package:catalog_app/features/category/presentation/widgets/expandable_categories_list.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/sharedWidgets/custom_app_bar.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/screen_size.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenSize
    ScreenSize.init(context);

    // Check if categories are already loaded, if not, fetch them
    final cubit = context.read<CategoriesCubit>();
    final currentState = cubit.state;
    if (currentState is CategoriesInitial ||
        (currentState is CategoriesLoaded && currentState.categories.isEmpty)) {
      cubit.getCategories(isInitialLoad: true);
    }

    // Use global admin configuration
    final isAdmin = AppConfig.isAdmin;
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: AppStrings.categoriesTitle.tr(),
        onMenuPressed: () {},
        onSearchChanged: (value) {},
        showSearch: false,
      ),
      floatingActionButton:
          isAdmin ? _buildFloatingActionButton(context) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8FAFC),
              const Color(0xFFE2E8F0).withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoading) {
                  return _buildLoadingState(context);
                }

                if (state is CategoriesError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is CategoriesLoaded) {
                  if (state.categories.isEmpty) {
                    return _buildEmptyState(context, isAdmin);
                  }

                  return _buildCategoriesContent(context, state, isAdmin);
                }

                // Handle delete-related states to prevent blank screen
                if (state is CategoryDeleting) {
                  return _buildLoadingState(context);
                }

                if (state is CategoryDeleteError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is CategoryDeleted) {
                  // Show a brief success indicator while waiting for fresh data
                  return _buildLoadingState(context);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return SizedBox(
      width: ResponsiveUtils.getResponsiveFABSize(context),
      height: ResponsiveUtils.getResponsiveFABSize(context),
      child: FloatingActionButton(
        onPressed: () async {
          await context.push(AppRoutes.categoryForm, extra: {'category': null});
        },
        backgroundColor: const Color(0xFFFF8A95),
        foregroundColor: Colors.white,
        elevation: ResponsiveUtils.getResponsiveElevation(context, 6.0),
        child: Icon(
          Icons.add_rounded,
          size: ResponsiveUtils.getResponsiveIconSize(context, 28.0),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 32.0),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context, 24.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    24.0,
                  ),
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 80.0),
                  height: ResponsiveUtils.getResponsiveSpacing(context, 80.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveSpacing(context, 40.0),
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth:
                          ResponsiveUtils.isTablet(context) ? 4.0 : 3.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
                ),
                Text(
                  'Loading categories...'.tr(),
                  style: TextStyle(
                    fontSize:
                        18.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                ),
                Text(
                  'Please wait while we fetch your categories'.tr(),
                  style: TextStyle(
                    fontSize:
                        15.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                    color: const Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 40.0),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, 28.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      32.0,
                    ),
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 24.0),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.1),
                          Colors.red.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(
                          context,
                          20.0,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        72.0,
                      ),
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 28.0),
                  ),
                  Text(
                    'Oops! Something went wrong'.tr(),
                    style: TextStyle(
                      fontSize:
                          22.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize:
                          16.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 36.0),
                  ),
                  _buildRetryButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ResponsiveUtils.getResponsiveButtonHeight(context),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A95).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<CategoriesCubit>().getCategories(isInitialLoad: true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: ResponsiveUtils.getResponsiveButtonPadding(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh_rounded,
              size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
            Text(
              AppStrings.retry.tr(),
              style: TextStyle(
                fontSize: 17.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isAdmin) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 40.0),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, 28.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      24.0,
                    ),
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 28.0),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF64748B).withOpacity(0.1),
                          const Color(0xFF64748B).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(
                          context,
                          24.0,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        88.0,
                      ),
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 28.0),
                  ),
                  Text(
                    'No categories yet'.tr(),
                    style: TextStyle(
                      fontSize:
                          26.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                  ),
                  Text(
                    'Start organizing your products by creating your first category'
                        .tr(),
                    style: TextStyle(
                      fontSize:
                          17.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isAdmin) ...[
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        36.0,
                      ),
                    ),
                    _buildCreateFirstCategoryButton(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateFirstCategoryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ResponsiveUtils.getResponsiveButtonHeight(context),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A95).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          await context.push(AppRoutes.categoryForm, extra: {'category': null});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: ResponsiveUtils.getResponsiveButtonPadding(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
            Text(
              'Create First Category'.tr(),
              style: TextStyle(
                fontSize: 17.0 * ResponsiveUtils.getFontSizeMultiplier(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesContent(
    BuildContext context,
    CategoriesLoaded state,
    bool isAdmin,
  ) {
    return Column(
      children: [
        // Header section with enhanced tablet styling
        Container(
          margin: ResponsiveUtils.getResponsiveMargin(context),
          padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
            top: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
            bottom: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
                  ),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
                  ),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 28.0),
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${state.categories.length} ${'Categories'.tr()}',
                      style: TextStyle(
                        fontSize:
                            20.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Organize your products efficiently'.tr(),
                      style: TextStyle(
                        fontSize:
                            14.0 *
                            ResponsiveUtils.getFontSizeMultiplier(context),
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Categories list with pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<CategoriesCubit>().refresh();
            },
            color: const Color(0xFFFF8A95),
            backgroundColor: Colors.white,
            strokeWidth: ResponsiveUtils.isTablet(context) ? 3.0 : 2.5,
            child: ExpandableCategoriesList(
              categories: state.categories,
              isLoadingMore: state.isLoadingMore,
              hasMore: state.hasMore,
              onEndReached: () {
                context.read<CategoriesCubit>().getCategories();
              },
              isAdmin: isAdmin,
            ),
          ),
        ),

        // Loading more indicator
        if (state.isLoadingMore) _buildLoadingMoreIndicator(context),
      ],
    );
  }

  Widget _buildLoadingMoreIndicator(BuildContext context) {
    return Container(
      margin: ResponsiveUtils.getResponsiveMargin(context),
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 20.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
            height: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF8A95),
              ),
              strokeWidth: ResponsiveUtils.isTablet(context) ? 3.0 : 2.5,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
          Text(
            'Loading more categories...'.tr(),
            style: TextStyle(
              fontSize: 15.0 * ResponsiveUtils.getFontSizeMultiplier(context),
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
