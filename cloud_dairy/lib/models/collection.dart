class Collection {
  final String id;
  final String farmerId;
  final DateTime date;
  final String shift;
  final double qty;
  final double fat;
  final double snf;
  final double rate;
  final double amount;

  Collection({
    required this.id,
    required this.farmerId,
    required this.date,
    required this.shift,
    required this.qty,
    required this.fat,
    required this.snf,
    required this.rate,
    required this.amount,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['_id'],
      farmerId: json['farmerId'],
      date: DateTime.parse(json['date']),
      shift: json['shift'],
      qty: (json['qty'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      snf: (json['snf'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}
