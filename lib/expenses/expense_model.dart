import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class Expense {
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  final String title;
  final double amount;
  final String category;

  @JsonKey(name: 'expense_date')
  final DateTime expenseDate;

  Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.expenseDate,
  });

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
