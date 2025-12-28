// lib/ui/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(
              context,
              icon: Icons.home_outlined,
              route: '/',
            ),
            _navIcon(
              context,
              icon: Icons.bar_chart_outlined,
              route: '/statistics',
            ),
            const SizedBox(width: 40), // space for FAB
            _navIcon(
              context,
              icon: Icons.account_balance_wallet_outlined,
              route: '/wallet',
            ),
            _navIcon(
              context,
              icon: Icons.person_outline,
              route: '/profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(
    BuildContext context, {
    required IconData icon,
    required String route,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.grey),
      onPressed: () => context.go(route),
    );
  }
}
