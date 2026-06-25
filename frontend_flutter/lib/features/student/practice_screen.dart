import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../shared/math_display.dart';

class PracticeScreen extends StatefulWidget {
  final String field;
  final String topic;

  const PracticeScreen({
    super.key,
    required this.field,
    required this.topic,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String level = 'Senior Secondary';
  String difficulty = 'medium';
  int seed = 1;
  Map<String, dynamic>? question;
  bool showHint = false;
  bool showSolution = false;

  @override
  void initState() {
    super.initState();
    loadQuestion();
  }

  Future<void> loadQuestion() async {
    final result = await ApiService().generateQuestion(
      level: level,
      field: widget.field,
      topic: widget.topic,
      difficulty: difficulty,
      seed: seed,
    );
    setState(() {
      question = result;
      showHint = false;
      showSolution = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = question;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.field} — ${widget.topic}')),
      body: q == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 12,
                  children: [
                    DropdownButton<String>(
                      value: level,
                      items: [
                        'Primary',
                        'Junior Secondary',
                        'Senior Secondary',
                        'Undergraduate',
                        'Graduate',
                        'Exam Prep',
                        'Olympiad',
                      ].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => level = value);
                        loadQuestion();
                      },
                    ),
                    DropdownButton<String>(
                      value: difficulty,
                      items: ['easy', 'medium', 'hard', 'expert', 'olympiad']
                          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => difficulty = value);
                        loadQuestion();
                      },
                    ),
                  ],
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${q["level"]} • ${q["difficulty"]} • Bank ${q["bank_size"]}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          q['question_text'].toString(),
                          style: const TextStyle(fontSize: 18, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        MathDisplay(latex: q['question_latex'].toString()),
                      ],
                    ),
                  ),
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => setState(() => showHint = true),
                      icon: const Icon(Icons.lightbulb),
                      label: const Text('Hint'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => showSolution = true),
                      icon: const Icon(Icons.menu_book),
                      label: const Text('Solution'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark),
                      label: const Text('Bookmark'),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        seed++;
                        loadQuestion();
                      },
                      icon: const Icon(Icons.navigate_next),
                      label: const Text('Next'),
                    ),
                  ],
                ),
                if (showHint)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        q['hint_text'].toString(),
                        style: const TextStyle(fontSize: 17, height: 1.4),
                      ),
                    ),
                  ),
                if (showSolution)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detailed Solution',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ...List<String>.from(q['solution_steps'] as List).asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Text(
                                'Step ${entry.key + 1}: ${entry.value}',
                                style: const TextStyle(fontSize: 17, height: 1.45),
                              ),
                            );
                          }),
                          const Divider(),
                          Text(
                            'Answer: ${q["answer_text"]}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
