import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart'; // Removed to avoid network dependency
import 'package:hive_flutter/adapters.dart';

import 'core/constants/app_strings.dart';
import 'core/network/service_locator.dart';
import 'core/route/app_router.dart';
import 'core/cache/image_cache_service.dart';
import 'core/cache/product_cache_service.dart';
import 'features/category/data/models/category_model.dart';
import 'features/products/data/model/product_model.dart';
import 'features/currency/presentation/cubit/currency_cubit.dart';
import 'features/products/data/model/attachment_model.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CategoryModelAdapter());
  await Hive.openBox<CategoryModel>('categoriesBox');

  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(AttachmentModelAdapter());
  await Hive.openBox('productsBox');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  await ImageCacheService.initialize();
  await ProductCacheService.initialize();
  await init();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar')], // Only Arabic supported
      path: 'assets/localization',
      fallbackLocale: const Locale('ar'), // Arabic as fallback
      startLocale: const Locale('ar'), // Force Arabic as start locale
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CurrencyCubit>()..getCurrency(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle.tr(),
        locale: const Locale('ar'), // Force Arabic locale
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        routerConfig: appRouter,
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFFC1D4)),
          useMaterial3: true,
          fontFamily: 'Roboto', // Use Roboto as fallback (similar to Inter)
        ),
      ),
    );
  }
}
