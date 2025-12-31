// lib/ui/home_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../expenses/expense_provider.dart';
import '../income/income_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/bottom_nav_bar.dart';

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

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool showFabMenu = false;
  final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser!;
  final res = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('user_id', user.id)
      .single();
  return res;
});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.30;
    final profileAsync = ref.watch(profileProvider);
    final userName = profileAsync.when(
      data: (data) => data['full_name'] ?? 'User',
      loading: () => 'User',
      error: (_, __) => 'User',
    );

    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          /// ================= MAIN CONTENT =================
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(color: Colors.white),

              /// HEADER IMAGE
              SizedBox(
                height: headerHeight,
                width: double.infinity,
                child: Image.asset(
                  'assets/homeheader.png',
                  fit: BoxFit.fill,
                ),
              ),

              /// GREETING
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              userName,
                              style: const TextStyle(
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
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// BALANCE CARD
              Positioned(
                top: headerHeight - 100,
                left: 20,
                right: 20,
                child: const BalanceCard(),
              ),

              /// LIST CONTENT
              Positioned(
                top: headerHeight + 80,
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildTransactionList(),
              ),
            ],
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
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F8F83),
        shape: CircleBorder(),
        onPressed: () {
          setState(() {
            showFabMenu = !showFabMenu;
          });
        },
        child: Icon(
          showFabMenu ? Icons.close : Icons.add,
          color: Colors.white,
        ),
      ),

      bottomNavigationBar: const BottomNavBar(),
    );
  }

  /// ================= TRANSACTION LIST =================
  Widget _buildTransactionList() {
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
            final List<HomeEntry> entries = [];

            for (final i in incomes) {
              entries.add(
                HomeEntry(
                  title: i.title,
                  amount: i.amount,
                  date: i.createdAt ?? DateTime.now(),
                  isIncome: true,
                ),
              );
            }

            for (final e in expenses) {
              entries.add(
                HomeEntry(
                  title: e.title,
                  amount: e.amount,
                  date: e.expenseDate,
                  isIncome: false,
                ),
              );
            }

            entries.sort(
              (a, b) => b.date.compareTo(a.date),
            );

            return ListView(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 120),
              children: [
                const Text(
                  'Income & Expense Listing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

/// ---------- LIST TILE ----------
Widget _homeListTile(HomeEntry entry) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      title: Text(entry.title),
      subtitle: Text(
        '${entry.date.day}/${entry.date.month}/${entry.date.year}',
      ),
      trailing: Text(
        entry.isIncome
            ? '+ ₹${entry.amount.toStringAsFixed(0)}'
            : '- ₹${entry.amount.toStringAsFixed(0)}',
        style: TextStyle(
          color: entry.isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
