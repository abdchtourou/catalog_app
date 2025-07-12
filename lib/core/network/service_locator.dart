import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import 'package:catalog_app/core/network/api_service.dart';
import 'package:catalog_app/core/network/network_info.dart';
import 'package:catalog_app/features/category/data/datasources/local/category_local_data_source.dart';
import 'package:catalog_app/features/category/data/datasources/remote/category_remote_data_source.dart';
import 'package:catalog_app/features/category/data/models/category_model.dart';
import 'package:catalog_app/features/category/data/repositories/category_repository_impl.dart';
import 'package:catalog_app/features/category/domain/repositories/category_repository.dart';
import 'package:catalog_app/features/category/domain/usecases/create_category_use_case.dart';
import 'package:catalog_app/features/category/domain/usecases/delete_category_use_case.dart';
import 'package:catalog_app/features/category/domain/usecases/get_categories_by_parent_use_case.dart';
import 'package:catalog_app/features/category/domain/usecases/get_categories_use_case.dart';
import 'package:catalog_app/features/category/domain/usecases/get_single_category_use_case.dart';
import 'package:catalog_app/features/category/domain/usecases/update_category_use_case.dart';
import 'package:catalog_app/features/category/presentation/cubit/categories_cubit.dart';
import 'package:catalog_app/features/products/data/datasource/product_remote_data_source.dart';
import 'package:catalog_app/core/cache/product_cache_service.dart';
import 'package:catalog_app/features/products/data/repository/product_repo_impl.dart';
import 'package:catalog_app/features/products/domain/repository/product_repository.dart';
import 'package:catalog_app/features/products/domain/usecase/create_attachment_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/create_product_with_images_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/delete_attachment_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/delete_product_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_all_products_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_all_products_with_search_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_products_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_products_with_search_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_single_attachment_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/get_single_product_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/update_product_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/update_product_with_attachments_use_case.dart';
import 'package:catalog_app/features/products/domain/usecase/update_syrian_price_use_case.dart';
import 'package:catalog_app/features/products/presentation/cubit/productcubit/product_cubit.dart';
import 'package:catalog_app/features/products/presentation/cubit/products_cubit.dart';
import 'package:catalog_app/features/currency/data/datasources/currency_remote_data_source.dart';
import 'package:catalog_app/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:catalog_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:catalog_app/features/currency/domain/usecases/get_currency_use_case.dart';
import 'package:catalog_app/features/currency/domain/usecases/update_currency_rate_use_case.dart';
import 'package:catalog_app/features/currency/presentation/cubit/currency_cubit.dart';

/// Service Locator for dependency injection
/// Uses GetIt package for managing dependencies
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
/// Call this method in main() before running the app
Future<void> init() async {
  // External dependencies
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Core dependencies
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<ApiService>(() => ApiService(networkInfo: sl()));

  // Initialize ProductCacheService
  await ProductCacheService.initialize();

  // Features - Category
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl()),
  );
  // Register the box
  sl.registerLazySingleton<Box<CategoryModel>>(
    () => Hive.box<CategoryModel>('categoriesBox'),
  );
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(sl<Box<CategoryModel>>()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl()),
  );
  sl.registerLazySingleton<CreateCategoryUseCase>(
    () => CreateCategoryUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateCategoryUseCase>(
    () => UpdateCategoryUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(sl()),
  );
  sl.registerLazySingleton<GetSingleCategoryUseCase>(
    () => GetSingleCategoryUseCase(sl()),
  );
  sl.registerLazySingleton<GetCategoriesByParentUseCase>(
    () => GetCategoriesByParentUseCase(sl()),
  );
  sl.registerLazySingleton<CategoriesCubit>(
    () => CategoriesCubit(sl(), sl(), sl(), sl(), sl(), sl()),
  );

  // Features - Product
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepoImpl(productRemoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<GetProductsUseCase>(() => GetProductsUseCase(sl()));

  sl.registerLazySingleton<CreateProductWithImagesUseCase>(
    () => CreateProductWithImagesUseCase(sl()),
  );
  sl.registerLazySingleton<CreateAttachmentUseCase>(
    () => CreateAttachmentUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteAttachmentUseCase>(
    () => DeleteAttachmentUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteAttachmentsUseCase>(
    () => DeleteAttachmentsUseCase(sl()),
  );

  sl.registerLazySingleton<UpdateProductUseCase>(
    () => UpdateProductUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateSyrianPriceUseCase>(
    () => UpdateSyrianPriceUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteProductUseCase>(
    () => DeleteProductUseCase(sl()),
  );

  sl.registerLazySingleton<GetSingleProductUseCase>(
    () => GetSingleProductUseCase(sl()),
  );

  sl.registerLazySingleton<GetProductsWithSearchUseCase>(
    () => GetProductsWithSearchUseCase(sl()),
  );

  sl.registerLazySingleton<GetAllProductsUseCase>(
    () => GetAllProductsUseCase(sl()),
  );

  sl.registerLazySingleton<GetAllProductsWithSearchUseCase>(
    () => GetAllProductsWithSearchUseCase(sl()),
  );

  sl.registerLazySingleton<GetSingleAttachmentUseCase>(
    () => GetSingleAttachmentUseCase(sl()),
  );

  sl.registerLazySingleton<UpdateProductWithAttachmentsUseCase>(
    () => UpdateProductWithAttachmentsUseCase(sl()),
  );

  sl.registerFactory<ProductsCubit>(
    () => ProductsCubit(
      sl<GetProductsUseCase>(),
      sl<GetProductsWithSearchUseCase>(),
      sl<CreateProductWithImagesUseCase>(),
      sl<CreateAttachmentUseCase>(),
      sl<DeleteAttachmentUseCase>(),
      sl<DeleteAttachmentsUseCase>(),
      sl<UpdateProductUseCase>(),
      sl<UpdateProductWithAttachmentsUseCase>(),
      sl<DeleteProductUseCase>(),
      sl<NetworkInfo>(),
    ),
  );

  sl.registerFactory<ProductCubit>(
    () => ProductCubit(
      sl<GetSingleProductUseCase>(),
      sl<GetSingleAttachmentUseCase>(),
      sl<CreateAttachmentUseCase>(),
      sl<DeleteAttachmentUseCase>(),
      sl<DeleteProductUseCase>(),
      sl<NetworkInfo>(),
    ),
  );

  // Features - Currency
  sl.registerLazySingleton<CurrencyRemoteDataSource>(
    () => CurrencyRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<GetCurrencyUseCase>(() => GetCurrencyUseCase(sl()));
  sl.registerLazySingleton<UpdateCurrencyRateUseCase>(
    () => UpdateCurrencyRateUseCase(sl()),
  );
  sl.registerFactory<CurrencyCubit>(
    () => CurrencyCubit(
      getCurrencyUseCase: sl(),
      updateCurrencyRateUseCase: sl(),
    ),
  );
}

/// Convenience getters for commonly used services
ApiService get apiService => sl<ApiService>();

NetworkInfo get networkInfo => sl<NetworkInfo>();
