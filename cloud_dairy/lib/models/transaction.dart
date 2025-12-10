class Transaction {
  final String id;
  final String farmerId;
  final String type; // payment, advance, collection
  final double amount;
  final String mode;
  final String description;
  final DateTime date;

  Transaction({
    required this.id,
    required this.farmerId,
    required this.type,
    required this.amount,
    required this.mode,
    required this.description,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      farmerId: json['farmerId'],
      type: json['type'],
      amount: (json['amount'] ?? 0).toDouble(),
      mode: json['mode'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }
}
