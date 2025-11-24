import 'package:flutter/material.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';

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
      home: const WelcomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/registration': (context) => const RegistrationScreen(),
      },
    );
  }
}

