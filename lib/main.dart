import 'package:flutter/material.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_new_habit_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const PerpetuaApp());
}

class PerpetuaApp extends StatelessWidget {
  const PerpetuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpetua',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/addHabit': (context) => const AddNewHabitScreen(),
        '/reminders': (context) => const RemindersScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

