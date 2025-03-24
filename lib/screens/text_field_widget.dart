import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final TextEditingController? controller;

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.controller, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // Use the controller here
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
      ),
    );
  }
}