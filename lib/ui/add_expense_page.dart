// lib/ui/add_expense_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../expenses/expense_provider.dart';
import '../shared/constant.dart';
import 'widgets/gradient_header.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() =>
      _AddExpensePageState();
}

class _AddExpensePageState
    extends ConsumerState<AddExpensePage> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  String category = expenseCategories.first;
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const GradientHeader(title: 'Add Expense'),

          Positioned.fill(
            top: 160,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding:
                    const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _input('NAME', titleCtrl),
                    const SizedBox(height: 16),

                    _amountInput(),
                    const SizedBox(height: 16),

                    _datePicker(context),
                    const SizedBox(height: 16),

                    _categoryPicker(),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final user = Supabase
                              .instance
                              .client
                              .auth
                              .currentUser!;

                          await ref
                              .read(
                                  expenseRepositoryProvider)
                              .addExpense({
                            'title': titleCtrl.text,
                            'amount': double.parse(
                                amountCtrl.text),
                            'category': category,
                            'expense_date':
                                date.toIso8601String(),
                            'user_id': user.id,
                          });

                          context.pop();
                        },
                        child:
                            const Text('Save Expense'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- INPUTS ----------

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

  Widget _amountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AMOUNT',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '₹ ',
            suffixText: 'Clear',
            suffixStyle:
                TextStyle(color: Color(0xFF2F8F83)),
          ),
        ),
      ],
    );
  }

  Widget _datePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DATE',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (d != null) {
              setState(() => date = d);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon:
                  Icon(Icons.calendar_today),
            ),
            child: Text(
              DateFormat('EEE, dd MMM yyyy')
                  .format(date),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryPicker() {
    return DropdownButtonFormField<String>(
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
    );
  }
}
