import 'package:hive/hive.dart';
import 'package:catalog_app/features/category/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<void> cacheCategories(List<CategoryModel> categories);
  Future<List<CategoryModel>> getCachedCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Box<CategoryModel> box;

  CategoryLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    await box.clear();
    for (var category in categories) {
      await box.add(category);
    }
  }

  @override
  Future<List<CategoryModel>> getCachedCategories() async {
    return box.values.toList();
  }
}
