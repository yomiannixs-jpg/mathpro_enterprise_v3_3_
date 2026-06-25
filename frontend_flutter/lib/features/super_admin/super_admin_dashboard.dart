import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../shared/ui.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    data = ApiService().getSuperAdminDashboard();
  }

  void openTask(Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SystemTaskReviewScreen(taskId: task['id'].toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: data,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final d = snapshot.data!;
        final tasks = List<Map<String, dynamic>>.from(d['tasks'] as List);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Super Admin Console',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                statCard('System', d['system_status']),
                statCard('Users', d['total_users']),
                statCard('Templates', d['question_templates']),
                statCard('Open Reports', d['open_reports']),
              ],
            ),
            sectionTitle('System Tasks'),
            ...tasks.map((task) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.task),
                  title: Text(task['title'].toString()),
                  subtitle: Text('Status: ${task["status"]}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openTask(task),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class SystemTaskReviewScreen extends StatefulWidget {
  final String taskId;

  const SystemTaskReviewScreen({super.key, required this.taskId});

  @override
  State<SystemTaskReviewScreen> createState() => _SystemTaskReviewScreenState();
}

class _SystemTaskReviewScreenState extends State<SystemTaskReviewScreen> {
  late Future<Map<String, dynamic>> task;

  @override
  void initState() {
    super.initState();
    task = ApiService().getTaskDetail(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review System Task'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: task,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final t = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                t['title'].toString(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: Text('Status: ${t["status"]}'),
                ),
              ),
              sectionTitle('Details'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(t['details'].toString(), style: const TextStyle(height: 1.45)),
                ),
              ),
              sectionTitle('Recommendation'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(t['recommendation'].toString(), style: const TextStyle(height: 1.45)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
