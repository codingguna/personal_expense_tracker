import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'widgets/bottom_nav_bar.dart';

/// ================= PROFILE PROVIDER =================

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser!;
  final res = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('user_id', user.id)
      .single();
  return res;
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool obscurePassword = true;

  bool loadingName = false;
  bool loadingPhone = false;
  bool loadingEmail = false;
  bool loadingPassword = false;
  bool loadingLogout = false;

  SupabaseClient get _client => Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser!;
    final email = user.email ?? '';

    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) {
          final name = profile['full_name'] ?? 'User';
          final phone = profile['phone'] ?? 'Not set';

          return SingleChildScrollView(
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
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                /// NAME
                _infoTile(
                  label: 'Name',
                  value: name,
                  loading: loadingName,
                  onEdit: () => _editName(context, name),
                ),

                const SizedBox(height: 16),

                /// PHONE
                _infoTile(
                  label: 'Phone Number',
                  value: phone,
                  loading: loadingPhone,
                  onEdit: () => _editPhone(context, phone),
                ),

                const SizedBox(height: 16),

                /// EMAIL
                _infoTile(
                  label: 'Email',
                  value: email,
                  loading: loadingEmail,
                  onEdit: () => _changeEmail(context, email),
                ),

                const SizedBox(height: 16),

                /// PASSWORD
                _infoTile(
                  label: 'Password',
                  value: '••••••••',
                  loading: loadingPassword,
                  onEdit: () => _changePassword(context),
                ),

                const SizedBox(height: 32),

                /// LOGOUT
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 121, 233, 224),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: loadingLogout
                      ? null
                      : () async {
                          setState(() => loadingLogout = true);
                          await _client.auth.signOut();
                          if (!mounted) return;
                          context.go('/onboarding');
                        },
                  icon: loadingLogout
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // ================= NAME (profiles table) =================

  void _editName(BuildContext context, String currentName) {
    final ctrl = TextEditingController(text: currentName);

    _showDialog(
      context,
      title: 'Update Name',
      controller: ctrl,
      loading: loadingName,
      onSave: () async {
        setState(() => loadingName = true);
        await _updateProfile(fullName: ctrl.text);
        setState(() => loadingName = false);
        Navigator.pop(context);
        ref.invalidate(profileProvider);
      },
    );
  }

  // ================= PHONE (profiles table) =================

  void _editPhone(BuildContext context, String currentPhone) {
    final ctrl = TextEditingController(
      text: currentPhone == 'Not set' ? '' : currentPhone,
    );

    _showDialog(
      context,
      title: 'Update Phone',
      controller: ctrl,
      keyboard: TextInputType.phone,
      loading: loadingPhone,
      onSave: () async {
        setState(() => loadingPhone = true);
        await _updateProfile(phone: ctrl.text);
        setState(() => loadingPhone = false);
        Navigator.pop(context);
        ref.invalidate(profileProvider);
      },
    );
  }

  Future<void> _updateProfile({
    String? fullName,
    String? phone,
  }) async {
    final user = _client.auth.currentUser!;
    await _client.from('profiles').update({
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
    }).eq('user_id', user.id);
  }

  // ================= EMAIL (auth) =================

  void _changeEmail(BuildContext context, String currentEmail) {
    final ctrl = TextEditingController(text: currentEmail);

    _showDialog(
      context,
      title: 'Change Email',
      controller: ctrl,
      loading: loadingEmail,
      onSave: () async {
        setState(() => loadingEmail = true);
        await _client.auth
            .updateUser(UserAttributes(email: ctrl.text));
        setState(() => loadingEmail = false);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Verification email sent. Please confirm.'),
          ),
        );
      },
    );
  }

  // ================= PASSWORD (auth) =================

  void _changePassword(BuildContext context) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Password'),
        content: TextField(
          controller: ctrl,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            labelText: 'New Password',
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => obscurePassword = !obscurePassword),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: loadingPassword
                ? null
                : () async {
                    setState(() => loadingPassword = true);
                    await _client.auth.updateUser(
                      UserAttributes(password: ctrl.text),
                    );
                    setState(() => loadingPassword = false);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated'),
                      ),
                    );
                  },
            child: loadingPassword
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ================= COMMON DIALOG =================

  void _showDialog(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    required bool loading,
    required VoidCallback onSave,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboard,
        ),
        actions: [
          TextButton(
            onPressed: loading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: loading ? null : onSave,
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ================= TILE =================

  Widget _infoTile({
    required String label,
    required String value,
    required bool loading,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
        ],
      ),
    );
  }
}
