import 'package:flutter/material.dart';

Widget buildButton(
    String label,
    VoidCallback? onPressed,
    ColorScheme colorScheme, {
      bool isLoading = false,
    }) {
  return ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4,
      minimumSize: const Size.fromHeight(48),
    ),
    child: isLoading
        ? CircularProgressIndicator(color: colorScheme.onPrimary)
        : Text(
      label,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
