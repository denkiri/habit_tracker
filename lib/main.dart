import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/models/habit_reminder.dart';
import 'package:habit_tracker/models/habit_detail.dart';
import 'package:habit_tracker/models/option.dart';
import 'package:habit_tracker/models/time_of_day_adapter.dart';
import 'package:habit_tracker/models/habitDB.dart';
import 'package:habit_tracker/providers/theme_provider.dart';
import 'package:habit_tracker/models/auth_view_model.dart';
import 'package:habit_tracker/pages/auth/login_page.dart';
import 'package:habit_tracker/pages/auth/signup_page.dart';
import 'package:habit_tracker/pages/get_started/index.dart';
import 'package:habit_tracker/pages/detail/index.dart';
import 'package:habit_tracker/pages/home/index.dart';
import 'package:habit_tracker/routes.dart';
import 'package:habit_tracker/theme.dart';
import 'package:habit_tracker/models/habit.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HiveTimeOfDayAdapter());
  Hive.registerAdapter(HabitReminderAdapter());
  Hive.registerAdapter(HabitDetailAdapter());
  Hive.registerAdapter(OptionAdapter());
  await Hive.openBox<Habit>('Habit');
  await Hive.openBox<HabitReminder>('HabitReminder');
  await Hive.openBox<HabitDetail>('HabitDetail');
  await Hive.openBox<Option>('Option');

  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider<HabitModel>(
          create: (_) => habitAdapter,
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: HabitApp(),
    );
  }
}

class HabitApp extends StatefulWidget {
  @override
  HabitAppState createState() => HabitAppState();
}

class HabitAppState extends State<HabitApp> {
  Widget? _initialPage;

  @override
  void initState() {
    super.initState();
    _determineInitialPage();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _setSystemUIOverlay(themeProvider.isDarkMode);

    return MaterialApp(
      title: 'HABIT TRACKER',
      debugShowCheckedModeBanner: false,
      theme: MaterialTheme.light(),
      darkTheme: MaterialTheme.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/homepage': (context) => Home(),
        '/detail': (context) => Detail(),
        '/getStarted': (context) => GetStarted(),
        ...Routes.routes,
      },
      home: _initialPage ??
          const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
    );
  }

  void _determineInitialPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email');

    if (userEmail != null) {
      try {
        await HabitDbProvider.db.syncHabits();
        print("Sync complete at startup.");
      } catch (e) {
        print("Error syncing habits at startup: $e");
      }
    }

    setState(() {
      _initialPage = userEmail == null ? LoginPage() : Home();
    });
  }

  void _setSystemUIOverlay(bool isDarkTheme) {
    final colorScheme = isDarkTheme
        ? MaterialTheme.dark().colorScheme
        : MaterialTheme.light().colorScheme;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: colorScheme.primaryContainer,
        systemNavigationBarIconBrightness:
        isDarkTheme ? Brightness.light : Brightness.dark,
        statusBarColor: colorScheme.primaryContainer,
        statusBarIconBrightness:
        isDarkTheme ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
