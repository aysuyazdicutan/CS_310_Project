import 'package:flutter/material.dart';

class HabitEditScreen extends StatefulWidget {
  final String habitName;
  final String habitEmoji;
  final Map<int, bool> completionHistory;

  const HabitEditScreen({
    super.key,
    required this.habitName,
    required this.habitEmoji,
    required this.completionHistory,
  });

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  late Map<int, bool> _completionHistory;

  @override
  void initState() {
    super.initState();
    _completionHistory = Map<int, bool>.from(widget.completionHistory);
  }

  void _toggleDay(int dayNumber) {
    setState(() {
      _completionHistory[dayNumber] = !(_completionHistory[dayNumber] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FA),
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

