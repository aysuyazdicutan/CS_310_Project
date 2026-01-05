import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habit_service.dart';
import '../providers/auth_provider.dart';
import '../models/habit.dart';
import '../constants/app_colors.dart';

class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  DateTime _currentDate = DateTime.now();
  Set<String>? _selectedHabitIds; // null = show all, empty set = show none, populated set = show selected

  @override
  void initState() {
    super.initState();
    // Initially, all habits are selected (null means show all)
    _selectedHabitIds = null;
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

  List<Widget> _buildCalendarDays(List<Map<String, dynamic>> habits) {
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
      final completedHabits = _getCompletedHabitsForDay(dayNumber, habits);
      
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

  List<String> _getCompletedHabitsForDay(int day, List<Map<String, dynamic>> habits) {
    List<String> emojis = [];
    final dateKey = '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    
    for (var habit in habits) {
      final habitId = habit['id'] as String;
      // null = show all, empty set = show none, populated set = show selected only
      if (_selectedHabitIds == null || _selectedHabitIds!.contains(habitId)) {
        // completionHistory can be either Map<String, bool> (date format) or Map<int, bool> (legacy)
        final completionHistory = habit['completionHistory'];
        
        bool isCompleted = false;
        if (completionHistory is Map<String, dynamic>) {
          // New format: Map<String, bool> with date keys like "2025-12-19"
          isCompleted = (completionHistory[dateKey] == true);
        } else if (completionHistory is Map<int, bool>) {
          // Legacy format: Map<int, bool> with day numbers
          isCompleted = (completionHistory[day] ?? false);
        }
        
        if (isCompleted) {
          emojis.add(habit['emoji'] as String);
        }
      }
    }
    return emojis;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final habitService = HabitService();
    
    final user = authProvider.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }
    
    final userId = user.uid;
        
        return StreamBuilder<List<Habit>>(
          stream: habitService.getHabitsStream(userId),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Error state
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                ),
              );
            }
            
            final habits = snapshot.data ?? [];
            final habitsMap = habits.map((habit) {
              return {
                'id': habit.id,
                'name': habit.name,
                'emoji': habit.emoji,
                'completionHistory': habit.completionHistory,
              };
            }).toList();
            
            return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
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
                      child: const Text(
                        '<',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9B59B6),
                          fontFamily: 'Roboto',
                        ),
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
                      child: const Text(
                        '>',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9B59B6),
                          fontFamily: 'Roboto',
                        ),
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
                      // Calendar days - AnimatedSwitcher ile smooth güncelleme
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: GridView.builder(
                          key: ValueKey(_selectedHabitIds?.toString() ?? 'all'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            childAspectRatio: 1,
                          ),
                          itemCount: _buildCalendarDays(habitsMap).length,
                          itemBuilder: (context, index) {
                            final days = _buildCalendarDays(habitsMap);
                            if (index < days.length) {
                              return days[index];
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Legend - Tıklanabilir habit listesi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(179),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tap to show/hide habits',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...habits.map((habit) {
                        final isVisible = _selectedHabitIds == null || _selectedHabitIds!.contains(habit.id);
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedHabitIds == null) {
                                // İlk tıklamada, tüm habit'leri seçili yap ama tıklananı kaldır
                                _selectedHabitIds = habits.map((h) => h.id).toSet()..remove(habit.id);
                              } else if (_selectedHabitIds!.contains(habit.id)) {
                                // Eğer seçiliyse, kaldır
                                _selectedHabitIds!.remove(habit.id);
                                // Eğer hiç habit kalmadıysa, null yap (hepsini göster)
                                if (_selectedHabitIds!.isEmpty) {
                                  _selectedHabitIds = null;
                                }
                              } else {
                                // Eğer seçili değilse, ekle
                                _selectedHabitIds!.add(habit.id);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isVisible ? Colors.transparent : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Checkmark indicator
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isVisible ? Icons.check_circle : Icons.radio_button_unchecked,
                                    key: ValueKey(isVisible),
                                    color: isVisible ? AppColors.primary : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isVisible ? 1.0 : 0.4,
                                  child: Text(
                                    habit.emoji,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: isVisible ? 1.0 : 0.4,
                                    child: Text(
                                      habit.name,
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
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
            );
          },
        );
  }
}

