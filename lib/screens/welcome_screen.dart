import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Eklendi
import '../providers/settings_provider.dart'; // Eklendi

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DARK MODE KONTROLÜ ---
    final isDark = context.watch<SettingsProvider>().darkModeEnabled;
    
    // Eğer Dark moddaysak yazılar Beyaz, değilse Siyah
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      // Arka plan rengi main.dart'tan geliyor (Koyu Siyah veya Beyaz)
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Spacer(flex: 2),
              // Top Text
              Text(
                'Welcome to',
                style: GoogleFonts.permanentMarker(
                  fontSize: 24,
                  color: textColor, // Dinamik Renk
                ),
              ),
              const SizedBox(height: 8),
              // Logo Text
              Text(
                'PERPETUA',
                style: GoogleFonts.permanentMarker(
                  fontSize: 50,
                  color: const Color(0xFF1565C0), // Logo rengi sabit kalabilir veya açılabilir
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              
              // Stylish Icon instead of Image
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 3, color: textColor), // Çerçeve rengi dinamik
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 80,
                  color: iconColor, // İkon rengi dinamik
                ),
              ),

              const SizedBox(height: 40),
              // Slogan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Build positive habits and keep your streak alive – don't break the chain!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.permanentMarker(
                    fontSize: 18,
                    color: iconColor, // Slogan rengi dinamik
                    height: 1.4,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              
              // Custom Styled Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DD0E1), // Cyan
                  foregroundColor: Colors.black, // Buton içi yazı hep siyah kalsın, okunur.
                  side: BorderSide(color: textColor, width: 2), // Kenarlık dinamik
                  elevation: 8,
                  shadowColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  'Get Started',
                  style: GoogleFonts.permanentMarker(fontSize: 20),
                ),
              ),
              const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}