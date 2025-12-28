// lib/ui/edit_expense_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../expenses/expense_model.dart';
import '../expenses/expense_provider.dart';
import 'package:go_router/go_router.dart';
import '../shared/constant.dart';

class EditExpensePage extends ConsumerWidget {
  final Expense expense;
  const EditExpensePage({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController(text: expense.title);
    final amountCtrl =
        TextEditingController(text: expense.amount.toString());
    String category = expense.category;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleCtrl),
            TextField(controller: amountCtrl),
            DropdownButton<String>(
              value: category,
              items: expenseCategories
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => category = v!,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(expenseRepositoryProvider)
                    .updateExpense(expense.id, {
                  'title': titleCtrl.text,
                  'amount': double.parse(amountCtrl.text),
                  'category': category,
                });
                context.pop();
              },
              child: const Text('Update'),
            )
          ],
        ),
      ),
    );
  }
}
