class Farmer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double balance;
  final double advance;

  Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.balance = 0.0,
    this.advance = 0.0,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      advance: (json['advance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}
