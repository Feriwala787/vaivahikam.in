class Scout {
  final String id;
  final String name;
  final String phone;
  final String? territory;
  final int walletBalance;
  final int totalUploads;
  final int trustScore;
  final DateTime createdAt;

  Scout({
    required this.id,
    required this.name,
    required this.phone,
    this.territory,
    this.walletBalance = 0,
    this.totalUploads = 0,
    this.trustScore = 100,
    required this.createdAt,
  });

  factory Scout.fromJson(Map<String, dynamic> json) => Scout(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    territory: json['territory'],
    walletBalance: json['wallet_balance'] ?? 0,
    totalUploads: json['total_uploads'] ?? 0,
    trustScore: json['trust_score'] ?? 100,
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'territory': territory,
    'wallet_balance': walletBalance,
    'total_uploads': totalUploads,
    'trust_score': trustScore,
  };
}
