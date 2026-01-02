import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habit_service.dart';
import '../providers/auth_provider.dart';
import '../models/habit.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  int _calculateBestStreak(Map<String, dynamic> completionHistory) {
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

  Map<String, dynamic> _calculateStats(List<Map> habits) {
    double adherence = 0;
    int longestStreak = 0;
    List<double> weeklyData = List<double>.filled(7, 0);
    
    if (habits.isEmpty) {
      return {
        'adherence': adherence,
        'longestStreak': longestStreak,
        'weeklyData': weeklyData,
      };
    }

    final now = DateTime.now();
    final totalHabits = habits.length;
    int longest = 0;
    
    final last7Days = <String>[];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      last7Days.add(dateKey);
    }
    
    final last30Days = <String>[];
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      last30Days.add(dateKey);
    }
    
    final weeklyStreakCount = List<double>.filled(7, 0);
    int totalCompletedDays = 0;

    for (final habit in habits) {
      final completionHistory = (habit['completionHistory'] as Map<String, dynamic>?) ?? {};
      
      // Calculate best streak dynamically from completion history
      final calculatedBestStreak = _calculateBestStreak(completionHistory);
      
      if (calculatedBestStreak > longest) {
        longest = calculatedBestStreak;
      }
      
      final last30DaysCompleted = completionHistory.entries
          .where((e) => last30Days.contains(e.key) && e.value == true)
          .length;
      totalCompletedDays += last30DaysCompleted;

      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        if (completionHistory[dateKey] == true) {
          final weekday = date.weekday;
          final chartIndex = (weekday - 1) % 7;
          weeklyStreakCount[chartIndex] += 1;
        }
      }
    }

    adherence = totalHabits > 0
        ? ((totalCompletedDays / (totalHabits * 30)) * 100).clamp(0, 100).toDouble()
        : 0.0;
    
    weeklyData = weeklyStreakCount;
    longestStreak = longest;

    return {
      'adherence': adherence,
      'longestStreak': longestStreak,
      'weeklyData': weeklyData,
    };
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
            
            // Convert habits to map format for _calculateStats
            final habits = snapshot.data ?? [];
            final habitMaps = habits.map((habit) {
              return {
                'id': habit.id,
                'name': habit.name,
                'emoji': habit.emoji,
                'streak': habit.streak,
                'bestStreak': habit.bestStreak,
                'completionHistory': habit.completionHistory,
              };
            }).toList();
            
            final stats = _calculateStats(habitMaps);
            
            return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Statistics',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stat Cards Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  // Adherence Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: _whiteCardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Adherence',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${stats['adherence'].toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B46C1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '(30d avg)',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF6B6B6B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Longest Streak Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: _whiteCardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Longest Streak',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${stats['longestStreak']} days',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B46C1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'All habits',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF6B6B6B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Weekly Chart Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: _whiteCardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This Week',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Bar Chart
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            (stats['weeklyData'] as List<double>).length,
                            (index) => _buildBar(
                              _dayLabels[index],
                              (stats['weeklyData'] as List<double>)[index],
                              (stats['weeklyData'] as List<double>),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
            );
          },
        );
  }

  Widget _buildBar(String label, double value, List<double> weeklyData) {
    // Value is the count of habits that have streak covering this day
    // Normalize to height: find max value first, then scale
    final maxValue = weeklyData.isEmpty 
        ? 1.0 
        : weeklyData.reduce((a, b) => a > b ? a : b);
    const maxHeight = 120.0;
    final barHeight = maxValue > 0 
        ? (value / maxValue) * maxHeight 
        : 0.0;
    const minBarHeight = 8.0; // Minimum visible height

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: barHeight < minBarHeight && value > 0 ? minBarHeight : barHeight,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFADD8E6),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}

const _whiteCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ],
);

