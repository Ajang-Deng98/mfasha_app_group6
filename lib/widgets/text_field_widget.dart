import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final TextEditingController? controller; // Added controller parameter

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.controller, // Accept controller
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller, // Assign controller here
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
        ),
      ],
    );
  }
}