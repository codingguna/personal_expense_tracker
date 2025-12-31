// lib/ui/signup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool obscure = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      await supabase.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        data: {
          'name': nameCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
        },
      );

      if (!mounted) return;

      context.go('/verifyemail');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Icon(
                  Icons.account_balance_wallet,
                  size: 56,
                  color: Color(0xFF2F8F83),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                const Text(
                  'Start managing your finances\neffortlessly',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 32),

                /// NAME
                _input(
                  controller: nameCtrl,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v!.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),

                /// PHONE
                _input(
                  controller: phoneCtrl,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                  validator: (v) =>
                      v!.length < 8 ? 'Invalid phone number' : null,
                ),
                const SizedBox(height: 16),

                /// EMAIL
                _input(
                  controller: emailCtrl,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) =>
                      !v!.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 16),

                /// PASSWORD
                TextFormField(
                  controller: passCtrl,
                  obscureText: obscure,
                  validator: (v) =>
                      v!.length < 6 ? 'Minimum 6 characters' : null,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscure = !obscure),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// SIGNUP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F8F83),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Log In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// -------- INPUT HELPER --------
  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
