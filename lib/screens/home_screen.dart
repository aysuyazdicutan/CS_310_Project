import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/reminder.dart';
import '../services/habit_service.dart';
import '../providers/auth_provider.dart';
import '../providers/reminders_provider.dart';
import '../providers/habit_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_paddings.dart';
import '../constants/app_dimensions.dart';
import 'habit_detail_screen.dart';
import 'streak_calendar_screen.dart';
import 'reminders_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

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

  Future<void> _deleteHabit(String id) async {
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
      final authProvider = context.read<AuthProvider>();
      final remindersProvider = context.read<RemindersProvider>();
      final userId = authProvider.user?.uid;
      if (userId != null) {
        remindersProvider.loadFromStorage(userId).then((_) {
          // Check reminders immediately after loading
          _checkReminders();
          // Then check every minute
          _reminderCheckTimer = Timer.periodic(
            const Duration(minutes: 1),
            (_) => _checkReminders(),
          );
        });
      }
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

    final timeString =
        '${reminder.timeOfDay.hour.toString().padLeft(2, '0')}:${reminder.timeOfDay.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppPaddings.paddingXLarge),
              topRight: Radius.circular(AppPaddings.paddingXLarge),
            ),
          ),
          padding: AppPaddings.paddingAllXLarge,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: AppPaddings.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(AppPaddings.radiusXSmall),
                  ),
                ),
                Text(
                  reminder.habitEmoji,
                  style: TextStyle(fontSize: AppDimensions.iconXLarge),
                ),
                SizedBox(height: AppPaddings.paddingMedium),
                Text(
                  'Time for ${reminder.habitTitle}',
                  style: AppTextStyles.titleLarge,
                ),
                SizedBox(height: AppPaddings.paddingXSmall),
                Text(
                  timeString,
                  style: AppTextStyles.bodyLarge,
                ),
                SizedBox(height: AppPaddings.paddingXLarge),
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
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: Colors.white,
                      padding: AppPaddings.buttonPaddingVertical,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppPaddings.borderRadiusMedium,
                      ),
                    ),
                    child: Text(
                      'Mark Done',
                      style: AppTextStyles.buttonLarge,
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
                      foregroundColor: AppColors.buttonPrimary,
                      side: BorderSide(color: AppColors.buttonPrimary),
                      padding: AppPaddings.buttonPaddingVertical,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppPaddings.borderRadiusMedium,
                      ),
                    ),
                    child: Text(
                      'Snooze 10 min',
                      style: AppTextStyles.buttonLarge,
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
                    child: Text(
                      'Dismiss',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: AppColors.textPrimary,
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

  Widget _buildHomeContent(String userId) {
    final habitService = HabitService();
    return Scaffold(
      body: SafeArea(
      child: Column(
        children: [
          // Top area
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppPaddings.paddingLarge,
              vertical: AppPaddings.paddingMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: Text(
                    'PROFILE',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Text(
                  _todayDate,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Keep the chain alive',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
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
                margin: EdgeInsets.symmetric(
                  horizontal: AppPaddings.paddingLarge,
                  vertical: AppPaddings.paddingXSmall,
                ),
                padding: AppPaddings.paddingAllMedium,
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: AppPaddings.borderRadiusMedium,
                  border: Border.all(
                    color: Colors.orange[200]!,
                    width: AppPaddings.borderWidthThin,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missed Today',
                      style: AppTextStyles.titleMedium,
                    ),
                    SizedBox(height: AppPaddings.paddingSmall),
                    ...missedReminders.map((reminder) {
                      final timeString =
                          '${reminder.timeOfDay.hour.toString().padLeft(2, '0')}:${reminder.timeOfDay.minute.toString().padLeft(2, '0')}';
                      return Container(
                        margin: EdgeInsets.only(bottom: AppPaddings.paddingXSmall),
                        padding: AppPaddings.paddingAllSmall,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackgroundLight,
                          borderRadius: AppPaddings.borderRadiusSmall,
                        ),
                        child: Row(
                          children: [
                            Text(
                              reminder.habitEmoji,
                              style: TextStyle(fontSize: AppDimensions.iconMedium),
                            ),
                            SizedBox(width: AppPaddings.paddingSmall),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reminder.habitTitle,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  Text(
                                    timeString,
                                    style: AppTextStyles.labelMedium.copyWith(
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
                                foregroundColor: AppColors.buttonPrimary,
                              ),
                              child: Text('Done'),
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
                              child: Text('Dismiss'),
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
            padding: AppPaddings.paddingAllLarge,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your habits',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
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
                      padding: AppPaddings.paddingAllLarge,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: AppDimensions.iconXLarge,
                            color: Colors.red,
                          ),
                          SizedBox(height: AppPaddings.paddingMedium),
                          Text(
                            'Error loading habits',
                            style: AppTextStyles.titleMedium,
                          ),
                          SizedBox(height: AppPaddings.paddingXSmall),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: AppPaddings.paddingMedium),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Success state
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No habits yet. Add one!',
                      style: AppTextStyles.bodyLarge,
                    ),
                  );
                }
                
                final habits = snapshot.data!;
                
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: AppPaddings.paddingLarge),
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
                        padding: EdgeInsets.only(right: AppPaddings.paddingLarge),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: AppPaddings.borderRadiusMedium,
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: AppDimensions.iconMedium,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Delete Habit'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    habit.emoji,
                                    style: TextStyle(fontSize: AppDimensions.iconXLarge),
                                  ),
                                  SizedBox(height: AppPaddings.paddingMedium),
                                  Text(
                                    'Are you sure you want to delete "${habit.name}"?',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                  SizedBox(height: AppPaddings.paddingXSmall),
                                  Text(
                                    'This action cannot be undone.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                        return confirmed ?? false;
                      },
                      onDismissed: (direction) {
                        _deleteHabit(habit.id);
                      },
                      child: GestureDetector(
                        onTap: () => _navigateToHabitDetail(habit),
                        child: Container(
                          margin: EdgeInsets.only(bottom: AppPaddings.paddingSmall),
                          padding: AppPaddings.paddingAllMedium,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackgroundLight,
                            borderRadius: AppPaddings.borderRadiusMedium,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(13),
                                blurRadius: AppPaddings.shadowBlurMedium,
                                offset: AppPaddings.shadowOffsetSmall,
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
                                        ? AppColors.primary
                                        : Colors.grey[200],
                                    border: Border.all(
                                      color: isCompleted
                                          ? AppColors.primary
                                          : Colors.grey[400]!,
                                      width: AppPaddings.borderWidthMedium,
                                    ),
                                  ),
                                  child: isCompleted
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: AppDimensions.iconMedium,
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
                                      style: TextStyle(fontSize: AppDimensions.iconMedium),
                                    ),
                                    SizedBox(width: AppPaddings.paddingSmall),
                                    Expanded(
                                      child: Text(
                                        habit.name,
                                        style: AppTextStyles.bodyMedium.copyWith(
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
                                  Text(
                                    '🔥',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(width: AppPaddings.paddingXSmall),
                                  Text(
                                    '${habit.streak}D',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
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
          Text(
            'Swipe left to delete',
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppPaddings.paddingXSmall),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppPaddings.paddingMedium),
            child: FloatingActionButton(
              onPressed: () async {
                final habitService = HabitService();
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
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
          SizedBox(height: AppPaddings.paddingXSmall),
        ],
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    final user = authProvider.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }
    
    final userId = user.uid;

    // List of screens for IndexedStack
    final List<Widget> screens = [
      _buildHomeContent(userId),
      const RemindersScreen(),
      const StatisticsScreen(),
      const StreakCalendarScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: AppPaddings.shadowBlurLarge,
              offset: AppPaddings.shadowOffsetSmall,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey[600],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
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

