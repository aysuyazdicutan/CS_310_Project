import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // Logo Text
              Text(
                'PERPETUA',
                style: GoogleFonts.permanentMarker(
                  fontSize: 50,
                  color: const Color(0xFF1565C0), // Dark blue
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),
              
              // Stylish Icon instead of Image (Safe against errors)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 3, color: Colors.black),
                  color: Colors.white.withOpacity(0.5),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 80,
                  color: Colors.black87,
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
                    color: Colors.black87,
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
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2),
                  elevation: 8,
                  shadowColor: Colors.purple, // Retro shadow effect
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