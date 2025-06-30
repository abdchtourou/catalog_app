import 'package:catalog_app/features/products/data/model/attachment_model.dart';
import 'package:catalog_app/features/products/domain/entities/product.dart';
import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 1)
class ProductModel extends Product {
  @HiveField(0)
  final int hiveId;

  @HiveField(1)
  final String hiveName;

  @HiveField(2)
  final String hiveDescription;

  @HiveField(3)
  final String hivePrice;

  @HiveField(4)
  final String hiveSyrianPoundPrice;

  @HiveField(5)
  final int hiveCategoryId;

  @HiveField(6)
  final List<AttachmentModel> hiveAttachments;

  const ProductModel({
    required this.hiveId,
    required this.hiveName,
    required this.hiveDescription,
    required this.hivePrice,
    required this.hiveSyrianPoundPrice,
    required this.hiveCategoryId,
    required this.hiveAttachments,
  }) : super(
         id: hiveId,
         name: hiveName,
         description: hiveDescription,
         price: hivePrice,
         syrianPoundPrice: hiveSyrianPoundPrice,
         categoryId: hiveCategoryId,
         attachments: hiveAttachments,
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final attachmentsJson = json['attachments'] as List<dynamic>? ?? [];

    return ProductModel(
      hiveId:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      hiveName: json['name']?.toString() ?? '',
      hiveDescription: json['description']?.toString() ?? '',
      hivePrice: json['price']?.toString() ?? '0',
      hiveSyrianPoundPrice: json['syrianPoundPrice']?.toString() ?? '0',
      hiveCategoryId:
          json['categoryId'] is int
              ? json['categoryId']
              : int.tryParse(json['categoryId']?.toString() ?? '1') ?? 1,
      hiveAttachments:
          attachmentsJson
              .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      hiveId: entity.id,
      hiveName: entity.name,
      hiveDescription: entity.description,
      hivePrice: entity.price,
      hiveSyrianPoundPrice: entity.syrianPoundPrice,
      hiveCategoryId: entity.categoryId,
      hiveAttachments:
          entity.attachments
              .map(
                (x) => x is AttachmentModel ? x : AttachmentModel.fromEntity(x),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': hiveId,
    'name': hiveName,
    'description': hiveDescription,
    'price': hivePrice,
    'syrianPoundPrice': hiveSyrianPoundPrice,
    'categoryId': hiveCategoryId,
    'attachments': hiveAttachments.map((e) => e.toJson()).toList(),
  };
}
