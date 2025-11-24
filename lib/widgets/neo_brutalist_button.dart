import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoBrutalistButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const NeoBrutalistButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.cyan,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.purple,
              offset: const Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.permanentMarker(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

