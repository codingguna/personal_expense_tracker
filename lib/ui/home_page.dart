// lib/ui/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../expenses/expense_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/bottom_nav_bar.dart';
import '../income/income_provider.dart';

/// ---------- MODEL ----------
class HomeEntry {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;

  HomeEntry({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.30;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          /// 1️⃣ BASE WHITE
          Container(color: Colors.white),

          /// 2️⃣ HEADER IMAGE
          SizedBox(
            height: headerHeight,
            width: double.infinity,
            child: Image.asset(
              'assets/homeheader.png',
              fit: BoxFit.fill,
            ),
          ),

          /// 3️⃣ GREETING + NOTIFICATION
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No notifications yet'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 4️⃣ BALANCE CARD
          Positioned(
            top: headerHeight - 100,
            left: 20,
            right: 20,
            child: const BalanceCard(),
          ),

          /// 5️⃣ MAIN CONTENT (UPDATED)
/// 5️⃣ MAIN CONTENT (UPDATED – REAL DATA)
Positioned(
  top: headerHeight + 80,
  left: 0,
  right: 0,
  bottom: 0,
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
              /// 🔹 Unified list
              final List<HomeEntry> entries = [];

              // ✅ Income entries
              for (final i in incomes) {
                entries.add(
                  HomeEntry(
                    title: 'Income',
                    amount: i.amount,
                    date: i.createdAt ?? DateTime.now(),
                    isIncome: true,
                  ),
                );
              }

              // ✅ Expense entries
              for (final e in expenses) {
                entries.add(
                  HomeEntry(
                    title: e.title,
                    amount: e.amount,
                    date: e.createdAt ?? DateTime.now(), // USE createdAt
                    isIncome: false,
                  ),
                );
              }

              // Sort latest first
              entries.sort((a, b) => b.date.compareTo(a.date));

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                children: [
                  /// TITLE ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    ...entries.map(_homeListTile),
                ],
              );
            },
          );
        },
      );
    },
  ),
),
        ],
      ),

      /// ✅ FAB
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F8F83),
        onPressed: () => context.push('/add'),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      /// ✅ Bottom Nav
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

/// ---------- LIST TILE ----------
Widget _homeListTile(HomeEntry entry) {
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
  if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day) {
    return 'Today';
  }
  return '${date.day}/${date.month}/${date.year}';
}
