import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_paddings.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPaddings.paddingAllXLarge,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppPaddings.spacingXXXLarge),
                // Title with handwritten style
                const Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.registrationTitle,
                ),
                const SizedBox(height: AppPaddings.spacingXXXXLarge),
                // White rounded container
                Container(
                  padding: AppPaddings.paddingAllXLarge,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackgroundLight,
                    borderRadius: AppPaddings.borderRadiusLarge,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title
                      const Text(
                        'Registration',
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: AppPaddings.spacingXLarge),
                      // Full Name field
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          border: OutlineInputBorder(
                            borderRadius: AppPaddings.borderRadiusMedium,
                            borderSide: const BorderSide(
                              color: AppColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppPaddings.borderRadiusMedium,
                            borderSide: const BorderSide(
                              color: AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppPaddings.borderRadiusMedium,
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackgroundLight,
                          contentPadding: AppPaddings.inputPadding,
                        ),
                      ),
                      const SizedBox(height: AppPaddings.spacingLarge),
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(
                            borderRadius: AppPaddings.borderRadiusMedium,
                            borderSide: const BorderSide(
                              color: AppColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppPaddings.borderRadiusMedium,
                            borderSide: const BorderSide(
                              color: AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppPaddings.borderRadiusMedium,
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackgroundLight,
                          contentPadding: AppPaddings.inputPadding,
                        ),
                      ),
                      const SizedBox(height: AppPaddings.spacingLarge),
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(
                            borderRadius: AppPaddings.borderRadiusMedium,
                            borderSide: const BorderSide(
                              color: AppColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppPaddings.borderRadiusMedium,
                            borderSide: const BorderSide(
                              color: AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppPaddings.borderRadiusMedium,
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackgroundLight,
                          contentPadding: AppPaddings.inputPadding,
                        ),
                      ),
                      const SizedBox(height: AppPaddings.spacingXLarge),
                      // Terms and Privacy Policy text
                      const Text(
                        'I agree to the Terms and Privacy Policy',
                        style: AppTextStyles.labelMedium,
                      ),
                      const SizedBox(height: AppPaddings.spacingSmall),
                      // Yes checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          const Text(
                            'Yes',
                            style: AppTextStyles.labelMedium,
                          ),
                        ],
                      ),
                      // No checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: !_agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = !(value ?? false);
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          const Text(
                            'No',
                            style: AppTextStyles.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppPaddings.spacingXXLarge),
                // Register Now button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _agreedToTerms) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else if (!_agreedToTerms) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please agree to the Terms and Privacy Policy'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: AppPaddings.buttonPaddingVerticalLarge,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppPaddings.borderRadiusMedium,
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Register Now',
                    style: AppTextStyles.buttonXLarge,
                  ),
                ),
                const SizedBox(height: AppPaddings.spacingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

