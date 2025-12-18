import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/auth_provider.dart';
import 'habit_detail_screen.dart';
import 'streak_calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String get _todayDate {
    final now = DateTime.now();
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
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  void _toggleHabit(String id, HabitProvider habitProvider) async {
    final habit = habitProvider.habits.firstWhere((h) => h.id == id);
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final newCompletionHistory = Map<String, bool>.from(habit.completionHistory);
    final wasCompleted = newCompletionHistory[todayKey] ?? false;
    newCompletionHistory[todayKey] = !wasCompleted;
    
    // Calculate new streak
    int newStreak = habit.streak;
    if (!wasCompleted) {
      // Marking as completed - increment streak
      newStreak = habit.streak + 1;
    } else {
      // Unmarking - decrement streak (but not below 0)
      newStreak = (habit.streak > 0) ? habit.streak - 1 : 0;
    }
    
    final newBestStreak = newStreak > habit.bestStreak ? newStreak : habit.bestStreak;
    
    await habitProvider.updateHabit(
      habitId: id,
      isCompleted: !wasCompleted,
      streak: newStreak,
      bestStreak: newBestStreak,
      completionHistory: newCompletionHistory,
    );
  }

  void _deleteHabit(String id, HabitProvider habitProvider) async {
    final success = await habitProvider.deleteHabit(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToHabitDetail(Habit habit) {
    // Calculate statistics from completionHistory (date string -> bool)
    final now = DateTime.now();
    final last7Days = <String>[];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      last7Days.add(dateKey);
    }
    
    final last7DaysCompleted = habit.completionHistory.entries
        .where((e) => last7Days.contains(e.key) && e.value)
        .length;
    
    // Last 30 days
    final last30Days = <String>[];
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      last30Days.add(dateKey);
    }
    
    final last30DaysCompleted = habit.completionHistory.entries
        .where((e) => last30Days.contains(e.key) && e.value)
        .length;
    
    // Total completions
    final totalCompletions = habit.completionHistory.values
        .where((v) => v)
        .length;

    // Convert completionHistory to Map<int, bool> for HabitDetailScreen compatibility
    // Using day of year as key
    final completionHistoryInt = <int, bool>{};
    habit.completionHistory.forEach((dateKey, completed) {
      if (completed) {
        try {
          final parts = dateKey.split('-');
          if (parts.length == 3) {
            final date = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
            completionHistoryInt[dayOfYear] = true;
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(
          habitName: habit.name,
          habitEmoji: habit.emoji,
          currentStreak: habit.streak,
          bestStreak: habit.bestStreak,
          completionHistory: completionHistoryInt,
          last7Days: last7DaysCompleted,
          last30Days: last30DaysCompleted,
          totalCompletions: totalCompletions,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final authProvider = context.watch<AuthProvider>();
    final habits = habitProvider.habits;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: const Text(
                      'PROFILE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    _todayDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const Text(
                    'Keep the chain alive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Your habits',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ),
            // Habits list
            Expanded(
              child: habitProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : habits.isEmpty
                      ? const Center(
                          child: Text(
                            'No habits yet. Add one!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            final habit = habits[index];
                            final today = DateTime.now();
                            final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                            final isCompleted = habit.completionHistory[todayKey] ?? false;
                        return Dismissible(
                          key: Key(habit.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          onDismissed: (direction) {
                            _deleteHabit(habit.id, habitProvider);
                          },
                          child: GestureDetector(
                            onTap: () => _navigateToHabitDetail(habit),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Toggle icon
                                  GestureDetector(
                                    onTap: () => _toggleHabit(habit.id, habitProvider),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCompleted
                                            ? const Color(0xFF4A90E2)
                                            : Colors.grey[200],
                                        border: Border.all(
                                          color: isCompleted
                                              ? const Color(0xFF4A90E2)
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: isCompleted
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 24,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Habit emoji and name
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          habit.emoji,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            habit.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2C3E50),
                                              decoration: isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Streak indicator
                                  Row(
                                    children: [
                                      const Text(
                                        '🔥',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${habit.streak}D',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Add button
            const Text(
              'Swipe left to delete',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/addHabit');
                  if (result != null && result is Map<String, dynamic> && authProvider.user != null) {
                    final success = await habitProvider.createHabit(
                      title: result['name'] as String,
                      description: '',
                      userId: authProvider.user!.uid,
                      emoji: result['emoji'] as String,
                    );
                    if (!success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(habitProvider.errorMessage ?? 'Failed to create habit'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                backgroundColor: const Color(0xFF4A90E2),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            // Navigate to screens when tapping bottom nav items
            if (index == 0) {
              Navigator.pushNamed(
                context,
                '/reminders',
                arguments: habits
                    .map(
                      (habit) => {
                        'id': habit.id,
                        'name': habit.name,
                        'emoji': habit.emoji,
                      },
                    )
                    .toList(),
              );
            } else if (index == 1) {
              Navigator.pushNamed(
                context,
                '/statistics',
                arguments: habits
                    .map(
                      (habit) => {
                        'id': habit.id,
                        'name': habit.name,
                        'emoji': habit.emoji,
                        'streak': habit.streak,
                        'bestStreak': habit.bestStreak,
                        'completionHistory': habit.completionHistory,
                      },
                    )
                    .toList(),
              );
            } else if (index == 2) {
              // Navigate to Streak Calendar
              // Convert completionHistory from Map<String, bool> to Map<int, bool> for compatibility
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreakCalendarScreen(
                    habits: habits.map((habit) {
                      final historyInt = <int, bool>{};
                      habit.completionHistory.forEach((dateKey, completed) {
                        if (completed) {
                          try {
                            final parts = dateKey.split('-');
                            if (parts.length == 3) {
                              final date = DateTime(
                                int.parse(parts[0]),
                                int.parse(parts[1]),
                                int.parse(parts[2]),
                              );
                              final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
                              historyInt[dayOfYear] = true;
                            }
                          } catch (e) {
                            // Skip invalid dates
                          }
                        }
                      });
                      return {
                        'id': habit.id,
                        'name': habit.name,
                        'emoji': habit.emoji,
                        'completionHistory': historyInt,
                      };
                    }).toList(),
                  ),
                ),
              );
            } else if (index == 3) {
              Navigator.pushNamed(context, '/settings');
            }
            // Reset index after navigation
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {
                  _selectedIndex = 0; // Reset to first item
                });
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF4A90E2),
          unselectedItemColor: Colors.grey[600],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              label: 'Reminders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department_outlined),
              label: 'Streaks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

