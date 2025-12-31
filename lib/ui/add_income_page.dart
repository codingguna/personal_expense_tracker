// lib/ui/add_income_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/gradient_header.dart';
import 'widgets/income_provider.dart';
import 'package:go_router/go_router.dart';

class AddIncomePage extends ConsumerStatefulWidget {
  const AddIncomePage({super.key});

  @override
  ConsumerState<AddIncomePage> createState() =>
      _AddIncomePageState();
}

class _AddIncomePageState
    extends ConsumerState<AddIncomePage> {
  final amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientHeader(title: 'Add Income'),

          Positioned.fill(
            top: 140,
            child: SafeArea(
              top: false,
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(24, 24, 24, 120),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AMOUNT',
                      style:
                          TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountCtrl,
                      keyboardType:
                          TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(incomeProvider.notifier)
                              .updateIncome(
                                double.parse(amountCtrl.text),
                              );
                          context.pop();
                        },
                        child: const Text('Save Income'),
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
}
