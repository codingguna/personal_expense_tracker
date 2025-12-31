// lib/income/income_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'income_model.dart';

class IncomeRepository {
  final SupabaseClient _client;
  
  IncomeRepository(this._client);

  Future<List<Income>> fetchIncomes(String userId) async {
    final response = await _client
        .from('incomes')              
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((e) => Income.fromJson(e))
        .toList();
  }

  // Future<void> addIncome(double amount) async {
  //   final user = _client.auth.currentUser!;
  //   await _client.from('incomes').insert({
  //     'user_id': user.id,
  //     'amount': amount,
  //     'created_at': DateTime.now().toUtc().toIso8601String(),
  //   });
  // }
}
