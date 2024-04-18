import 'package:flutter/material.dart';

class OnboardInstruct extends StatefulWidget {
  const OnboardInstruct({super.key, required this.title});
  final String title;

  @override
  State<OnboardInstruct> createState() => _OnboardInstructState();
}

class _OnboardInstructState extends State<OnboardInstruct> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
