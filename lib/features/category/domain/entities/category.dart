import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String imagePath;
  final int? parentId;
  final String? nameArabic;
  final String? color;

  const Category({
    required this.id,
    required this.name,
    required this.imagePath,
    this.parentId,
    this.nameArabic,
    this.color,
  });

  @override
  List<Object?> get props => [id, name, imagePath, parentId, nameArabic, color];

  @override
  String toString() {
    return 'Category(id: $id, name: $name, imagePath: $imagePath, parentId: $parentId, nameArabic: $nameArabic, color: $color)';
  }
}
