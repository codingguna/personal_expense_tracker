import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'expense_model.dart';
import 'expense_repository.dart';

final expenseRepositoryProvider =
    Provider<ExpenseRepository>((ref) => ExpenseRepository());

final expenseListProvider = FutureProvider<List<Expense>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser!;
  return ref
      .read(expenseRepositoryProvider)
      .getExpenses(user.id);
});
