import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../shell/app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController(text: 'Demo User');
  String role = 'student';
  bool loading = false;

  final Map<String, String> roles = const {
    'student': 'Student',
    'teacher': 'Teacher',
    'institution_admin': 'Institution Admin',
    'super_admin': 'Super Admin',
  };

  Future<void> signIn() async {
    setState(() => loading = true);
    final result = await ApiService().login(nameController.text, role);
    if (!mounted) return;
    setState(() => loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AppShell(user: result['user'] as Map<String, dynamic>),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 540),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MathPro Enterprise v3.0',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Unified enterprise demo with Olympiad math, teacher tools, and role dashboards.'),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: roles.entries.map((entry) {
                    return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                  }).toList(),
                  onChanged: (value) => setState(() => role = value ?? 'student'),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: loading ? null : signIn,
                  icon: const Icon(Icons.login),
                  label: Text(loading ? 'Signing in...' : 'Enter MathPro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
