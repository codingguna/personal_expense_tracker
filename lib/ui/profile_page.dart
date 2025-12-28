//lib/ui/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'widgets/income_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser!;
    final income = ref.watch(incomeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF2F8F83),
              child: Icon(Icons.person,
                  size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),

            Text(
              user.email ?? '',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 32),

            _infoTile(
              label: 'Monthly Income',
              value: '₹${income.toStringAsFixed(0)}',
              onEdit: () => _editIncome(context, ref, income),
            ),

            const SizedBox(height: 16),

            _infoTile(
              label: 'Password',
              value: '••••••••',
              onEdit: () =>
                  _changePassword(context),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                Navigator.of(context)
                    .pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  // -------- EDIT INCOME --------

  void _editIncome(
    BuildContext context,
    WidgetRef ref,
    double currentIncome,
  ) {
    final ctrl =
        TextEditingController(text: currentIncome.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Income'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(incomeProvider.notifier)
                  .updateIncome(double.parse(ctrl.text));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // -------- PASSWORD UPDATE --------

  void _changePassword(BuildContext context) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Password'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await Supabase.instance.client.auth
                  .updateUser(
                UserAttributes(password: ctrl.text),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text('Password updated'),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // -------- UI TILE --------

  Widget _infoTile({
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
