// lib/income/income_model.dart

class Income {
  final String id;
  final String title;
  final String userId; 
  final double amount;
  final DateTime? createdAt;

  Income({
    required this.id,
    required this.title,
    required this.userId,
    required this.amount,
    required this.createdAt,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] as String,
      title: json['title'] as String,
      userId: json['user_id'] as String, 
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at']),
    );
  }
}
