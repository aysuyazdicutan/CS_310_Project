import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App text styles
/// 
/// Centralized text style definitions for consistent typography.
/// Use these constants instead of defining TextStyle inline.
class AppTextStyles {
  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headlineLargeDark = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: AppColors.textPrimaryDark,
  );
  
  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle titleMediumDark = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: AppColors.textPrimaryDark,
  );
  
  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyLargeDark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    color: AppColors.textPrimaryDark,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmallDark = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimaryDark,
  );
  
  // Button styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle buttonXLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  // Label styles
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );
  
  // Registration screen specific
  static const TextStyle registrationTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    letterSpacing: 1.2,
    color: AppColors.textPrimary,
  );
  
  // Private constructor to prevent instantiation
  AppTextStyles._();
}





