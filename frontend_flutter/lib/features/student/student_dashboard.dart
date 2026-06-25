import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../shared/ui.dart';
import 'practice_screen.dart';
import 'ai_tutor_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late Future<Map<String, dynamic>> dashboard;
  late Future<Map<String, dynamic>> catalog;

  @override
  void initState() {
    super.initState();
    dashboard = ApiService().getStudentDashboard();
    catalog = ApiService().getCatalog();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([dashboard, catalog]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final d = snapshot.data![0];
        final c = snapshot.data![1];
        final fields = Map<String, dynamic>.from(c['fields'] as Map);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Student Dashboard',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                statCard('Solved', d['solved']),
                statCard('Accuracy', '${d["accuracy"]}%'),
                statCard('Streak', d['streak']),
                statCard('Bookmarks', d['bookmarks']),
              ],
            ),
            sectionTitle('Recommended Study'),
            ...List<String>.from(d['recommended'] as List).map((topic) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: Text(topic),
                ),
              );
            }),
            sectionTitle('Practice Topics'),
            ...fields.entries.map((entry) {
              return Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: List<String>.from(entry.value as List).map((topic) {
                    return ListTile(
                      title: Text(topic),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PracticeScreen(field: entry.key, topic: topic),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
            sectionTitle('AI Tutor'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.smart_toy),
                title: const Text('Ask MathPro AI Tutor'),
                subtitle: const Text('Slow explanations, examples, and step-by-step help.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiTutorScreen())),
              ),
            ),
          ],
        );
      },
    );
  }
}
