import 'package:flutter/material.dart';
import 'habit_selection_screen.dart';

class StreakCalendarScreen extends StatefulWidget {
  final List<Map<String, dynamic>> habits; // List of habits with their completion history

  const StreakCalendarScreen({
    super.key,
    required this.habits,
  });

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  DateTime _currentDate = DateTime.now();
  late Set<String> _selectedHabitIds;

  @override
  void initState() {
    super.initState();
    // Initially, all habits are selected (empty set means show all)
    _selectedHabitIds = {};
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  List<String> _getDaysOfWeek() {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }

  List<Widget> _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    // Adjust to start from Monday (1)
    final startOffset = firstWeekday == 7 ? 0 : firstWeekday - 1;
    
    List<Widget> days = [];
    
    // Add empty cells for days before the first day of the month
    for (int i = 0; i < startOffset; i++) {
      days.add(
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.transparent,
              width: 1,
            ),
          ),
        ),
      );
    }
    
    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final dayNumber = day;
      final completedHabits = _getCompletedHabitsForDay(dayNumber);
      
      days.add(
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF9B59B6),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // Day number
              Positioned(
                top: 2,
                left: 2,
                child: Text(
                  '$dayNumber',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2C3E50),
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              // Habit emojis
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 2,
                  children: completedHabits.map((emoji) {
                    return Text(
                      emoji,
                      style: const TextStyle(fontSize: 12),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return days;
  }

  List<String> _getCompletedHabitsForDay(int day) {
    List<String> emojis = [];
    for (var habit in widget.habits) {
      final habitId = habit['id'] as String;
      // If no habits are selected, show all. Otherwise, only show selected habits.
      if (_selectedHabitIds.isEmpty || _selectedHabitIds.contains(habitId)) {
        final completionHistory = habit['completionHistory'] as Map<int, bool>?;
        if (completionHistory != null && (completionHistory[day] ?? false)) {
          emojis.add(habit['emoji'] as String);
        }
      }
    }
    return emojis;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FA),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          onTap: () => Navigator.pop(context),
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
              // Month navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _previousMonth,
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF9B59B6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _getMonthYearString(_currentDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _nextMonth,
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF9B59B6),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Calendar grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF9B59B6),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Days of week header
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final daysOfWeek = _getDaysOfWeek();
                          return Center(
                            child: Text(
                              daysOfWeek[index],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                                fontFamily: 'Roboto',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      // Calendar days
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                        itemCount: _buildCalendarDays().length,
                        itemBuilder: (context, index) {
                          final days = _buildCalendarDays();
                          if (index < days.length) {
                            return days[index];
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.habits
                        .where((habit) {
                          final habitId = habit['id'] as String;
                          // Show all habits in legend if none selected, otherwise only selected ones
                          return _selectedHabitIds.isEmpty || _selectedHabitIds.contains(habitId);
                        })
                        .map((habit) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              habit['emoji'] as String,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              habit['name'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2C3E50),
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Edit button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF87CEEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF9B59B6),
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final result = await Navigator.push<Set<String>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitSelectionScreen(
                            allHabits: widget.habits,
                            selectedHabitIds: _selectedHabitIds,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _selectedHabitIds = result;
                        });
                      }
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Roboto',
                      ),
                    ),
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

