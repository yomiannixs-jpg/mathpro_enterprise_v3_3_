import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const MathProEnterpriseApp());
}

class MathProEnterpriseApp extends StatelessWidget {
  const MathProEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathPro Enterprise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B12),
        cardColor: const Color(0xFF171824),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E8CFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
