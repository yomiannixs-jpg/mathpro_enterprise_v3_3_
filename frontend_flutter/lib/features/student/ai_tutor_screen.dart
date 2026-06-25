import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController questionController =
      TextEditingController(text: 'solve 2x+3y=9');
  List<dynamic> reply = [];
  bool loading = false;

  Future<void> askTutor() async {
    setState(() {
      loading = true;
      reply = [];
    });
    final result = await ApiService().tutorExplain(
      questionController.text,
      'Solve fully with detailed steps',
    );
    setState(() {
      reply = result['reply'] as List;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: questionController,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Ask MathPro AI Tutor',
              helperText: 'Example: solve 2x+3y=9',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: loading ? null : askTutor,
            child: Text(loading ? 'Solving...' : 'Solve with AI Tutor'),
          ),
          const SizedBox(height: 12),
          ...reply.asMap().entries.map((entry) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${entry.key + 1}')),
                title: Text(entry.value.toString()),
              ),
            );
          }),
        ],
      ),
    );
  }
}
