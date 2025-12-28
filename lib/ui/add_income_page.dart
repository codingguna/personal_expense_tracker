// lib/ui/add_income_page.dart
import 'package:flutter/material.dart';
import 'widgets/gradient_header.dart';

class AddIncomePage extends StatelessWidget {
  const AddIncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: const [
          GradientHeader(title: 'Add Income'),
          Positioned.fill(
            top: 160,
            child: Center(
              child: Text(
                'Income UI matches Expense UI\n(backend optional)',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
