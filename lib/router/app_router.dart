// lib/router/app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../expenses/expense_model.dart';
import '../ui/add_expense_page.dart';
import '../ui/edit_expense_page.dart';
import '../ui/home_page.dart';
import '../ui/login_page.dart';
import '../ui/signup_page.dart';
import '../ui/verify_email_page.dart';
import '../ui/statistics_page.dart';
import '../ui/wallet_page.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);
}

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(authProvider); // keeps router reactive

  return GoRouter(
    redirect: (context, state) {
      final loggedIn =
          Supabase.instance.client.auth.currentUser != null;
      final loggingIn =
          state.uri.path == '/login' ||
          state.uri.path == '/signup';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => SignupPage(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => HomePage(),
      ),
      GoRoute(
        path: '/add',
        builder: (_, __) => const AddExpensePage(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => VerifyEmailPage(),
      ),
      GoRoute(
        path: '/statistics',
        builder: (_, __) => StatisticsPage(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (_, __) => const WalletPage(),
      ),
      GoRoute(
        path:'/profile',
        builder: (_, __) => const WalletPage(),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) {
          final expense = state.extra as Expense;
          return EditExpensePage(expense: expense);
        },
      ),
    ],
  );
});
