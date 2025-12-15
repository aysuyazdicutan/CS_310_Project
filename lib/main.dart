import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
// Your Imports
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/personalization_screen.dart';
// Friends' Imports
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/add_new_habit_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PerpetuaApp());
}

class PerpetuaApp extends StatelessWidget {
  const PerpetuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Perpetua',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        home: const WelcomeScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/personalization': (context) => const PersonalizationScreen(),
          '/home': (context) => const HomeScreen(),
          '/addHabit': (context) => const AddNewHabitScreen(),
          '/registration': (context) => const RegistrationScreen(),
          '/reminders': (context) => const RemindersScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}