import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../expenses/expense_provider.dart';
import '../income/income_provider.dart';
import 'widgets/bottom_nav_bar.dart';

/// ---------------- MODEL ----------------
class WalletEntry {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;

  WalletEntry({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}

/// ---------------- PAGE ----------------
class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  bool showFabMenu = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBar = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// BASE
          Container(color: Colors.white),

          /// HEADER IMAGE
          SizedBox(
            height: screenHeight * 0.30,
            width: double.infinity,
            child: Image.asset(
              'assets/homeheader.png',
              fit: BoxFit.fill,
            ),
          ),

          /// TITLE
          Positioned(
            top: statusBar + 30,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          /// MAIN CONTENT
          Positioned.fill(
            top: screenHeight * 0.30,
            child: Consumer(
              builder: (context, ref, _) {
                final expensesAsync = ref.watch(expenseListProvider);
                final incomesAsync = ref.watch(incomeListProvider);

                return expensesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                  data: (expenses) {
                    return incomesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(e.toString())),
                      data: (incomes) {
                        final List<WalletEntry> entries = [];

                        /// INCOMES
                        for (final i in incomes) {
                          entries.add(
                            WalletEntry(
                              title: i.title,
                              amount: i.amount,
                              date: i.createdAt ?? DateTime.now(),
                              isIncome: true,
                            ),
                          );
                        }

                        /// EXPENSES
                        for (final e in expenses) {
                          entries.add(
                            WalletEntry(
                              title: e.title,
                              amount: e.amount,
                              date: e.createdAt ?? DateTime.now(),
                              isIncome: false,
                            ),
                          );
                        }

                        /// SORT (latest first)
                        entries.sort((a, b) => b.date.compareTo(a.date));

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            140,
                            16,
                            140,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Income & Expense Listing',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'See all',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (entries.isEmpty)
                                const Center(
                                  child: Text('No transactions yet'),
                                )
                              else
                                ...entries.map(_walletListTile),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          /// WALLET CARD
          Positioned(
            top: screenHeight * 0.18,
            left: 20,
            right: 20,
            child: _walletCard(context, ref),
          ),
          
/// ================= BLUR OVERLAY =================
          if (showFabMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () =>
                    setState(() => showFabMenu = false),
                child: BackdropFilter(
                  filter:
                      ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
              ),
            ),

          /// ================= FAB MENU =================
          if (showFabMenu)
            Positioned(
              bottom: 90,
              right: 0,
              left: 0,
              child: Center(
                child: _fabMenu(context),
              ),
            ),
        ],
      ),

      /// FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F8F83),
        shape: const CircleBorder(),
        onPressed: () {
          setState(() {
            showFabMenu = !showFabMenu;
          });
        },
        child: Icon(showFabMenu ? Icons.close : Icons.add,
         color: Colors.white),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  /// ---------------- WALLET CARD ----------------
  Widget _walletCard(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider).value ?? [];
    final incomes = ref.watch(incomeListProvider).value ?? [];

    final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);

    final totalExpense = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    final remaining = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2F8F83),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet Summary',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Income',
            '₹${totalIncome.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _summaryRow(
            'Expenses',
            '₹${totalExpense.toStringAsFixed(0)}',
            color: Colors.redAccent,
          ),
          const Divider(color: Colors.white30, height: 32),
          _summaryRow(
            'Remaining',
            '₹${remaining.toStringAsFixed(0)}',
            color: Colors.greenAccent,
          ),
        ],
      ),
    );
  }


  Widget _summaryRow(
    String label,
    String value, {
    Color color = Colors.white,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// ================= FAB MENU =================
Widget _fabMenu(BuildContext context) {
  return Material(
    color: Colors.transparent,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _fabMenuItem(
          icon: Icons.remove_circle_outline,
          label: 'Add Expense',
          color: Colors.redAccent,
          onTap: () {
            setState(() => showFabMenu = false);
            context.push('/add-expense');
          },
        ),
        const SizedBox(height: 12),
        _fabMenuItem(
          icon: Icons.add_circle_outline,
          label: 'Add Income',
          color: Colors.green,
          onTap: () {
            setState(() => showFabMenu = false);
            context.push('/add-income');
          },
        ),
      ],
    ),
  );
}

Widget _fabMenuItem({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

}

/// ---------------- LIST TILE ----------------
Widget _walletListTile(WalletEntry entry) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        entry.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _formatDate(entry.date),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        entry.isIncome
            ? '+ ₹${entry.amount.toStringAsFixed(0)}'
            : '- ₹${entry.amount.toStringAsFixed(0)}',
        style: TextStyle(
          color: entry.isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  }
  return '${date.day}/${date.month}/${date.year}';
}