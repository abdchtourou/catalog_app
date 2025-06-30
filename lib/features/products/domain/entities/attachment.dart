import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final int id;
  final int? productId;
  final String path;

  const Attachment({
    required this.id,
    required this.productId,
    required this.path,
  });

  @override
  List<Object?> get props => [id, productId, path];

  @override
  String toString() {
    return 'Attachment(id: $id, productId: $productId, path: $path)';
  }
}
