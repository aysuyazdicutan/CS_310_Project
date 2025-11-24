import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String name;
  final int streak;
  final bool isCompleted;

  Habit({
    required this.id,
    required this.name,
    required this.streak,
    this.isCompleted = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Habit> _habits = [
    Habit(id: '1', name: 'Morning Exercise', streak: 5),
    Habit(id: '2', name: 'Read 30 Minutes', streak: 3),
    Habit(id: '3', name: 'Meditation', streak: 7),
    Habit(id: '4', name: 'Drink Water', streak: 2),
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
      _habits[index] = Habit(
        id: habit.id,
        name: habit.name,
        streak: habit.isCompleted ? habit.streak : habit.streak + 1,
        isCompleted: !habit.isCompleted,
      );
    });
  }

  void _deleteHabit(String id) {
    setState(() {
      _habits.removeWhere((habit) => habit.id == id);
    });
  }

  void _navigateToHabitDetail(Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFE6F2FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: Text(
              'Habit Detail: ${habit.name}',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
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
                        streak: 0,
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
                                  // Habit name
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

