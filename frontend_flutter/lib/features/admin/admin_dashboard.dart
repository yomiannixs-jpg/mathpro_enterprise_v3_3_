import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../shared/ui.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    data = ApiService().getAdminDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: data,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final d = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Institution Admin Dashboard', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                statCard('Institutions', d['institutions']),
                statCard('Teachers', d['teachers']),
                statCard('Students', d['students']),
                statCard('Subscriptions', d['active_subscriptions']),
                statCard('Revenue', '\$${d["monthly_revenue_usd"]}'),
              ],
            ),
            sectionTitle('Alerts'),
            ...List<String>.from(d['alerts'] as List).map((alert) {
              return Card(child: ListTile(leading: const Icon(Icons.warning_amber), title: Text(alert)));
            }),
          ],
        );
      },
    );
  }
}
