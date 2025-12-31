// lib/ui/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    final bool isStatistics =
        location.startsWith('/statistics');

    return BottomAppBar(
      shape: isStatistics
          ? null 
          : const CircularNotchedRectangle(),
      notchMargin: isStatistics ? 0 : 8,
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(
              context,
              icon: Icons.home_outlined,
              route: '/',
              isActive: location == '/',
            ),
            _navIcon(
              context,
              icon: Icons.bar_chart_outlined,
              route: '/statistics',
              isActive: isStatistics,
            ),

            /// 🔹 CENTER GAP (CONDITIONAL)
            SizedBox(width: isStatistics ? 0 : 40),

            _navIcon(
              context,
              icon: Icons.account_balance_wallet_outlined,
              route: '/wallet',
              isActive: location.startsWith('/wallet'),
            ),
            _navIcon(
              context,
              icon: Icons.person_outline,
              route: '/profile',
              isActive: location.startsWith('/profile'),
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
    required bool isActive,
  }) {
    final activeColor = const Color(0xFF2F8F83);

    return InkResponse(
      radius: 28,
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isActive ? activeColor : Colors.grey,
        ),
      ),
    );
  }
}
