// lib/ui/wallet_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../expenses/expense_provider.dart';
import 'widgets/income_provider.dart';
import 'widgets/gradient_header.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseListProvider);
    final income = ref.watch(incomeProvider);

    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(title: 'Wallet'),

          Positioned.fill(
            top: 160,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: expensesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text(e.toString())),
                data: (expenses) {
                  final totalSpent = expenses.fold<double>(
                    0,
                    (sum, e) => sum + e.amount,
                  );

                  final remaining = income - totalSpent;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryCard(
                        context,
                        ref,
                        income: income,
                        spent: totalSpent,
                        remaining: remaining,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Spending History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: expenses.isEmpty
                            ? const Center(
                                child: Text('No spending yet'),
                              )
                            : ListView.separated(
                                itemCount: expenses.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(),
                                itemBuilder: (_, i) {
                                  final e = expenses[i];
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor:
                                          Color(0xFFEEF6F5),
                                      child: Icon(
                                        Icons.shopping_bag,
                                        color:
                                            Color(0xFF2F8F83),
                                      ),
                                    ),
                                    title: Text(e.title),
                                    subtitle: Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(e.expenseDate),
                                    ),
                                    trailing: Text(
                                      '- ₹${e.amount}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SUMMARY CARD ----------------

  Widget _summaryCard(
    BuildContext context,
    WidgetRef ref, {
    required double income,
    required double spent,
    required double remaining,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2F8F83),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit,
                    color: Colors.white),
                onPressed: () =>
                    _editIncome(context, ref, income),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _summaryRow(
            label: 'Total Income',
            value: '₹${income.toStringAsFixed(0)}',
            color: Colors.white,
          ),
          const SizedBox(height: 12),

          _summaryRow(
            label: 'Spent',
            value: '₹${spent.toStringAsFixed(0)}',
            color: Colors.redAccent,
          ),

          const Divider(color: Colors.white30, height: 32),

          _summaryRow(
            label: 'Remaining',
            value: '₹${remaining.toStringAsFixed(0)}',
            color: Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ---------------- EDIT INCOME DIALOG ----------------

  void _editIncome(
    BuildContext context,
    WidgetRef ref,
    double currentIncome,
  ) {
    final ctrl =
        TextEditingController(text: currentIncome.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Income'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(incomeProvider.notifier)
                  .updateIncome(
                    double.parse(ctrl.text),
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
