import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/routes.dart';
import 'package:habit_tracker/models/auth_view_model.dart';
import 'package:habit_tracker/providers/theme_provider.dart';
import 'package:habit_tracker/pages/auth/widgets/reusable_text_field.dart';
import 'package:habit_tracker/pages/auth/widgets/reusable_password_field.dart';
import 'package:habit_tracker/pages/auth/widgets/reusable_button.dart';
import 'package:habit_tracker/pages/components/theme_toggle_row.dart';
class SignupPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        actions: [
          Row(
            children: [
            ThemeToggleRow(),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Create Account 📝',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign up to get started.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 40),
                      buildTextField(
                        'Email address *',
                        emailController,
                        'Enter email *',
                        colorScheme,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      buildPasswordField(
                        'Password *',
                        passwordController,
                        colorScheme,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      buildButton(
                        'Sign Up',
                        authViewModel.isLoading
                            ? null
                            : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final errorMessage = await authViewModel.signUp(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                            if (errorMessage == null) {
                              Navigator.of(context).pushReplacementNamed(Routes.login);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                        colorScheme,
                        isLoading: authViewModel.isLoading,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () =>  Navigator.of(context).pushReplacementNamed(Routes.login),
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
