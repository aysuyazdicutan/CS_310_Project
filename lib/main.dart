import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/settings_provider.dart';
import 'services/auth_service.dart';
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
  
  // Initialize SettingsProvider and load preferences
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadPreferences();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: const PerpetuaApp(),
    ),
  );
}

class PerpetuaApp extends StatelessWidget {
  const PerpetuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
    return MaterialApp(
      title: 'Perpetua',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFE6F2FA),
            cardColor: Colors.white,
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Color(0xFF2C3E50),
              ),
              titleLarge: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Color(0xFF2C3E50),
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Color(0xFF2C3E50),
              ),
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
              secondary: Color(0xFF4A90E2),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Roboto',
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            cardColor: const Color(0xFF1E293B),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
              titleLarge: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF38BDF8),
              secondary: Color(0xFF38BDF8),
            ),
          ),
          themeMode: settingsProvider.darkModeEnabled 
              ? ThemeMode.dark 
              : ThemeMode.light,
      // App-level router decides which flow to show based on auth state.
      home: const AppRouter(),
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
        );
      },
    );
  }
}

/// Top-level widget that reacts to authentication state using StreamBuilder.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Error state
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }
        
        // No authenticated user - show login/signup flow
        if (!snapshot.hasData || snapshot.data == null) {
          return const WelcomeScreen();
        }
        
        // User is authenticated - show home screen
        return const HomeScreen();
      },
    );
  }
}
