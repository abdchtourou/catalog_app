import 'package:catalog_app/features/products/domain/entities/attachment.dart';
import 'package:hive/hive.dart';

part 'attachment_model.g.dart';

@HiveType(typeId: 3)
class AttachmentModel extends Attachment {
  @HiveField(0)
  final int hiveId;

  @HiveField(1)
  final int? hiveProductId;

  @HiveField(2)
  final String hivePath;

  const AttachmentModel({
    required this.hiveId,
    this.hiveProductId,
    required this.hivePath,
  }) : super(id: hiveId, productId: hiveProductId, path: hivePath);

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      hiveId: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      hiveProductId: json['productId'] is int
          ? json['productId']
          : int.tryParse(json['productId']?.toString() ?? ''),
      hivePath: json['path']?.toString() ?? '',
    );
  }

  factory AttachmentModel.fromEntity(Attachment entity) {
    return AttachmentModel(
      hiveId: entity.id,
      hiveProductId: entity.productId,
      hivePath: entity.path,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': hiveId,
    'productId': hiveProductId,
    'path': hivePath,
  };
}
