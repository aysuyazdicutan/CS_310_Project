import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/settings_provider.dart';
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

/// Top-level widget that reacts to authentication state.
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  String? _initializedUserId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final habitProvider = context.read<HabitProvider>();

    // While auth is initializing or performing an action, show a simple loader.
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If there is no authenticated user, show the login / signup flow.
    // `WelcomeScreen` is assumed to navigate to Login / Signup screens.
    if (auth.user == null) {
      _initializedUserId = null;
      return const WelcomeScreen();
    }

    // If the user is authenticated, initialize habits (only once per user)
    final userId = auth.user!.uid;
    if (_initializedUserId != userId) {
      _initializedUserId = userId;
      habitProvider.initialize(userId);
    }

    return const HomeScreen();
  }
}
