import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:perpetua/screens/welcome_screen.dart';
import 'package:perpetua/providers/settings_provider.dart';

void main() {
  group('WelcomeScreen Widget Tests', () {
    testWidgets('WelcomeScreen should display welcome text and PERPETUA title',
        (WidgetTester tester) async {
      // Create a mock SettingsProvider
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SettingsProvider>(
            create: (_) => settingsProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      // Wait for the widget to load
      await tester.pumpAndSettle();

      // Verify that "Welcome to" text is displayed
      expect(find.text('Welcome to'), findsOneWidget);

      // Verify that "PERPETUA" title is displayed
      expect(find.text('PERPETUA'), findsOneWidget);

      // Verify that the slogan text is displayed
      expect(
          find.textContaining(
              "Build positive habits and keep your streak alive"),
          findsOneWidget);

      // Verify that "Get Started" button is displayed
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('WelcomeScreen should have Get Started button that is tappable',
        (WidgetTester tester) async {
      // Create a mock SettingsProvider
      final settingsProvider = SettingsProvider();

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/login': (context) => const Scaffold(
                  body: Text('Login Screen'),
                ),
          },
          home: ChangeNotifierProvider<SettingsProvider>(
            create: (_) => settingsProvider,
            child: const WelcomeScreen(),
          ),
        ),
      );

      // Wait for the widget to load
      await tester.pumpAndSettle();

      // Find the Get Started button by type
      final getStartedButton = find.byType(ElevatedButton);
      expect(getStartedButton, findsOneWidget);

      // Verify the button is tappable
      expect(tester.widget<ElevatedButton>(getStartedButton).onPressed,
          isNotNull);

      // Tap the button
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // Verify navigation occurred (this will navigate to /login route)
      // Note: Since we're not using a full navigation setup, we just verify
      // that the button tap doesn't throw an error
    });
  });
}
