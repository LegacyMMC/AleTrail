import 'package:flutter/material.dart';

class OnboardWelcome extends StatefulWidget {
  const OnboardWelcome({super.key, required this.title});
  final String title;

  @override
  State<OnboardWelcome> createState() => _OnboardWelcomeState();
}

class _OnboardWelcomeState extends State<OnboardWelcome> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
