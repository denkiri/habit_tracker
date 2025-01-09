import 'package:flutter/material.dart';
import 'package:habit_tracker/pages/detail/index.dart';
import 'package:habit_tracker/pages/get_started/index.dart';
import 'package:habit_tracker/pages/home/index.dart';
import 'package:habit_tracker/pages/auth/login_page.dart';
import 'package:habit_tracker/pages/auth/signup_page.dart';

class Routes {
  Routes._();
  static const String getStarted = '/getStarted';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String homepage = '/homepage';

  static final Map<String, WidgetBuilder> routes = {
    getStarted: (BuildContext context) => GetStarted(),
    home: (BuildContext context) => Home(),
    detail: (BuildContext context) => Detail(),
    login: (BuildContext context) => LoginPage(),
    signup: (BuildContext context) => SignupPage(),
    homepage: (BuildContext context) => Home(),
  };
}
