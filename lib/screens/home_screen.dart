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

  void _toggleHabit(String id, HabitProvider habitProvider) async {
    final habit = habitProvider.habits.firstWhere((h) => h.id == id);
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final newCompletionHistory = Map<String, bool>.from(habit.completionHistory);
    final wasCompleted = newCompletionHistory[todayKey] ?? false;
    newCompletionHistory[todayKey] = !wasCompleted;
    
    final newStreak = _calculateStreak(newCompletionHistory);
    final newBestStreak = _calculateBestStreak(newCompletionHistory);
    final finalBestStreak = newBestStreak > habit.bestStreak ? newBestStreak : habit.bestStreak;
    
    await habitProvider.updateHabit(
      habitId: id,
      isCompleted: !wasCompleted,
      streak: newStreak,
      bestStreak: finalBestStreak,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(
          habitId: habit.id,
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
                  : habitProvider.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Error loading habits',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  habitProvider.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (authProvider.user != null) {
                                      habitProvider.initialize(authProvider.user!.uid);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A90E2),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
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
              // Statistics screen now uses Provider to get real-time habit data
              Navigator.pushNamed(context, '/statistics');
            } else if (index == 2) {
              // Navigate to Streak Calendar
              // StreakCalendarScreen now uses Provider to get real-time habit data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StreakCalendarScreen(),
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

