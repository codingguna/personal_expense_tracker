// lib/ui/widgets/balance_card.dart
import 'package:flutter/material.dart';
import 'balance_chip.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
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
        children: const [
          Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 8),
          Text(
            '₹2,548.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BalanceChip(
                icon: Icons.arrow_downward,
                label: 'Income',
                amount: '₹1,840',
              ),
              BalanceChip(
                icon: Icons.arrow_upward,
                label: 'Expenses',
                amount: '₹284',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
