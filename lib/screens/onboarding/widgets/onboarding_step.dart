import 'package:flutter/material.dart';

class OnboardingStep extends StatelessWidget {
  final String text;
  const OnboardingStep({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}
