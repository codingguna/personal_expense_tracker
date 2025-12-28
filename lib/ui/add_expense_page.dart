import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../expenses/expense_provider.dart';
import '../shared/constant.dart';
import '../shared/validators.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() =>
      _AddExpensePageState();
}

class _AddExpensePageState
    extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String category = expenseCategories.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleCtrl,
                validator: requiredValidator,
                decoration:
                    const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountCtrl,
                validator: requiredValidator,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                items: expenseCategories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => category = v!),
                decoration:
                    const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user =
                        Supabase.instance.client.auth.currentUser!;
                    await ref
                        .read(expenseRepositoryProvider)
                        .addExpense({
                      'title': titleCtrl.text,
                      'amount':
                          double.parse(amountCtrl.text),
                      'category': category,
                      'expense_date':
                          selectedDate.toIso8601String(),
                      'user_id': user.id,
                    });
                    context.pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }
}
