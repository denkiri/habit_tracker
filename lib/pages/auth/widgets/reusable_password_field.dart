import 'package:flutter/material.dart';

Widget buildPasswordField(
    String label,
    TextEditingController controller,
    ColorScheme colorScheme, {
      FormFieldValidator<String>? validator,
    }) {
  final obscureTextNotifier = ValueNotifier<bool>(true);

  return ValueListenableBuilder<bool>(
    valueListenable: obscureTextNotifier,
    builder: (context, obscureText, _) {
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
            obscureText: obscureText,
            validator: validator,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter password *',
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              filled: true,
              fillColor: colorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  obscureTextNotifier.value = !obscureTextNotifier.value;
                },
              ),
            ),
          ),
        ],
      );
    },
  );
}
