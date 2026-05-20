class CreditTransaction {
  final String id;
  final String scoutId;
  final String type; // earned, spent, purchased, penalty
  final int amount;
  final String? description;
  final DateTime timestamp;

  CreditTransaction({
    required this.id,
    required this.scoutId,
    required this.type,
    required this.amount,
    this.description,
    required this.timestamp,
  });

  factory CreditTransaction.fromJson(Map<String, dynamic> json) => CreditTransaction(
    id: json['id'],
    scoutId: json['scout_id'],
    type: json['type'],
    amount: json['amount'],
    description: json['description'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
