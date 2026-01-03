import 'package:flutter/material.dart';
import '../services/habit_service.dart';
import '../models/habit.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailScreen({
    super.key,
    required this.habitId,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  DateTime _currentDate = DateTime.now();
  final HabitService _habitService = HabitService();

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

  int _calculateStreak(Map<String, bool> completionHistory) {
    if (completionHistory.isEmpty) return 0;
    
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    if (completionHistory[todayKey] != true) {
      return 0;
    }
    
    int streak = 1;
    
    for (int i = 1; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      if (completionHistory[dateKey] == true) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  int _calculateBestStreak(Map<String, bool> completionHistory) {
    if (completionHistory.isEmpty) return 0;
    
    final completedDates = <DateTime>[];
    
    completionHistory.forEach((dateKey, completed) {
      if (completed == true) {
        try {
          final parts = dateKey.split('-');
          if (parts.length == 3) {
            final date = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            completedDates.add(date);
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
    });
    
    if (completedDates.isEmpty) return 0;
    
    completedDates.sort((a, b) => b.compareTo(a));
    
    int maxStreak = 0;
    int currentStreak = 1;
    
    for (int i = 0; i < completedDates.length - 1; i++) {
      final currentDate = completedDates[i];
      final nextDate = completedDates[i + 1];
      final daysDiff = currentDate.difference(nextDate).inDays;
      
      if (daysDiff == 1) {
        currentStreak++;
      } else {
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
        currentStreak = 1;
      }
    }
    
    maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
    return maxStreak;
  }

  Future<void> _onDayTap(int dayNumber, Habit habit) async {
    final tappedDate = DateTime(_currentDate.year, _currentDate.month, dayNumber);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final tappedDateOnly = DateTime(tappedDate.year, tappedDate.month, tappedDate.day);
    
    // Check if tapped date is in the future
    if (tappedDateOnly.isAfter(todayOnly)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You cannot mark future dates as completed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    
    final dateKey = '${tappedDate.year}-${tappedDate.month.toString().padLeft(2, '0')}-${tappedDate.day.toString().padLeft(2, '0')}';
    
    final newCompletionHistory = Map<String, bool>.from(habit.completionHistory);
    final wasCompleted = newCompletionHistory[dateKey] ?? false;
    newCompletionHistory[dateKey] = !wasCompleted;

    // Calculate new streak
    final newStreak = _calculateStreak(newCompletionHistory);
    final newBestStreak = _calculateBestStreak(newCompletionHistory);
    final finalBestStreak = newBestStreak > habit.bestStreak ? newBestStreak : habit.bestStreak;

    // Get today's date key to update isCompleted
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final isCompleted = newCompletionHistory[todayKey] ?? false;

    // Update in Firestore - StreamBuilder will automatically update UI
    try {
      await _habitService.updateHabit(
        habitId: widget.habitId,
        isCompleted: isCompleted,
        streak: newStreak,
        bestStreak: finalBestStreak,
        completionHistory: newCompletionHistory,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating habit: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildCalendarGrid(Map<int, bool> completionHistoryInt, String habitEmoji, Habit habit) {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    // Adjust to start from Monday (1)
    final startOffset = firstWeekday == 7 ? 0 : firstWeekday - 1;
    
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final totalCellsRounded = rows * 7;
    
    return Column(
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
            final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
          itemCount: totalCellsRounded,
          itemBuilder: (context, index) {
            if (index < startOffset) {
              // Empty cells before first day of month
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1,
                  ),
                ),
              );
            }
            
            final dayNumber = index - startOffset + 1;
            if (dayNumber > daysInMonth) {
              // Empty cells after last day of month
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1,
                  ),
                ),
              );
            }
            
            final isCompleted = completionHistoryInt[dayNumber] ?? false;
            final now = DateTime.now();
            final isToday = dayNumber == now.day && 
                           _currentDate.month == now.month && 
                           _currentDate.year == now.year;
            
            return GestureDetector(
              onTap: () => _onDayTap(dayNumber, habit),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF9B59B6),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: isToday ? const Color(0xFF9B59B6).withAlpha(26) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday ? const Color(0xFF9B59B6) : const Color(0xFF2C3E50),
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: isCompleted
                            ? Text(
                                habitEmoji,
                                style: const TextStyle(fontSize: 20),
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Habit?>(
      stream: _habitService.getHabitStream(widget.habitId),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // No data
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Habit not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
        
        final habit = snapshot.data!;
        final now = DateTime.now();
    
    final last7Days = <String>[];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      last7Days.add(dateKey);
    }
    
    int last7DaysCompleted = 0;
    for (final dateKey in last7Days) {
      if (habit.completionHistory.containsKey(dateKey)) {
        final value = habit.completionHistory[dateKey];
        if (value == true) {
          last7DaysCompleted++;
        }
      }
    }
    
    final last30Days = <String>[];
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      last30Days.add(dateKey);
    }
    
    int last30DaysCompleted = 0;
    for (final dateKey in last30Days) {
      if (habit.completionHistory.containsKey(dateKey)) {
        final value = habit.completionHistory[dateKey];
        if (value == true) {
          last30DaysCompleted++;
        }
      }
    }
    
    final totalCompletions = habit.completionHistory.values
        .where((v) => v == true)
        .length;

    final currentStreak = _calculateStreak(habit.completionHistory);
    final bestStreak = _calculateBestStreak(habit.completionHistory);

    final completionHistoryInt = <int, bool>{};
    final currentYear = _currentDate.year;
    final currentMonth = _currentDate.month;
    
    // Convert completionHistory to day numbers (1-31) where dayNumber = day of month
    habit.completionHistory.forEach((dateKey, completed) {
      if (completed == true) {
        try {
          final parts = dateKey.split('-');
          if (parts.length == 3) {
            final date = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            // Only include dates from current displayed month
            if (date.year == currentYear && date.month == currentMonth) {
              completionHistoryInt[date.day] = true;
            }
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
    });

        return Scaffold(
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
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          habit.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          habit.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Streak information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(179),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Current Streak: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(
                          '$currentStreak days',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(179),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Best Streak: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(
                          '$bestStreak days',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
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
                ),
                child: _buildCalendarGrid(completionHistoryInt, habit.emoji, habit),
              ),
            ),
            const SizedBox(height: 24),
            // Statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(179),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Last 7 Days',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$last7DaysCompleted/7',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Last 30 Days',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$last30DaysCompleted/30',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Total Completions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalCompletions times',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
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

