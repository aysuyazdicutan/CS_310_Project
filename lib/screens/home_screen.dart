import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/reminder.dart';
import '../services/habit_service.dart';
import '../services/auth_service.dart';
import '../providers/reminders_provider.dart';
import '../providers/habit_provider.dart';
import 'habit_detail_screen.dart';
import 'streak_calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Timer? _reminderCheckTimer;
  final Set<String> _shownReminderIds = {}; // Track reminders shown in this session

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

  void _toggleHabit(String id, List<Habit> habits) async {
    final habit = habits.firstWhere((h) => h.id == id);
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final newCompletionHistory = Map<String, bool>.from(habit.completionHistory);
    final wasCompleted = newCompletionHistory[todayKey] ?? false;
    newCompletionHistory[todayKey] = !wasCompleted;
    
    final newStreak = _calculateStreak(newCompletionHistory);
    final newBestStreak = _calculateBestStreak(newCompletionHistory);
    final finalBestStreak = newBestStreak > habit.bestStreak ? newBestStreak : habit.bestStreak;
    
    final habitService = HabitService();
    try {
      await habitService.updateHabit(
        habitId: id,
        isCompleted: !wasCompleted,
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

  void _deleteHabit(String id) async {
    final habitService = HabitService();
    try {
      await habitService.deleteHabit(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting habit: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
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
  void initState() {
    super.initState();
    // Load reminders from storage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final remindersProvider = context.read<RemindersProvider>();
      remindersProvider.loadFromStorage().then((_) {
        // Check reminders immediately after loading
        _checkReminders();
        // Then check every minute
        _reminderCheckTimer = Timer.periodic(
          const Duration(minutes: 1),
          (_) => _checkReminders(),
        );
      });
    });
  }

  @override
  void dispose() {
    _reminderCheckTimer?.cancel();
    super.dispose();
  }

  void _checkReminders() {
    if (!mounted) return;

    final remindersProvider = context.read<RemindersProvider>();
    final dueReminders = remindersProvider.getDueReminders();

    for (final reminder in dueReminders) {
      // Avoid showing the same reminder multiple times in one session
      if (_shownReminderIds.contains(reminder.id)) continue;

      _shownReminderIds.add(reminder.id);
      _showReminderDialog(reminder, remindersProvider);
    }
  }

  void _showReminderDialog(Reminder reminder, RemindersProvider provider) {
    if (!mounted) return;

    final habitProvider = context.read<HabitProvider>();
    final timeString =
        '${reminder.timeOfDay.hour.toString().padLeft(2, '0')}:${reminder.timeOfDay.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  reminder.habitEmoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'Time for ${reminder.habitTitle}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeString,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 24),
                // Mark Done button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Mark habit as completed
                      final habitProvider = context.read<HabitProvider>();
                      final habit = await habitProvider.getHabit(reminder.habitId);
                      if (habit != null) {
                        final today = DateTime.now();
                        final todayKey =
                            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                        final newCompletionHistory =
                            Map<String, bool>.from(habit.completionHistory);
                        newCompletionHistory[todayKey] = true;

                        // Calculate new streak
                        int streak = 1;
                        for (int i = 1; i < 365; i++) {
                          final date = today.subtract(Duration(days: i));
                          final dateKey =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          if (newCompletionHistory[dateKey] == true) {
                            streak++;
                          } else {
                            break;
                          }
                        }

                        await habitProvider.updateHabit(
                          habitId: habit.id,
                          isCompleted: true,
                          streak: streak,
                          completionHistory: newCompletionHistory,
                        );
                      }

                      // Mark reminder as shown
                      await provider.markShownToday(reminder.id);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B46C1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Mark Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Snooze button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await provider.snooze(reminder.id, minutes: 10);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B46C1),
                      side: const BorderSide(color: Color(0xFF6B46C1)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Snooze 10 min',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Dismiss button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      await provider.dismissReminder(reminder.id);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final habitService = HabitService();
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        // Loading auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // No authenticated user
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Please log in')),
          );
        }
        
        final userId = authSnapshot.data!.uid;

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
            // Missed Reminders Section
            Consumer<RemindersProvider>(
              builder: (context, remindersProvider, _) {
                final missedReminders = remindersProvider.getMissedReminders();
                if (missedReminders.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange[200]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Missed Today',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...missedReminders.map((reminder) {
                        final timeString =
                            '${reminder.timeOfDay.hour.toString().padLeft(2, '0')}:${reminder.timeOfDay.minute.toString().padLeft(2, '0')}';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                reminder.habitEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reminder.habitTitle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    Text(
                                      timeString,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Mark Done button
                              TextButton(
                                onPressed: () async {
                                  final habitProvider =
                                      context.read<HabitProvider>();
                                  final habit = await habitProvider
                                      .getHabit(reminder.habitId);
                                  if (habit != null) {
                                    final today = DateTime.now();
                                    final todayKey =
                                        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                                    final newCompletionHistory = Map<String, bool>.from(
                                        habit.completionHistory);
                                    newCompletionHistory[todayKey] = true;

                                    int streak = 1;
                                    for (int i = 1; i < 365; i++) {
                                      final date =
                                          today.subtract(Duration(days: i));
                                      final dateKey =
                                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                      if (newCompletionHistory[dateKey] ==
                                          true) {
                                        streak++;
                                      } else {
                                        break;
                                      }
                                    }

                                    await habitProvider.updateHabit(
                                      habitId: habit.id,
                                      isCompleted: true,
                                      streak: streak,
                                      completionHistory: newCompletionHistory,
                                    );
                                  }
                                  await remindersProvider
                                      .markShownToday(reminder.id);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF6B46C1),
                                ),
                                child: const Text('Done'),
                              ),
                              // Dismiss button
                              TextButton(
                                onPressed: () async {
                                  await remindersProvider
                                      .dismissReminder(reminder.id);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[600],
                                ),
                                child: const Text('Dismiss'),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
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
            // Habits list with StreamBuilder
            Expanded(
              child: StreamBuilder<List<Habit>>(
                stream: habitService.getHabitsStream(userId),
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // Error state
                  if (snapshot.hasError) {
                    return Center(
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
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {});
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
                    );
                  }
                  
                  // Success state
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No habits yet. Add one!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    );
                  }
                  
                  final habits = snapshot.data!;
                  
                  return ListView.builder(
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
                          _deleteHabit(habit.id);
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
                                  onTap: () => _toggleHabit(habit.id, habits),
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
                  if (result != null && result is Map<String, dynamic>) {
                    try {
                      await habitService.createHabit(
                        title: result['name'] as String,
                        description: '',
                        userId: userId,
                        emoji: result['emoji'] as String,
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create habit: $e'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
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
          onTap: (index) async {
            setState(() {
              _selectedIndex = index;
            });
            // Navigate to screens when tapping bottom nav items
            if (index == 0) {
              // Get habits from StreamBuilder for reminders
              final habitsStream = habitService.getHabitsStream(userId);
              final habitsSnapshot = await habitsStream.first;
              if (mounted) {
                Navigator.pushNamed(
                  context,
                  '/reminders',
                  arguments: habitsSnapshot
                      .map(
                        (habit) => {
                          'id': habit.id,
                          'name': habit.name,
                          'emoji': habit.emoji,
                        },
                      )
                      .toList(),
                );
              }
            } else if (index == 1) {
              Navigator.pushNamed(context, '/statistics');
            } else if (index == 2) {
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
      },
    );
  }
}

