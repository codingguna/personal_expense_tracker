// lib/ui/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_provider.dart';
import '../shared/validators.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final user = Supabase.instance.client.auth.currentUser;

    // // 🔹 If user exists but email NOT verified → Verify Email page
    // if (user != null && user.emailConfirmedAt == null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     context.go('/verifyemail');
    //   });
    // }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF6F5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: Color(0xFF2F8F83),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'Sign in to manage your finances\nsecurely and efficiently.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 32),

                    // 🔹 Email
                    TextFormField(
                      controller: emailCtrl,
                      validator: requiredValidator,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Password with visibility toggle
                    TextFormField(
                      controller: passCtrl,
                      validator: requiredValidator,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon:
                            const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🔹 Login Button (interactive + loader)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (!_formKey
                                    .currentState!
                                    .validate()) return;

                                setState(
                                    () => isLoading = true);

                                try {
                                  await ref
                                      .read(
                                          authRepositoryProvider)
                                      .login(
                                        emailCtrl.text
                                            .trim(),
                                        passCtrl.text
                                            .trim(),
                                      );

                                  final user = Supabase
                                      .instance
                                      .client
                                      .auth
                                      .currentUser;

                                  // 🔹 If email not verified
                                  if (user != null && user.emailConfirmedAt == null) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        context.go('/verify-email');
                                      });
                                    }
                                    context.go('/');
                                } on AuthException catch (e) {
                                  // 🔹 Invalid credentials
                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.message
                                                .toLowerCase()
                                                .contains(
                                                    'invalid')
                                            ? 'Invalid email or password'
                                            : e.message,
                                      ),
                                      backgroundColor:
                                          Colors.red,
                                    ),
                                  );
                                } catch (_) {
                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Something went wrong'),
                                      backgroundColor:
                                          Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() =>
                                        isLoading = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLoading
                              ? Colors.grey.shade400
                              : const Color(0xFF2F8F83),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Log In',
                                style:
                                    TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextButton(
                      onPressed: () =>
                          context.go('/signup'),
                      child: const Text(
                        "Don't have an account? Sign Up",
                      ),
                    ),
                    
                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () =>
                          context.push('/resetpassword'),
                      child: const Text(
                        "Forgot password?",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
