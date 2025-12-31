// lib/income/income_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'income_repository.dart';
import 'income_model.dart';

/// Supabase client provider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Repository provider
final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  final client = ref.read(supabaseProvider);
  return IncomeRepository(client);
});

/// Income list provider (used by statistics page)
final incomeListProvider = FutureProvider<List<Income>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser!;
  final repo = ref.read(incomeRepositoryProvider);
  return repo.fetchIncomes(user.id);
});

