import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  bool _allowNotifications = true;
  bool _isDarkMode = false; // Başlangıçta aydınlık mod

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                "Let's personalize\nyour experience",
                textAlign: TextAlign.center,
                style: GoogleFonts.permanentMarker(
                  fontSize: 28,
                  color: textColor, // YAZI RENGİ DEĞİŞKEN
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 50),

              // 1. OPTION: Notifications
              _buildCustomOptionCard(
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, size: 28, color: Colors.black),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Allow notifications",
                        style: GoogleFonts.permanentMarker(
                          fontSize: 18,
                          color: const Color(0xFF006064), // Dark Cyan text
                        ),
                      ),
                    ),
                    Switch(
                      value: _allowNotifications,
                      activeColor: Colors.black,
                      activeTrackColor: const Color(0xFF4DD0E1),
                      inactiveThumbColor: Colors.grey,
                      onChanged: (val) {
                        setState(() {
                          _allowNotifications = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Title for Theme
              Text(
                "Choose Theme",
                style: GoogleFonts.permanentMarker(
                  fontSize: 22,
                  color: textColor, // YAZI RENGİ DEĞİŞKEN
                ),
              ),
              const SizedBox(height: 10),

              // 2. OPTION: Theme Switcher
              _buildCustomOptionCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sun Icon (Light)
                    Icon(Icons.wb_sunny, color: Colors.orange[800], size: 28),
                    
                    Text(
                      _isDarkMode ? "Dark Mode 🌙" : "Light Mode ☀️",
                       style: GoogleFonts.permanentMarker(
                          fontSize: 18,
                          color: const Color(0xFF006064),
                        ),
                    ),

                    // Switch
                    Switch(
                      value: _isDarkMode,
                      activeColor: Colors.black,
                      activeTrackColor: Colors.indigo,
                      inactiveThumbColor: Colors.orange,
                      inactiveTrackColor: Colors.yellow[200],
                      onChanged: (val) {
                        setState(() {
                          _isDarkMode = val; // BURASI EKRANI YENİDEN ÇİZER
                        });
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Home or Next Screen
                    Navigator.pushNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DD0E1), // Cyan Button
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 2),
                    elevation: 8,
                    shadowColor: _isDarkMode ? Colors.white24 : Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.permanentMarker(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget
  Widget _buildCustomOptionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4), // Pastel Yellow background (Always keeps clarity)
        borderRadius: BorderRadius.circular(0), // Sharp corners
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}