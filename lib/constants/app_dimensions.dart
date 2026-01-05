import 'package:flutter/material.dart';

/// App dimensions and size constants
/// 
/// Centralized dimension definitions for consistent sizing throughout the app.
/// Use these constants instead of hardcoding size values.
class AppDimensions {
  // Font family
  static const String fontFamily = 'Roboto';
  
  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  
  // Avatar sizes
  static const double avatarSmall = 40.0;
  static const double avatarMedium = 60.0;
  static const double avatarLarge = 100.0;
  
  // Button heights
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  
  // Border widths
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 3.0;
  
  // Shadow blur radius
  static const double shadowBlurSmall = 4.0;
  static const double shadowBlurMedium = 8.0;
  static const double shadowBlurLarge = 10.0;
  
  // Shadow offsets
  static const Offset shadowOffsetSmall = Offset(0, 2);
  static const Offset shadowOffsetMedium = Offset(0, 4);
  static const Offset shadowOffsetLarge = Offset(0, 6);
  
  // Private constructor to prevent instantiation
  AppDimensions._();
}

