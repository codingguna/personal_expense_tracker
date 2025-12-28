import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../expenses/expense_provider.dart';
import '../expenses/expense_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: expenses.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No expenses yet'),
            );
          }

          final total = list.fold<double>(
            0,
            (sum, e) => sum + e.amount,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Total: ₹$total',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final Expense expense = list[i];

                    return ListTile(
                      title: Text(expense.title),
                      subtitle: Text(expense.category),
                      trailing:
                          Text('₹${expense.amount}'),
                      onTap: () {
                        context.go(
                          '/edit',
                          extra: expense,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
