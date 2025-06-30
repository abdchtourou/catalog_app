import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:catalog_app/core/network/service_locator.dart';
import 'package:catalog_app/core/route/app_routes.dart';
import 'package:catalog_app/features/category/domain/entities/category.dart';
import 'package:catalog_app/features/category/presentation/cubit/categories_cubit.dart';
import 'package:catalog_app/features/category/presentation/screen/category_form_screen.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:catalog_app/features/products/presentation/cubit/all_products_cubit.dart';
import 'package:catalog_app/features/products/presentation/cubit/productcubit/product_cubit.dart';
import 'package:catalog_app/features/products/presentation/cubit/products_cubit.dart';
import 'package:catalog_app/features/products/presentation/screen/all_products_screen.dart';
import 'package:catalog_app/features/products/presentation/screen/product_details_screen.dart';
import 'package:catalog_app/features/products/presentation/screen/product_form_screen.dart';
import 'package:catalog_app/features/products/presentation/screen/products_screen.dart';

import '../../features/category/presentation/screen/categories_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<CategoriesCubit>(),
          child: CategoriesScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.products,
      builder: (context, state) {
        final extra = state.extra;
        String? categoryId;
        String? categoryName;
        if (extra is Map) {
          categoryId = extra['categoryId'] as String?;
          categoryName = extra['categoryName'] as String?;
        }

        // ✅ FIX: Validate categoryId before proceeding
        if (categoryId == null || categoryId.isEmpty) {
          // Return error screen or redirect to categories
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Invalid category ID'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text('Back to Categories'),
                  ),
                ],
              ),
            ),
          );
        }

        return BlocProvider(
          create:
              (context) =>
                  sl<ProductsCubit>()..getProducts(
                    categoryId!,
                    isInitialLoad: true,
                  ), // Safe to use ! since we validated above
          child: ProductsScreen(
            categoryTitle: categoryName,
            categoryId: categoryId,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.product,
      builder: (context, state) {
        final extra = state.extra;
        int? productId;
        if (extra is Map) {
          productId = extra['productId'] as int?;
        }
        return BlocProvider(
          create: (context) => sl<ProductCubit>()..getProduct(productId ?? 1),
          child: ProductDetailsScreen(productId: productId ?? 1),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.categoryForm,
      builder: (context, state) {
        final extra = state.extra;
        Category? category;
        int? parentId;
        if (extra is Map) {
          category = extra['category'] as Category?;
          parentId = extra['parentId'] as int?;
        }
        return BlocProvider(
          create: (context) => sl<CategoriesCubit>(),
          child: CategoryFormScreen(category: category, parentId: parentId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.allProducts,
      builder: (context, state) {
        return BlocProvider(
          create:
              (context) =>
                  sl<AllProductsCubit>()..getAllProducts(isInitialLoad: true),
          child: const AllProductsScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.productForm,
      builder: (context, state) {
        final extra = state.extra;
        Product? product;
        String? categoryId;
        if (extra is Map) {
          product = extra['product'] as Product?;
          categoryId = extra['categoryId'] as String?;
        }
        return BlocProvider(
          create: (context) => sl<ProductsCubit>(),
          child: ProductFormScreen(product: product, categoryId: categoryId),
        );
      },
    ),
  ],
);
