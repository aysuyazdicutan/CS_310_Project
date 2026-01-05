import 'package:flutter/material.dart';

/// App padding and spacing constants
/// 
/// Centralized padding, spacing, and size definitions.
/// Use these constants for consistent spacing throughout the app.
class AppPaddings {
  // Padding constants
  static const double paddingXSmall = 8.0;
  static const double paddingSmall = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 24.0;
  static const double paddingXXLarge = 32.0;
  
  // Spacing (SizedBox height/width)
  static const double spacingXSmall = 8.0;
  static const double spacingSmall = 12.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 20.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;
  static const double spacingXXXLarge = 40.0;
  static const double spacingXXXXLarge = 50.0;
  
  // Border radius
  static const double radiusXSmall = 2.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
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
  
  // Common EdgeInsets
  static const EdgeInsets paddingAllSmall = EdgeInsets.all(paddingSmall);
  static const EdgeInsets paddingAllMedium = EdgeInsets.all(paddingMedium);
  static const EdgeInsets paddingAllLarge = EdgeInsets.all(paddingLarge);
  static const EdgeInsets paddingAllXLarge = EdgeInsets.all(paddingXLarge);
  
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: paddingMedium);
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(horizontal: paddingLarge);
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(vertical: paddingMedium);
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(vertical: 18.0);
  
  // Button padding
  static const EdgeInsets buttonPaddingVertical = EdgeInsets.symmetric(vertical: paddingMedium);
  static const EdgeInsets buttonPaddingVerticalLarge = EdgeInsets.symmetric(vertical: 18.0);
  static const EdgeInsets buttonPaddingHorizontal = EdgeInsets.symmetric(horizontal: paddingLarge, vertical: paddingMedium);
  
  // Input field padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: paddingMedium, vertical: paddingMedium);
  
  // Border radius objects
  static BorderRadius borderRadiusXSmall = BorderRadius.circular(radiusXSmall);
  static BorderRadius borderRadiusSmall = BorderRadius.circular(radiusSmall);
  static BorderRadius borderRadiusMedium = BorderRadius.circular(radiusMedium);
  static BorderRadius borderRadiusLarge = BorderRadius.circular(radiusLarge);
  
  // Private constructor to prevent instantiation
  AppPaddings._();
}






