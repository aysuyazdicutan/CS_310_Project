import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/neo_brutalist_button.dart';
import '../widgets/custom_switch.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  bool _notificationsEnabled = false;
  bool _isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEFF5), // Pastel açık mavi
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Title
              Text(
                "Let's personalize your experience",
                style: GoogleFonts.permanentMarker(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              // Allow notifications switch
              CustomSwitch(
                label: 'Allow notifications',
                icon: const Icon(
                  Icons.notifications,
                  size: 24,
                  color: Colors.black,
                ),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              // Choose Theme switch
              CustomSwitch(
                label: 'Choose Theme',
                icon: Row(
                  children: [
                    Icon(
                      _isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                      size: 24,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isDarkTheme ? 'Dark' : 'Light',
                      style: GoogleFonts.permanentMarker(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                value: _isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _isDarkTheme = value;
                  });
                },
              ),
              const Spacer(),
              // Continue button
              Center(
                child: NeoBrutalistButton(
                  text: 'Continue',
                  onPressed: () {
                    // Burada bir sonraki ekrana geçiş yapılabilir
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

