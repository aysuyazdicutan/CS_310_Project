import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/neo_brutalist_button.dart';
import 'personalization_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEFF5), // Pastel açık mavi
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Welcome to text
              Text(
                'Welcome to',
                style: GoogleFonts.permanentMarker(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              // PERPETUA text
              Text(
                'PERPETUA',
                style: GoogleFonts.permanentMarker(
                  fontSize: 64,
                  color: const Color(0xFF1565C0), // Koyu mavi
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              
              // RESİM YERİNE İKON
              const Icon(
                Icons.favorite_border_rounded,
                size: 150,
                color: Colors.black87,
              ),

              const SizedBox(height: 40),
              // Slogan text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  // DÜZELTİLEN SATIR BURASI (Çift Tırnak Kullanıldı)
                  "Build positive habits and keep your streak alive – don't break the chain!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.permanentMarker(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Get Started button
              NeoBrutalistButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalizationScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}