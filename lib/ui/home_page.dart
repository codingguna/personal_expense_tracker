// lib/ui/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../expenses/expense_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/bottom_nav_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🔹 Gradient Header
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2F8F83), Color(0xFF3AAFA9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.only(
              top: 60,
              left: 24,
              right: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Good afternoon,\nUser',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.notifications_none,
                    color: Colors.white),
              ],
            ),
          ),

          // 🔹 Content
          Positioned.fill(
            top: 180,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  // 🔹 Expense List
                  Expanded(
                    child: expenses.when(
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Center(child: Text(e.toString())),
                      data: (list) {
                        if (list.isEmpty) {
                          return const Center(
                            child: Text('No expenses yet'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          itemCount: list.length,
                          itemBuilder: (_, i) {
                            final e = list[i];
                            return ListTile(
                              title: Text(e.title),
                              subtitle: Text(e.category),
                              trailing: Text(
                                '₹${e.amount}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () =>
                                  context.go('/edit', extra: e),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Floating Balance Card
          const Positioned(
            top: 140,
            left: 24,
            right: 24,
            child: BalanceCard(),
          ),
        ],
      ),

      // 🔹 Floating Add Button (centered)
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F8F83),
        onPressed: () => context.go('/add'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
