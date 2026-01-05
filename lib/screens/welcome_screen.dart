import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_paddings.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().darkModeEnabled;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppPaddings.paddingXLarge,
            vertical: AppPaddings.spacingXXXLarge,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: AppPaddings.spacingXXXLarge),
              // Top Text
              Text(
                'Welcome to',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 24,
                  color: textColor,
                ),
              ),
              SizedBox(height: AppPaddings.paddingXSmall),
              // Logo Text
              Text(
                'PERPETUA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: AppPaddings.spacingXXXLarge),
              
              // Image Container
              Container(
                padding: AppPaddings.paddingAllLarge,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: AppPaddings.shadowBlurMedium,
                      offset: AppPaddings.shadowOffsetSmall,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/kalp-Photoroom.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: AppPaddings.spacingXXXLarge),
              // Slogan
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPaddings.paddingLarge),
                child: Text(
                  "Build positive habits and keep your streak alive – don't break the chain!",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: AppPaddings.spacingXXXXLarge),
              
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: AppPaddings.buttonPaddingVerticalLarge,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppPaddings.borderRadiusLarge,
                    ),
                    elevation: 8,
                    shadowColor: AppColors.primaryPurple.withAlpha(128),
                  ),
                  child: Text(
                    'Get Started',
                    style: AppTextStyles.buttonXLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppPaddings.spacingXXXLarge),
            ],
          ),
        ),
      ),
    );
  }
}