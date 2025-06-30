import '../../domain/entities/currency.dart';

class CurrencyModel extends Currency {
  const CurrencyModel({
    required super.id,
    required super.name,
    required super.rate,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] as int,
      name: json['name'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'rate': rate};
  }

  CurrencyModel copyWith({int? id, String? name, double? rate}) {
    return CurrencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
    );
  }
}
