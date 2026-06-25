import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String name, String role) {
    return post('/auth/login', {'name': name, 'role': role});
  }

  Future<Map<String, dynamic>> getCatalog() => get('/catalog');
  Future<Map<String, dynamic>> getStudentDashboard() => get('/student/dashboard');
  Future<Map<String, dynamic>> getTeacherDashboard() => get('/teacher/dashboard');
  Future<Map<String, dynamic>> getClassPreview(String classId) => get('/teacher/class/$classId');
  Future<Map<String, dynamic>> getAssignmentPreview(String assignmentId) => get('/teacher/assignments/$assignmentId');
  Future<Map<String, dynamic>> getAdminDashboard() => get('/admin/dashboard');
  Future<Map<String, dynamic>> getSuperAdminDashboard() => get('/super-admin/dashboard');
  Future<Map<String, dynamic>> getTaskDetail(String taskId) => get('/super-admin/tasks/$taskId');
  Future<Map<String, dynamic>> getPlans() => get('/subscriptions/plans');

  Future<Map<String, dynamic>> createAssignment({
    required String classId,
    required String title,
    required String field,
    required String topic,
    required String level,
    required String difficulty,
    required int questionCount,
  }) {
    return post('/teacher/assignments/create', {
      'class_id': classId,
      'title': title,
      'field': field,
      'topic': topic,
      'level': level,
      'difficulty': difficulty,
      'question_count': questionCount,
    });
  }

  Future<Map<String, dynamic>> generateQuestion({
    required String level,
    required String field,
    required String topic,
    required String difficulty,
    required int seed,
  }) {
    return post('/question/generate', {
      'level': level,
      'field': field,
      'topic': topic,
      'difficulty': difficulty,
      'seed': seed,
    });
  }

  Future<Map<String, dynamic>> tutorExplain(String question, String ask) {
    return post('/tutor/explain', {'question': question, 'ask': ask});
  }
}
