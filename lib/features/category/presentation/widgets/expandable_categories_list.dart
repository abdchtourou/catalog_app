import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/route/app_routes.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/category.dart';
import '../cubit/categories_cubit.dart';
import 'hierarchical_category_card.dart';

class ExpandableCategoriesList extends StatefulWidget {
  final List<Category> categories;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onEndReached;
  final bool isAdmin;

  const ExpandableCategoriesList({
    super.key,
    required this.categories,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onEndReached,
    required this.isAdmin,
  });

  @override
  State<ExpandableCategoriesList> createState() =>
      _ExpandableCategoriesListState();
}

class _ExpandableCategoriesListState extends State<ExpandableCategoriesList>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  final Set<int> _expandedCategories = <int>{};
  final Map<int, List<Category>> _subcategoriesCache = <int, List<Category>>{};
  final Map<int, bool> _hasSubcategoriesCache = <int, bool>{};
  late final AnimationController _listAnimationController;
  late final Animation<double> _fadeAnimation;

  // Filter to get only root categories for display
  List<Category> get _rootCategories {
    return widget.categories
        .where((category) => category.parentId == null)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _listAnimationController.forward();

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

  Future<void> _toggleExpansion(int categoryId) async {
    final category = widget.categories.firstWhere(
      (cat) => cat.id == categoryId,
    );
    AppLogger.info(
      '🔄 Toggle expansion for category: ${category.name} (ID: $categoryId)',
    );

    // Check if category has subcategories first
    final hasSubcategories = await _checkHasSubcategories(categoryId);
    AppLogger.info(
      '📊 Category $categoryId has subcategories: $hasSubcategories',
    );

    if (!hasSubcategories) {
      // Navigate to products if no subcategories
      AppLogger.info('➡️ No subcategories found, navigating to products');
      _navigateToProducts(category);
      return;
    }

    AppLogger.info('📂 Category has subcategories, handling expansion');

    // Handle expansion/collapse for categories with subcategories
    if (_expandedCategories.contains(categoryId)) {
      AppLogger.info('🔽 Collapsing category $categoryId');
      setState(() {
        _expandedCategories.remove(categoryId);
      });
    } else {
      AppLogger.info('🔼 Expanding category $categoryId');
      // Load subcategories if not already cached
      if (!_subcategoriesCache.containsKey(categoryId)) {
        AppLogger.info('📥 Loading subcategories for category $categoryId');
        await _loadSubcategories(categoryId);
      } else {
        AppLogger.info(
          '💾 Using cached subcategories for category $categoryId',
        );
      }

      setState(() {
        _expandedCategories.add(categoryId);
      });

      final subcategories = _subcategoriesCache[categoryId] ?? [];
      AppLogger.info('📋 Subcategories loaded: ${subcategories.length} items');
      for (final sub in subcategories) {
        AppLogger.info(
          '  - ${sub.name} (ID: ${sub.id}, ParentID: ${sub.parentId})',
        );
      }
    }
  }

  Future<bool> _checkHasSubcategories(int categoryId) async {
    AppLogger.info('🔍 Checking if category $categoryId has subcategories');

    // Return cached result if available
    if (_hasSubcategoriesCache.containsKey(categoryId)) {
      final cached = _hasSubcategoriesCache[categoryId]!;
      AppLogger.info(
        '💾 Using cached result for category $categoryId: $cached',
      );
      return cached;
    }

    // Check from all categories list (includes subcategories)
    final allCategories = widget.categories;
    final hasSubcategories = allCategories.any(
      (category) => category.parentId == categoryId,
    );

    AppLogger.info(
      '✅ Found subcategories in list for category $categoryId: $hasSubcategories',
    );
    _hasSubcategoriesCache[categoryId] = hasSubcategories;
    return hasSubcategories;
  }

  Future<void> _loadSubcategories(int categoryId) async {
    AppLogger.info('📥 Loading subcategories for category $categoryId');

    // Filter from all categories to find subcategories
    final allCategories = widget.categories;
    final subcategories =
        allCategories
            .where((category) => category.parentId == categoryId)
            .toList();

    _subcategoriesCache[categoryId] = subcategories;

    AppLogger.info(
      '✅ Found ${subcategories.length} subcategories for category $categoryId:',
    );
    for (final sub in subcategories) {
      AppLogger.info(
        '  - ${sub.name} (ID: ${sub.id}, ParentID: ${sub.parentId})',
      );
    }
  }

  List<Category> _getSubcategories(Category category) {
    return _subcategoriesCache[category.id] ?? [];
  }

  void _navigateToProducts(Category category) {
    AppLogger.info(
      '🛍️ Navigating to products for category: ${category.name} (ID: ${category.id})',
    );
    context.push(
      AppRoutes.products,
      extra: {
        'categoryId': category.id.toString(),
        'categoryName': category.name,
      },
    );
  }

  void _handleSubcategoryTap(Category subcategory) {
    // Subcategories always navigate to products
    _navigateToProducts(subcategory);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.getMaxContentWidth(context),
        ),
        child: ListView.builder(
          controller: _scrollController,
          padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
            top: ResponsiveUtils.getResponsiveSpacing(context, 8),
            bottom: ResponsiveUtils.getResponsiveSpacing(context, 24),
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: _rootCategories.length + (widget.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _rootCategories.length) {
              final category = _rootCategories[index];
              final isExpanded = _expandedCategories.contains(category.id);
              final subcategories = _getSubcategories(category);

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Column(
                        children: [
                          HierarchicalCategoryCard(
                            category: category,
                            index: index,
                            isAdmin: widget.isAdmin,
                            onTap: () => _toggleExpansion(category.id),
                            enableHierarchicalNavigation: false,
                          ),

                          // Enhanced animated subcategories section
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                            height: isExpanded ? null : 0,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: isExpanded ? 1.0 : 0.0,
                              child:
                                  isExpanded
                                      ? Container(
                                        margin: EdgeInsets.only(
                                          left:
                                              ResponsiveUtils.getResponsiveSpacing(
                                                context,
                                                24.0,
                                              ),
                                          right:
                                              ResponsiveUtils.getResponsiveSpacing(
                                                context,
                                                8.0,
                                              ),
                                          bottom:
                                              ResponsiveUtils.getResponsiveSpacing(
                                                context,
                                                20.0,
                                              ),
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              const Color(
                                                0xFFE2E8F0,
                                              ).withOpacity(0.1),
                                              Colors.transparent,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            ResponsiveUtils.getResponsiveBorderRadius(
                                              context,
                                              16.0,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            // Subcategories header
                                            Container(
                                              margin: EdgeInsets.only(
                                                bottom:
                                                    ResponsiveUtils.getResponsiveSpacing(
                                                      context,
                                                      12.0,
                                                    ),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    ResponsiveUtils.getResponsiveSpacing(
                                                      context,
                                                      16.0,
                                                    ),
                                                vertical:
                                                    ResponsiveUtils.getResponsiveSpacing(
                                                      context,
                                                      8.0,
                                                    ),
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF64748B,
                                                ).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(
                                                  ResponsiveUtils.getResponsiveBorderRadius(
                                                    context,
                                                    12.0,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .subdirectory_arrow_right_rounded,
                                                    color: const Color(
                                                      0xFF64748B,
                                                    ),
                                                    size:
                                                        ResponsiveUtils.getResponsiveIconSize(
                                                          context,
                                                          16.0,
                                                        ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        ResponsiveUtils.getResponsiveSpacing(
                                                          context,
                                                          8.0,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Subcategories'.tr(),
                                                    style: TextStyle(
                                                      fontSize:
                                                          14.0 *
                                                          ResponsiveUtils.getFontSizeMultiplier(
                                                            context,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                        0xFF64748B,
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          ResponsiveUtils.getResponsiveSpacing(
                                                            context,
                                                            8.0,
                                                          ),
                                                      vertical:
                                                          ResponsiveUtils.getResponsiveSpacing(
                                                            context,
                                                            4.0,
                                                          ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF64748B,
                                                      ).withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            ResponsiveUtils.getResponsiveBorderRadius(
                                                              context,
                                                              8.0,
                                                            ),
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${subcategories.length}',
                                                      style: TextStyle(
                                                        fontSize:
                                                            12.0 *
                                                            ResponsiveUtils.getFontSizeMultiplier(
                                                              context,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color(
                                                          0xFF64748B,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Subcategories list
                                            ...subcategories.asMap().entries.map((
                                              entry,
                                            ) {
                                              final subIndex = entry.key;
                                              final subcategory = entry.value;

                                              return TweenAnimationBuilder<
                                                double
                                              >(
                                                duration: Duration(
                                                  milliseconds:
                                                      200 + (subIndex * 100),
                                                ),
                                                tween: Tween(
                                                  begin: 0.0,
                                                  end: 1.0,
                                                ),
                                                curve: Curves.easeOutCubic,
                                                builder: (
                                                  context,
                                                  animValue,
                                                  child,
                                                ) {
                                                  return Transform.translate(
                                                    offset: Offset(
                                                      30 * (1 - animValue),
                                                      0,
                                                    ),
                                                    child: Opacity(
                                                      opacity: animValue.clamp(
                                                        0.0,
                                                        1.0,
                                                      ),
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                          bottom:
                                                              ResponsiveUtils.getResponsiveSpacing(
                                                                context,
                                                                12.0,
                                                              ),
                                                        ),
                                                        child: HierarchicalCategoryCard(
                                                          category: subcategory,
                                                          index: subIndex,
                                                          isAdmin:
                                                              widget.isAdmin,
                                                          onTap:
                                                              () =>
                                                                  _handleSubcategoryTap(
                                                                    subcategory,
                                                                  ),
                                                          enableHierarchicalNavigation:
                                                              false,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Container(
                margin: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 20.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(
                          context,
                          16.0,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF8A95),
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            12.0,
                          ),
                        ),
                        Text(
                          'Loading more categories...'.tr(),
                          style: TextStyle(
                            fontSize:
                                14.0 *
                                ResponsiveUtils.getFontSizeMultiplier(context),
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
