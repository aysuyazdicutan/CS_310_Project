import 'package:flutter/material.dart';
// Your Imports
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/personalization_screen.dart';
// Friends' Imports
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/add_new_habit_screen.dart';

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
      // App starts with your screen
      home: const WelcomeScreen(),
      
      // All Routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/personalization': (context) => const PersonalizationScreen(),
        '/home': (context) => const HomeScreen(),
        '/addHabit': (context) => const AddNewHabitScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/reminders': (context) => const RemindersScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}