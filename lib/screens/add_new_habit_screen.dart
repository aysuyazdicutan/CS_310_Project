import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_paddings.dart';

class AddNewHabitScreen extends StatefulWidget {
  const AddNewHabitScreen({super.key});

  @override
  State<AddNewHabitScreen> createState() => _AddNewHabitScreenState();
}

class _AddNewHabitScreenState extends State<AddNewHabitScreen> {
  final _habitNameController = TextEditingController();
  final _emojiController = TextEditingController();
  int? _selectedDaysPerWeek;

  @override
  void dispose() {
    _habitNameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    // Validate that required fields are filled
    if (_habitNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a habit name'),
        ),
      );
      return;
    }

    // Create a map with the habit data
    final habitData = {
      'name': _habitNameController.text.trim(),
      'emoji': _emojiController.text.trim().isNotEmpty 
          ? _emojiController.text.trim() 
          : '✨', // Default emoji if none provided
      'daysPerWeek': _selectedDaysPerWeek ?? 7, // Default to 7 if not selected
    };
    
    // Show success dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('New habit created successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog first
                Navigator.of(dialogContext).pop();
                // Then close the screen and return the habit data
                Navigator.pop(context, habitData);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppPaddings.paddingXLarge,
            vertical: AppPaddings.paddingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // White rounded card
              Container(
                padding: AppPaddings.paddingAllXLarge,
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(AppPaddings.paddingLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: AppPaddings.shadowBlurLarge,
                      offset: AppPaddings.shadowOffsetMedium,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Add New Habit',
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppPaddings.spacingXXLarge),
                    // Habit Name text field
                    TextField(
                      controller: _habitNameController,
                      decoration: InputDecoration(
                        labelText: 'Habit Name',
                        labelStyle: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: AppPaddings.borderRadiusMedium,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: AppPaddings.inputPadding,
                      ),
                    ),
                    SizedBox(height: AppPaddings.spacingXXLarge),
                    // "How many days a week will you do it?" section
                    Text(
                      'How many days a week will you do it?',
                      style: AppTextStyles.bodyMedium,
                    ),
                    SizedBox(height: AppPaddings.paddingMedium),
                    // 7 selectable boxes labeled 1-7
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final dayNumber = index + 1;
                        final isSelected = _selectedDaysPerWeek == dayNumber;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDaysPerWeek = dayNumber;
                            });
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.cardBackgroundLight,
                              borderRadius: AppPaddings.borderRadiusMedium,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[300]!,
                                width: AppPaddings.borderWidthMedium,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$dayNumber',
                                style: AppTextStyles.buttonXLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: AppPaddings.spacingXXLarge),
                    // Text field for choosing an emoji
                    TextField(
                      controller: _emojiController,
                      decoration: InputDecoration(
                        labelText: 'Choose an emoji',
                        labelStyle: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: AppPaddings.borderRadiusMedium,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: AppPaddings.inputPadding,
                        hintText: 'e.g., 💪',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppPaddings.spacingXXLarge),
              // Large rounded "Add" button
              ElevatedButton(
                onPressed: _handleAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: AppPaddings.buttonPaddingVerticalLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppPaddings.borderRadiusLarge,
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Add',
                  style: AppTextStyles.buttonXLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: AppPaddings.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }
}

