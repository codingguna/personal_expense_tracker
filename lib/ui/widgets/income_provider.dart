// lib/ui/widgets/income_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final incomeProvider = StateNotifierProvider<IncomeNotifier, double>(
  (ref) => IncomeNotifier(),
);

class IncomeNotifier extends StateNotifier<double> {
  IncomeNotifier() : super(0) {
    _loadIncome();
  }

  final _client = Supabase.instance.client;

  Future<void> _loadIncome() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final income = user.userMetadata?['income'] ?? 0;
    state = (income as num).toDouble();
  }

  Future<void> updateIncome(double income) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'income': income}),
    );
    state = income;
  }
}
