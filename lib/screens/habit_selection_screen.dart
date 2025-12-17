import 'package:flutter/material.dart';

class HabitSelectionScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allHabits;
  final Set<String> selectedHabitIds;

  const HabitSelectionScreen({
    super.key,
    required this.allHabits,
    required this.selectedHabitIds,
  });

  @override
  State<HabitSelectionScreen> createState() => _HabitSelectionScreenState();
}

class _HabitSelectionScreenState extends State<HabitSelectionScreen> {
  late Set<String> _selectedHabitIds;

  @override
  void initState() {
    super.initState();
    // If selectedHabitIds is empty, select all habits by default
    if (widget.selectedHabitIds.isEmpty) {
      _selectedHabitIds = widget.allHabits.map((h) => h['id'] as String).toSet();
    } else {
      _selectedHabitIds = Set<String>.from(widget.selectedHabitIds);
    }
  }

  void _toggleHabit(String habitId) {
    setState(() {
      if (_selectedHabitIds.contains(habitId)) {
        _selectedHabitIds.remove(habitId);
      } else {
        _selectedHabitIds.add(habitId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back button and title
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context, _selectedHabitIds),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF9B59B6),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Streak Calendar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Habit list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: widget.allHabits.length,
                itemBuilder: (context, index) {
                  final habit = widget.allHabits[index];
                  final habitId = habit['id'] as String;
                  final habitName = habit['name'] as String;
                  final habitEmoji = habit['emoji'] as String;
                  final isSelected = _selectedHabitIds.contains(habitId);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF9B59B6),
                        width: 1,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => _toggleHabit(habitId),
                      child: Row(
                        children: [
                          Text(
                            habitEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              habitName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? const Color(0xFF9B59B6) : Colors.grey,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Instruction text
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'Tap to view this habit on the Streak Calendar',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

