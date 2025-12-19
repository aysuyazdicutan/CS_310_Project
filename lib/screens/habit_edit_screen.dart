import 'package:flutter/material.dart';
import '../services/habit_service.dart';

class HabitEditScreen extends StatefulWidget {
  final String habitId;
  final String habitName;
  final String habitEmoji;
  final Map<int, bool> completionHistory;

  const HabitEditScreen({
    super.key,
    required this.habitId,
    required this.habitName,
    required this.habitEmoji,
    required this.completionHistory,
  });

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  late Map<int, bool> _completionHistory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _completionHistory = Map<int, bool>.from(widget.completionHistory);
  }

  Map<String, bool> _convertToDateMap(Map<int, bool> dayMap) {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final dateMap = <String, bool>{};
    
    dayMap.forEach((dayNumber, completed) {
      if (completed && dayNumber >= 1 && dayNumber <= 28) {
        // dayNumber is the day of the month (1-28)
        try {
          final date = DateTime(currentYear, currentMonth, dayNumber);
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          dateMap[dateKey] = true;
        } catch (e) {
          // Invalid date (e.g., day 31 in a month with 30 days)
        }
      }
    });
    
    return dateMap;
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

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      final habitService = HabitService();
      
      // Get current habit to preserve bestStreak
      final habit = await habitService.getHabit(widget.habitId);
      if (habit == null) {
        throw 'Habit not found';
      }
      
      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;
      
      // Remove all dates from current month (days 1-28)
      final currentMonthDates = <String>[];
      for (int day = 1; day <= 28; day++) {
        try {
          final date = DateTime(currentYear, currentMonth, day);
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          currentMonthDates.add(dateKey);
        } catch (e) {
          // Skip invalid dates (e.g., day 31 in a month with 30 days)
        }
      }
      
      final existingHistory = Map<String, bool>.from(habit.completionHistory);
      
      for (final dateKey in currentMonthDates) {
        existingHistory.remove(dateKey);
      }
      
      final editedDates = _convertToDateMap(_completionHistory);
      existingHistory.addAll(editedDates);
      
      final newStreak = _calculateStreak(existingHistory);
      final newBestStreak = _calculateBestStreak(existingHistory);
      final finalBestStreak = newBestStreak > habit.bestStreak ? newBestStreak : habit.bestStreak;
      
      await habitService.updateHabit(
        habitId: widget.habitId,
        completionHistory: existingHistory,
        streak: newStreak,
        bestStreak: finalBestStreak,
      );
      
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _toggleDay(int dayNumber) {
    setState(() {
      _completionHistory[dayNumber] = !(_completionHistory[dayNumber] ?? false);
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
                        onTap: _isSaving ? null : () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF9B59B6),
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      if (_isSaving)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF9B59B6),
                              ),
                            ),
                          ),
                        )
                      else
                        TextButton(
                          onPressed: _saveChanges,
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Color(0xFF9B59B6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      widget.habitName,
                      style: const TextStyle(
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
            // Calendar grid
            Expanded(
              child: Padding(
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
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: 28,
                    itemBuilder: (context, index) {
                      final dayNumber = index + 1;
                      final isCompleted = _completionHistory[dayNumber] ?? false;
                      return GestureDetector(
                        onTap: () => _toggleDay(dayNumber),
                        child: Container(
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
                                top: 4,
                                left: 4,
                                child: Text(
                                  '$dayNumber',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF2C3E50),
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                              // Red X icon (only when completed)
                              if (isCompleted)
                                Positioned(
                                  top: 2,
                                  left: 2,
                                  child: GestureDetector(
                                    onTap: () => _toggleDay(dayNumber),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              // Emoji (centered, only when completed)
                              Center(
                                child: isCompleted
                                    ? Text(
                                        widget.habitEmoji,
                                        style: const TextStyle(fontSize: 24),
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Instruction text
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'Tap an item to mark completion',
                  style: const TextStyle(
                    fontSize: 16,
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

