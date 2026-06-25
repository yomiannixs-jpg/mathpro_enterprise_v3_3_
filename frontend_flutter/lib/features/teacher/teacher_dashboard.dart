import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../shared/ui.dart';
import '../shared/math_display.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    data = ApiService().getTeacherDashboard();
  }

  void openClass(Map<String, dynamic> classItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassPreviewScreen(
          classId: classItem['id'].toString(),
          className: classItem['name'].toString(),
        ),
      ),
    );
  }

  void openAssignmentPreview(Map<String, dynamic> assignment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentPreviewScreen(
          assignmentId: assignment['id'].toString(),
        ),
      ),
    );
  }

  Future<void> openAssignmentBuilder() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AssignmentBuilderScreen()),
    );
    setState(refresh);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: data,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final classes = List<Map<String, dynamic>>.from(snapshot.data!['classes'] as List);
        final recent = List<String>.from(snapshot.data!['recent_activity'] as List);
        final assignments = List<Map<String, dynamic>>.from(snapshot.data!['assignments'] as List);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Teacher Portal', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            sectionTitle('Classes'),
            ...classes.map((classItem) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.groups),
                  title: Text(classItem['name'].toString()),
                  subtitle: Text(
                    '${classItem["students"]} students • accuracy ${classItem["accuracy"]}% • weak: ${List.from(classItem["weak_topics"] as List).join(", ")}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openClass(classItem),
                ),
              );
            }),
            sectionTitle('Recent Activity'),
            ...recent.map((activity) {
              return Card(child: ListTile(leading: const Icon(Icons.trending_up), title: Text(activity)));
            }),
            sectionTitle('Assignment Bank'),
            ...assignments.map((assignment) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment),
                  title: Text(assignment['title'].toString()),
                  subtitle: Text(
                    '${assignment["class_name"]} • ${assignment["status"]} • ${assignment["field"]} • ${assignment["topic"]} • ${assignment["question_count"]} questions',
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => openAssignmentPreview(assignment),
                    child: const Text('Preview'),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: openAssignmentBuilder,
              icon: const Icon(Icons.assignment_add),
              label: const Text('Create New Assignment'),
            ),
          ],
        );
      },
    );
  }
}

class ClassPreviewScreen extends StatefulWidget {
  final String classId;
  final String className;

  const ClassPreviewScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ClassPreviewScreen> createState() => _ClassPreviewScreenState();
}

class _ClassPreviewScreenState extends State<ClassPreviewScreen> {
  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    data = ApiService().getClassPreview(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: data,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final students = List<Map<String, dynamic>>.from(snapshot.data!['students'] as List);
          final recommendations = List<String>.from(snapshot.data!['recommendations'] as List);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              sectionTitle('Student Performance'),
              ...students.map((student) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(student['name'].toString()),
                    subtitle: Text(
                      'Accuracy ${student["accuracy"]}% • solved ${student["solved"]} • weak: ${student["weak_topic"]}',
                    ),
                    trailing: Text(student['status'].toString()),
                  ),
                );
              }),
              sectionTitle('Teacher Recommendations'),
              ...recommendations.map((recommendation) {
                return Card(child: ListTile(leading: const Icon(Icons.lightbulb), title: Text(recommendation)));
              }),
            ],
          );
        },
      ),
    );
  }
}

class AssignmentPreviewScreen extends StatefulWidget {
  final String assignmentId;

  const AssignmentPreviewScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  State<AssignmentPreviewScreen> createState() => _AssignmentPreviewScreenState();
}

class _AssignmentPreviewScreenState extends State<AssignmentPreviewScreen> {
  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    data = ApiService().getAssignmentPreview(widget.assignmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Preview'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: data,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final assignment = Map<String, dynamic>.from(snapshot.data!['assignment'] as Map);
          final questions = List<Map<String, dynamic>>.from(snapshot.data!['sample_questions'] as List);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                assignment['title'].toString(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${assignment["class_name"]} • ${assignment["field"]} • ${assignment["topic"]} • ${assignment["level"]} • ${assignment["difficulty"]}',
              ),
              sectionTitle('Sample Questions'),
              ...questions.asMap().entries.map((entry) {
                final q = entry.value;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Question ${entry.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(q['question_text'].toString()),
                        const SizedBox(height: 8),
                        MathDisplay(latex: q['question_latex'].toString(), fontSize: 18),
                        const SizedBox(height: 8),
                        Text('Answer: ${q["answer_text"]}'),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class AssignmentBuilderScreen extends StatefulWidget {
  const AssignmentBuilderScreen({super.key});

  @override
  State<AssignmentBuilderScreen> createState() => _AssignmentBuilderScreenState();
}

class _AssignmentBuilderScreenState extends State<AssignmentBuilderScreen> {
  String classId = 'jss2';
  String field = 'Arithmetic';
  String topic = 'Percentages';
  String level = 'Senior Secondary';
  String difficulty = 'medium';
  int questionCount = 20;
  Map<String, dynamic>? saved;

  final TextEditingController titleController =
      TextEditingController(text: 'New Practice Assignment');
  final TextEditingController topicController =
      TextEditingController(text: 'Percentages');

  Future<void> saveAssignment() async {
    final result = await ApiService().createAssignment(
      classId: classId,
      title: titleController.text,
      field: field,
      topic: topicController.text,
      level: level,
      difficulty: difficulty,
      questionCount: questionCount,
    );
    setState(() => saved = result['assignment'] as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    final assignmentText = saved == null
        ? ''
        : 'Saved to Assignment Bank\n'
          'Title: ${saved!["title"]}\n'
          'Class: ${saved!["class_name"]}\n'
          'Field: ${saved!["field"]}\n'
          'Topic: ${saved!["topic"]}\n'
          'Level: ${saved!["level"]}\n'
          'Difficulty: ${saved!["difficulty"]}\n'
          'Questions: ${saved!["question_count"]}\n'
          'Estimated minutes: ${saved!["estimated_minutes"]}';

    return Scaffold(
      appBar: AppBar(title: const Text('Create Assignment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Assignment title'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: classId,
            decoration: const InputDecoration(labelText: 'Class'),
            items: const [
              DropdownMenuItem(value: 'jss2', child: Text('JSS 2 Mathematics')),
              DropdownMenuItem(value: 'ss2', child: Text('SS 2 Further Maths')),
              DropdownMenuItem(value: 'uni1', child: Text('University Year 1')),
              DropdownMenuItem(value: 'grad', child: Text('Graduate Mathematics')),
              DropdownMenuItem(value: 'olympiad', child: Text('Olympiad Training Group')),
            ],
            onChanged: (value) => setState(() => classId = value ?? 'jss2'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: field,
            decoration: const InputDecoration(labelText: 'Field'),
            items: const [
              DropdownMenuItem(value: 'Primary Mathematics', child: Text('Primary Mathematics')),
              DropdownMenuItem(value: 'Arithmetic', child: Text('Arithmetic')),
              DropdownMenuItem(value: 'Algebra', child: Text('Algebra')),
              DropdownMenuItem(value: 'Financial Mathematics', child: Text('Financial Mathematics')),
              DropdownMenuItem(value: 'Linear Algebra', child: Text('Linear Algebra')),
              DropdownMenuItem(value: 'Trigonometry', child: Text('Trigonometry')),
              DropdownMenuItem(value: 'Geometry', child: Text('Geometry')),
              DropdownMenuItem(value: 'Calculus', child: Text('Calculus')),
              DropdownMenuItem(value: 'Differential Equations', child: Text('Differential Equations')),
              DropdownMenuItem(value: 'PDE', child: Text('PDE')),
              DropdownMenuItem(value: 'Integral Equations', child: Text('Integral Equations')),
              DropdownMenuItem(value: 'Probability and Statistics', child: Text('Probability and Statistics')),
              DropdownMenuItem(value: 'Operations Research', child: Text('Operations Research')),
              DropdownMenuItem(value: 'Graduate Mathematics', child: Text('Graduate Mathematics')),
              DropdownMenuItem(value: 'Olympiad Mathematics', child: Text('Olympiad Mathematics')),
            ],
            onChanged: (value) => setState(() => field = value ?? 'Arithmetic'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: topicController,
            decoration: const InputDecoration(labelText: 'Topic'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: level,
            decoration: const InputDecoration(labelText: 'Level'),
            items: const [
              DropdownMenuItem(value: 'Primary', child: Text('Primary')),
              DropdownMenuItem(value: 'Junior Secondary', child: Text('Junior Secondary')),
              DropdownMenuItem(value: 'Senior Secondary', child: Text('Senior Secondary')),
              DropdownMenuItem(value: 'Undergraduate', child: Text('Undergraduate')),
              DropdownMenuItem(value: 'Graduate', child: Text('Graduate')),
              DropdownMenuItem(value: 'Exam Prep', child: Text('Exam Prep')),
              DropdownMenuItem(value: 'Olympiad', child: Text('Olympiad')),
            ],
            onChanged: (value) => setState(() => level = value ?? 'Senior Secondary'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: difficulty,
            decoration: const InputDecoration(labelText: 'Difficulty'),
            items: const [
              DropdownMenuItem(value: 'easy', child: Text('Easy')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'hard', child: Text('Hard')),
              DropdownMenuItem(value: 'expert', child: Text('Expert')),
              DropdownMenuItem(value: 'olympiad', child: Text('Olympiad')),
            ],
            onChanged: (value) => setState(() => difficulty = value ?? 'medium'),
          ),
          const SizedBox(height: 12),
          Text('Question count: $questionCount'),
          Slider(
            value: questionCount.toDouble(),
            min: 5,
            max: 50,
            divisions: 9,
            label: questionCount.toString(),
            onChanged: (value) => setState(() => questionCount = value.round()),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: saveAssignment,
            icon: const Icon(Icons.save),
            label: const Text('Save to Assignment Bank'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: saved == null ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Return to Assignment Bank'),
          ),
          if (saved != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(assignmentText),
              ),
            ),
        ],
      ),
    );
  }
}
