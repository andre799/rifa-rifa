class RifaModel {
  final String name;
  final num number;
  final bool paid;

  RifaModel(this.name, this.number, this.paid);

  factory RifaModel.fromMap(Map<String, dynamic> map) {
    return RifaModel(
        map['nome'] ?? '', map['numero'] ?? 0, map['pago'] ?? false);
  }
}
