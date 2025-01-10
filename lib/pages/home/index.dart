import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/models/notification.dart';
import 'package:habit_tracker/pages/home/components/habit_list.dart';
import 'package:habit_tracker/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/models/auth_view_model.dart';
import 'package:habit_tracker/pages/components/reusable_title_text.dart';
import 'package:habit_tracker/pages/components/theme_toggle_row.dart';

import 'modal/add.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    initializeNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    final authViewModel = Provider.of<AuthViewModel>(context);
    final isSyncing = authViewModel.isLoading;


    final isDarkMode = themeProvider.isDarkMode;
    final gradientColors = isDarkMode
        ? [
      colorScheme.tertiaryContainer,
      colorScheme.tertiary,
    ]
        : [
      colorScheme.secondaryContainer,
      colorScheme.secondary,
    ];

    final textColor = isDarkMode
        ? colorScheme.onTertiaryContainer
        : colorScheme.onSecondaryContainer;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.primary,

      body: SafeArea(
        child: Stack(
          children: [

            Container(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                children: [
                  _header(context),
                  const SizedBox(height: 10),
                  Expanded(child: HabitList()),
                ],
              ),
            ),


            if (isSyncing)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),


      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        onPressed: () {
          modalAddHabit(context).then((value) {
            if (value == null) return;

            final String? name = value['name'];
            final TimeOfDay? time = value['time'];
            final List<int>? daylist = value['daylist'];

            if (name != null && name.isNotEmpty) {
              Provider.of<HabitModel>(context, listen: false).add(
                name: name,
                time: time,
                daylist: daylist,
              );
            }
          });
        },
        child: const Icon(Icons.add, size: 30),
      ),


      bottomNavigationBar: _syncBar(
        context: context,
        gradientColors: gradientColors,
        textColor: textColor,
      ),
    );
  }


  Widget _header(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
      TitleText(),
        Row(
          children: [
            ThemeToggleRow(),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () => authViewModel.logout(context),
              icon: const Icon(Icons.logout),
              color: colorScheme.onPrimaryContainer,
              tooltip: 'Logout',
            ),
          ],
        ),
      ],
    );
  }


  Widget _syncBar({
    required BuildContext context,
    required List<Color> gradientColors,
    required Color textColor,
  }) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Container(
      height: 60, // Adjust as needed
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: InkWell(
        onTap: () async {
          try {
            await authViewModel.syncDataWithServer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data sync complete!')),
            );
          } catch (e) {
            print('Sync error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sync failed: $e')),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sync, color: textColor),
            const SizedBox(width: 6),
            Text(
              'Tap to Sync',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
