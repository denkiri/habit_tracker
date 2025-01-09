import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/routes.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/models/habitDB.dart';
class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://deletech.co.ke/habit_tracker/',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> signUp(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _dio.post(
        'api.php?action=signup',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        print('SignUp successful: ${response.data}');
        return null; // No error
      } else {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          return responseData['message'] as String; // Return the message
        } else {
          return 'Unexpected error format.';
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          return responseData['message'] as String;
        } else {
          return 'SignUp failed: ${e.response?.data}';
        }
      } else {
        return 'Network error: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    } finally {
      _setLoading(false);
    }
  }
  Future<String?> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _dio.post(
        'api.php?action=signin',
        data: {'email': email, 'password': password},
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // Save email in SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', email);
          print('user_email saved in SharedPreferences: $email');
        } catch (prefsError) {
          print('Error saving user_email to SharedPreferences: $prefsError');
          return 'Failed to save user email. Please try again.';
        }

        try {
          final prefs = await SharedPreferences.getInstance();
          String? savedEmail = prefs.getString('user_email');
          print('Retrieved user_email from SharedPreferences: $savedEmail');
          if (savedEmail != email) {
            print('Mismatch in saved email.');
            return 'Failed to verify user email. Please try again.';
          }
        } catch (retrieveError) {
          print('Error retrieving user_email from SharedPreferences: $retrieveError');
          return 'Failed to retrieve user email. Please try again.';
        }

        print('Login successful: ${response.data}');

        await syncDataWithServer();

        return null; // No error
      } else {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          return responseData['message'] as String;
        } else {
          return 'Login failed with status: ${response.statusCode}';
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          return responseData['message'] as String;
        } else {
          return 'Login failed: ${e.response?.data}';
        }
      } else {
        return 'Network error: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');

      // await _googleSignIn.signOut();

      Navigator.of(context).pushReplacementNamed(Routes.login);
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> googleLogin(BuildContext context) async {
    _setLoading(true);
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', account.email);

        print('Google login successful: ${account.email}');

        await syncDataWithServer();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/homepage');
        });

        return null; // No error
      } else {
        return 'Google sign-in was canceled.';
      }
    } on DioError catch (e) {
      print('DioError during Google login: $e');
      return 'Google login failed: ${e.message}';
    } catch (e) {
      print('Error during Google login: $e');
      return 'Google login failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> syncDataWithServer() async {
    _setLoading(true);
    try {

      await HabitDbProvider.db.syncHabits();
      print('Local habits synced successfully with remote server.');
    } catch (e) {
      print('Error syncing data: $e');
    } finally {
      _setLoading(false);
    }
  }
}
