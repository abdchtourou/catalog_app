import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/category.dart';
import 'hierarchical_category_card.dart';

class HierarchicalCategoriesList extends StatefulWidget {
  final List<Category> categories;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onEndReached;
  final bool isAdmin;

  const HierarchicalCategoriesList({
    super.key,
    required this.categories,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onEndReached,
    required this.isAdmin,
  });

  @override
  State<HierarchicalCategoriesList> createState() =>
      _HierarchicalCategoriesListState();
}

class _HierarchicalCategoriesListState extends State<HierarchicalCategoriesList>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        controller: _scrollController,
        padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
          top: ResponsiveUtils.getResponsiveSpacing(context, 8),
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 24),
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: widget.categories.length + (widget.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < widget.categories.length) {
            final category = widget.categories[index];

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 200 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: HierarchicalCategoryCard(
                      category: category,
                      index: index,
                      isAdmin: widget.isAdmin,
                    ),
                  ),
                );
              },
            );
          } else {
            return _buildLoadingIndicator(context);
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
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
              ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
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
                height: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              ),
              Text(
                'Loading more categories...'.tr(),
                style: TextStyle(
                  fontSize:
                      14.0 * ResponsiveUtils.getFontSizeMultiplier(context),
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
}
