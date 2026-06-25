import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../student/student_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../super_admin/super_admin_dashboard.dart';
import '../subscriptions/subscription_screen.dart';

class AppShell extends StatefulWidget {
  final Map<String, dynamic> user;

  const AppShell({super.key, required this.user});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final String role = widget.user['role'] as String;

    final List<Widget> pages = [
      if (role == 'student') const StudentDashboard(),
      if (role == 'teacher') const TeacherDashboard(),
      if (role == 'institution_admin') const AdminDashboard(),
      if (role == 'super_admin') const SuperAdminDashboard(),
      const SubscriptionScreen(),
    ];

    final List<NavigationDestination> destinations = [
      if (role == 'student') const NavigationDestination(icon: Icon(Icons.school), label: 'Student'),
      if (role == 'teacher') const NavigationDestination(icon: Icon(Icons.groups), label: 'Teacher'),
      if (role == 'institution_admin') const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
      if (role == 'super_admin') const NavigationDestination(icon: Icon(Icons.settings), label: 'Super'),
      const NavigationDestination(icon: Icon(Icons.workspace_premium), label: 'Plans'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('MathPro Enterprise — ${widget.user["name"]}'),
        actions: [
          Center(child: Text('${widget.user["role"]}  ')),
          IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: destinations,
        onDestinationSelected: (value) => setState(() => index = value),
      ),
    );
  }
}
