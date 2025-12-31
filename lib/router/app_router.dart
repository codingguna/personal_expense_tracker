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
import '../ui/profile_page.dart';
import '../ui/reset_password_page.dart';
import '../ui/splash_screen.dart';
import '../ui/onboarding_screen.dart';


final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);
}

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(authProvider);
  

  return GoRouter(
    
    initialLocation: '/splash',

    redirect: (context, state) {
  final user = Supabase.instance.client.auth.currentUser;

  final publicRoutes = [
    '/splash',
    '/onboarding',
    '/login',
    '/signup',
    '/reset-password',
    '/verify-email',
  ];

  final isPublic = publicRoutes.contains(state.uri.path);

  if (user == null && !isPublic) {
    return '/onboarding';
  }

  if (user != null &&
      (state.uri.path == '/login' ||
       state.uri.path == '/signup' ||
       state.uri.path == '/onboarding')) {
    return '/';
  }

  return null;
},

    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: '/add',
        builder: (_, __) => AddExpensePage(),
      ),
      GoRoute(
        path: '/verifyemail',
        builder: (_, __) => const VerifyEmailPage(),
      ),
      GoRoute(
        path: '/statistics',
        builder: (_, __) => const StatisticsPage(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (_, __) => const WalletPage(),
      ),
      GoRoute(
        path:'/profile',
        builder: (_, __) => const ProfilePage(),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) {
          final expense = state.extra as Expense;
          return EditExpensePage(expense: expense);
        },
      ),
      GoRoute(
        path: '/resetpassword',
        builder: (_, __) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
    ],
  );
});
