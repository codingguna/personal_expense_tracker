// lib/ui/widgets/balance_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../expenses/expense_provider.dart';
import '../../income/income_provider.dart';
import 'balance_chip.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseListProvider);
    final incomesAsync = ref.watch(incomeListProvider);

    final expenses =
        expensesAsync.value ?? [];
    final incomes =
        incomesAsync.value ?? [];

    final totalExpense = expenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    final totalIncome = incomes.fold<double>(
      0,
      (sum, i) => sum + i.amount,
    );

    final balance = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2F7F78),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${balance.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BalanceChip(
                icon: Icons.arrow_downward,
                label: 'Income',
                amount:
                    '₹${totalIncome.toStringAsFixed(0)}',
              ),
              BalanceChip(
                icon: Icons.arrow_upward,
                label: 'Expenses',
                amount:
                    '₹${totalExpense.toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
