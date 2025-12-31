// lib/ui/edit_expense_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../expenses/expense_model.dart';
import '../expenses/expense_provider.dart';
import '../shared/constant.dart';

class EditExpensePage extends ConsumerStatefulWidget {
  final Expense expense;
  const EditExpensePage({super.key, required this.expense});

  @override
  ConsumerState<EditExpensePage> createState() =>
      _EditExpensePageState();
}

class _EditExpensePageState
    extends ConsumerState<EditExpensePage> {
  late TextEditingController titleCtrl;
  late TextEditingController amountCtrl;
  late String category;

  @override
  void initState() {
    super.initState();
    titleCtrl =
        TextEditingController(text: widget.expense.title);
    amountCtrl = TextEditingController(
        text: widget.expense.amount.toString());
    category = widget.expense.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _input('NAME', titleCtrl),
              const SizedBox(height: 16),

              _input('AMOUNT', amountCtrl),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: category,
                items: expenseCategories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => category = v!),
                decoration: const InputDecoration(
                    labelText: 'Category'),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(expenseRepositoryProvider)
                        .updateExpense(
                      widget.expense.id,
                      {
                        'title': titleCtrl.text,
                        'amount': double.parse(
                            amountCtrl.text),
                        'category': category,
                      },
                    );
                    context.pop();
                  },
                  child: const Text('Update Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(controller: c),
      ],
    );
  }
}
