import 'package:supabase_flutter/supabase_flutter.dart';
import 'expense_model.dart';

class ExpenseRepository {
  final _client = Supabase.instance.client;

  Future<List<Expense>> getExpenses(String userId) async {
    final res = await _client
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .order('expense_date', ascending: false);

    return (res as List).map((e) => Expense.fromJson(e)).toList();
  }

  Future<void> addExpense(Map<String, dynamic> data) async {
    await _client.from('expenses').insert(data);
  }

  Future<void> updateExpense(String id, Map<String, dynamic> data) async {
    await _client.from('expenses').update(data).eq('id', id);
  }

  Future<void> deleteExpense(String id) async {
    await _client.from('expenses').delete().eq('id', id);
  }
}
