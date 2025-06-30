import 'package:hive/hive.dart';
import 'package:catalog_app/features/category/domain/entities/category.dart';

part 'category_model.g.dart'; // Needed for code generation

@HiveType(typeId: 0)
class CategoryModel extends Category {
  @HiveField(0)
  final int hiveId;

  @HiveField(1)
  final String hiveName;

  @HiveField(3)
  final String? hiveImagePath; // Made nullable

  @HiveField(4)
  final int? hiveParentId; // Added parentId field

  @HiveField(5)
  final String? hiveNameArabic; // Added nameArabic field

  @HiveField(6)
  final String? hiveColor; // Added color field

  const CategoryModel({
    required this.hiveId,
    required this.hiveName,
    this.hiveImagePath, // Now optional
    this.hiveParentId, // Now optional
    this.hiveNameArabic, // Now optional
    this.hiveColor, // Now optional
  }) : super(
         id: hiveId,
         name: hiveName,
         imagePath: hiveImagePath ?? '',
         parentId: hiveParentId,
         nameArabic: hiveNameArabic,
         color: hiveColor,
       );

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      hiveId: json['id'] as int? ?? 0, // Provide default value
      hiveName: json['name'] as String? ?? '', // Provide default value
      hiveImagePath: json['imagePath'] as String?, // Can be null
      hiveParentId: json['parentId'] as int?, // Can be null
      hiveNameArabic: json['nameArabic'] as String?, // Can be null
      hiveColor: json['color'] as String?, // Can be null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': hiveId,
      'name': hiveName,
      'imagePath': hiveImagePath, // Can be null
      'parentId': hiveParentId, // Can be null
      'nameArabic': hiveNameArabic, // Can be null
      'color': hiveColor, // Can be null
    };
  }
}
