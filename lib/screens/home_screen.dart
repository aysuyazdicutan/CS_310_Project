import 'package:flutter/material.dart';
import 'habit_detail_screen.dart';
import 'streak_calendar_screen.dart';

class Habit {
  final String id;
  final String name;
  final String emoji;
  final int streak;
  final int bestStreak;
  final bool isCompleted;
  final Map<int, bool> completionHistory; // day number -> completed

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.streak,
    this.bestStreak = 0,
    this.isCompleted = false,
    Map<int, bool>? completionHistory,
  }) : completionHistory = completionHistory ?? {};
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Habit> _habits = [
    Habit(
      id: '1',
      name: 'Morning Exercise',
      emoji: '💪',
      streak: 5,
      bestStreak: 10,
      completionHistory: Map.fromIterable(
        List.generate(28, (i) => i + 1),
        key: (day) => day,
        value: (day) => day <= 5, // First 5 days completed
      ),
    ),
    Habit(
      id: '2',
      name: 'Read 30 Minutes',
      emoji: '📚',
      streak: 3,
      bestStreak: 8,
      completionHistory: Map.fromIterable(
        List.generate(28, (i) => i + 1),
        key: (day) => day,
        value: (day) => day <= 3, // First 3 days completed
      ),
    ),
    Habit(
      id: '3',
      name: 'Meditation',
      emoji: '🧘',
      streak: 7,
      bestStreak: 15,
      completionHistory: Map.fromIterable(
        List.generate(28, (i) => i + 1),
        key: (day) => day,
        value: (day) => day <= 7, // First 7 days completed
      ),
    ),
    Habit(
      id: '4',
      name: 'Drink Water',
      emoji: '💧',
      streak: 27,
      bestStreak: 35,
      completionHistory: Map.fromIterable(
        List.generate(28, (i) => i + 1),
        key: (day) => day,
        value: (day) => true, // All 28 days completed (like in the image)
      ),
    ),
  ];

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

  void _toggleHabit(String id) {
    setState(() {
      final habit = _habits.firstWhere((h) => h.id == id);
      final index = _habits.indexOf(habit);
      final newCompletionHistory = Map<int, bool>.from(habit.completionHistory);
      final today = DateTime.now().day;
      newCompletionHistory[today] = !habit.isCompleted;
      
      final newStreak = habit.isCompleted ? habit.streak - 1 : habit.streak + 1;
      final newBestStreak = newStreak > habit.bestStreak ? newStreak : habit.bestStreak;
      
      _habits[index] = Habit(
        id: habit.id,
        name: habit.name,
        emoji: habit.emoji,
        streak: newStreak,
        bestStreak: newBestStreak,
        isCompleted: !habit.isCompleted,
        completionHistory: newCompletionHistory,
      );
    });
  }

  void _deleteHabit(String id) {
    setState(() {
      _habits.removeWhere((habit) => habit.id == id);
    });
  }

  void _navigateToHabitDetail(Habit habit) {
    // Calculate statistics
    // Last 7 days are days 22-28 in the calendar grid
    final last7DaysCompleted = habit.completionHistory.entries
        .where((e) => e.key > 21 && e.key <= 28 && e.value)
        .length;
    
    // Last 30 days - count all completed days in the history
    final last30DaysCompleted = habit.completionHistory.entries
        .where((e) => e.value)
        .length;
    
    // Total completions - sum of all completed days
    final totalCompletions = habit.completionHistory.values
        .where((v) => v)
        .length;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(
          habitName: habit.name,
          habitEmoji: habit.emoji,
          currentStreak: habit.streak,
          bestStreak: habit.bestStreak,
          completionHistory: habit.completionHistory,
          last7Days: last7DaysCompleted,
          last30Days: last30DaysCompleted,
          totalCompletions: totalCompletions,
        ),
      ),
    );
  }

  void _addNewHabit() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Add New Habit'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter habit name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _habits.add(
                      Habit(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        emoji: '✨', // Default emoji for new habits
                        streak: 0,
                        bestStreak: 0,
                        completionHistory: {},
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PROFILE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 1.2,
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
              child: _habits.isEmpty
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
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        final habit = _habits[index];
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${habit.name} deleted'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
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
                                    onTap: () => _toggleHabit(habit.id),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: habit.isCompleted
                                            ? const Color(0xFF4A90E2)
                                            : Colors.grey[200],
                                        border: Border.all(
                                          color: habit.isCompleted
                                              ? const Color(0xFF4A90E2)
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: habit.isCompleted
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
                                              decoration: habit.isCompleted
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: FloatingActionButton(
                onPressed: _addNewHabit,
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
              Navigator.pushNamed(context, '/reminders');
            } else if (index == 1) {
              Navigator.pushNamed(context, '/statistics');
            } else if (index == 2) {
              // Navigate to Streak Calendar
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreakCalendarScreen(
                    habits: _habits.map((habit) => {
                      'id': habit.id,
                      'name': habit.name,
                      'emoji': habit.emoji,
                      'completionHistory': habit.completionHistory,
                    }).toList(),
                  ),
                ),
              );
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

