import 'package:flutter/material.dart';

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

    // Print the entered values
    print('Habit Name: ${habitData['name']}');
    print('Days per week: ${habitData['daysPerWeek']}');
    print('Emoji: ${habitData['emoji']}');
    
    // Navigate back with the habit data
    Navigator.pop(context, habitData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // White rounded card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    const Text(
                      'Add New Habit',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Habit Name text field
                    TextField(
                      controller: _habitNameController,
                      decoration: InputDecoration(
                        labelText: 'Habit Name',
                        labelStyle: const TextStyle(
                          color: Color(0xFF2C3E50),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // "How many days a week will you do it?" section
                    const Text(
                      'How many days a week will you do it?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                  ? const Color(0xFF4A90E2)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4A90E2)
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    // Text field for choosing an emoji
                    TextField(
                      controller: _emojiController,
                      decoration: InputDecoration(
                        labelText: 'Choose an emoji',
                        labelStyle: const TextStyle(
                          color: Color(0xFF2C3E50),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: 'e.g., 💪',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Large rounded "Add" button
              ElevatedButton(
                onPressed: _handleAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

