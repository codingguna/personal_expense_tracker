import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  DateTime date = DateTime.now();
  bool isSaving = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  // ---------------- SAVE EXPENSE ----------------

  Future<void> _saveExpense() async {
    if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User not logged in';

      await Supabase.instance.client.from('expenses').insert({
        'title': titleCtrl.text.trim(),
        'amount': double.parse(amountCtrl.text.trim()),
        'expense_date': date.toIso8601String(),
        'category': 'General',
        'user_id': user.id,
      });

      if (!mounted) return;

      // ✅ SUCCESS SNACKBAR
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 🔹 TEAL HEADER
          Container(
            height: height * 0.35,
            color: const Color(0xFF338B85),
          ),

          // 🔹 HEADER BAR
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
                    'Add Expense',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz,
                        color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // 🔹 CENTERED WHITE CARD
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: height * 0.18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: Container(
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
                            '\$ ',
                            style: TextStyle(
                              color: Color(0xFF338B85),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          suffix: TextButton(
                            onPressed: () => amountCtrl.clear(),
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                color: Color(0xFF338B85),
                              ),
                            ),
                          ),
                          focused: true,
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
                          hint: DateFormat('EEE, dd MMM yyyy').format(date),
                          suffixIcon:
                              const Icon(Icons.calendar_month_outlined),
                        ),
                      ),
                      const SizedBox(height: 18),

_label('CATEGORY'),

Container(
  height: 60,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.grey.shade300,
      width: 1,
    ),
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category selector coming soon'),
        ),
      );
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey.shade600,
          child: const Icon(
            Icons.add,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Add Category',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      ],
    ),
  ),
),


                      const SizedBox(height: 24),

                      // 🔹 SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveExpense,
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
                              : const Text(
                                  'Save Expense',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

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
    String? hint,
    bool focused = false,
    Widget? suffixIcon,
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
}
