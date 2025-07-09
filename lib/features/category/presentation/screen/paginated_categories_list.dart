// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import '../../domain/entities/category.dart';
// import '../widgets/categories_list.dart';
//
// class PaginatedCategoriesList extends StatefulWidget {
//   final List<Category> categories;
//   final bool isLoadingMore;
//   final bool hasMore;
//   final VoidCallback onEndReached;
//   final bool isAdmin;
//
//   const PaginatedCategoriesList({
//     super.key,
//     required this.categories,
//     required this.isLoadingMore,
//     required this.hasMore,
//     required this.onEndReached,
//     required this.isAdmin,
//   });
//
//   @override
//   State<PaginatedCategoriesList> createState() =>
//       _PaginatedCategoriesListState();
// }
//
// class _PaginatedCategoriesListState extends State<PaginatedCategoriesList> {
//   late final ScrollController _scrollController;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController()..addListener(_onScroll);
//     WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
//   }
//
//   void _onScroll() {
//     final position = _scrollController.position;
//     if (position.pixels >= position.maxScrollExtent - 200) {
//       if (widget.hasMore && !widget.isLoadingMore) {
//         widget.onEndReached();
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CategoriesList(
//       categories: widget.categories,
//       scrollController: _scrollController,
//       isLoadingMore: widget.isLoadingMore,
//       isAdmin: widget.isAdmin,
//     );
//   }
// }
