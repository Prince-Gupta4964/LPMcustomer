import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final TextEditingController controller;

  const TextInput({
    super.key,
    required this.label,
    required this.hint,
    this.initialValue,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Set initial value if provided and controller is empty
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller, // ✅ Use the passed controller
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            hintText: hint,
          ),
        ),
      ],
    );
  }
}