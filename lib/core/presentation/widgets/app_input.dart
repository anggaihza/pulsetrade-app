import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    required this.label,
    super.key,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }
}
