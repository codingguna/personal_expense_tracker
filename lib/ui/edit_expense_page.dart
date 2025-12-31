import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../expenses/expense_model.dart';
import '../expenses/expense_provider.dart';

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
  late DateTime date;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.expense.title);
    amountCtrl =
        TextEditingController(text: widget.expense.amount.toString());
    date = widget.expense.expenseDate;
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateExpense() async {
    setState(() => isSaving = true);

    await ref.read(expenseRepositoryProvider).updateExpense(
      widget.expense.id,
      {
        'title': titleCtrl.text.trim(),
        'amount': double.parse(amountCtrl.text.trim()),
        'expense_date': date.toIso8601String(),
      },
    );

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: height * 0.35,
            color: const Color(0xFF338B85),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Edit Expense',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: height * 0.18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: _card(
                  children: [
                    _label('NAME'),
                    TextField(
                      controller: titleCtrl,
                      decoration: _inputDecoration(),
                    ),

                    const SizedBox(height: 18),

                    _label('AMOUNT'),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        prefix: const Text(
                          '₹ ',
                          style: TextStyle(
                            color: Color(0xFF338B85),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    _label('DATE'),
                    TextField(
                      readOnly: true,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => date = d);
                      },
                      decoration: _inputDecoration(
                        hint:
                            DateFormat('EEE, dd MMM yyyy').format(date),
                        suffixIcon:
                            const Icon(Icons.calendar_month_outlined),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _submitButton(
                      isSaving: isSaving,
                      label: 'Update Expense',
                      onPressed: _updateExpense,
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
Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    ),
  );
}

InputDecoration _inputDecoration({
  Widget? prefix,
  Widget? suffix,
  Widget? suffixIcon,
  String? hint,
  bool focused = false,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: prefix == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(left: 12, top: 14),
            child: prefix,
          ),
    suffixIcon: suffix ?? suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: focused
        ? OutlineInputBorder(
            borderSide:
                const BorderSide(color: Color(0xFF338B85)),
            borderRadius: BorderRadius.circular(12),
          )
        : null,
  );
}

Widget _submitButton({
  required bool isSaving,
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSaving
            ? Colors.grey.shade400
            : const Color(0xFF338B85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: isSaving
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    ),
  );
}
Widget _card({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

}
