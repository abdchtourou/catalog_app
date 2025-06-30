class Currency {
  final int id;
  final String name;
  final double rate;

  const Currency({required this.id, required this.name, required this.rate});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency &&
        other.id == id &&
        other.name == name &&
        other.rate == rate;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ rate.hashCode;

  @override
  String toString() => 'Currency(id: $id, name: $name, rate: $rate)';
}
