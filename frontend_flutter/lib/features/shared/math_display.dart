import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathDisplay extends StatelessWidget {
  final String latex;
  final double fontSize;

  const MathDisplay({
    super.key,
    required this.latex,
    this.fontSize = 20,
  });

  String cleanLatex(String input) {
    return input
        .replaceAll('\\(', '')
        .replaceAll('\\)', '')
        .replaceAll('\\[', '')
        .replaceAll('\\]', '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final expression = cleanLatex(latex);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Math.tex(
        expression,
        textStyle: TextStyle(fontSize: fontSize),
        onErrorFallback: (FlutterMathException error) {
          return Text(
            expression,
            style: TextStyle(fontSize: fontSize),
          );
        },
      ),
    );
  }
}
