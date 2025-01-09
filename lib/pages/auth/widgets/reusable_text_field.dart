import 'package:flutter/material.dart';

Widget buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    ColorScheme colorScheme, {
      FormFieldValidator<String>? validator,
    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
          filled: true,
          fillColor: colorScheme.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
        ),
      ),
    ],
  );
}
