import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _daySlots = [22, 23, 24, 25, 26, 27, 28];

  bool _hasLoadedData = false;
  double _adherence = 0;
  int _longestStreak = 0;
  List<double> _weeklyData = List<double>.filled(7, 0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedData) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List) {
      final habitMaps = args.whereType<Map>().toList();
      _calculateStats(habitMaps);
    }
    _hasLoadedData = true;
  }

  void _calculateStats(List<Map> habits) {
    if (habits.isEmpty) {
      setState(() {
        _adherence = 0;
        _longestStreak = 0;
        _weeklyData = List<double>.filled(7, 0);
      });
      return;
    }

    final totalHabits = habits.length;
    double totalStreak = 0;
    int longest = 0;
    // For weekly chart: count how many habits have streak covering each of the last 7 days
    // If a habit has streak 5, it means the last 5 days are completed
    // So for days 1-5 (today back to 5 days ago), this habit counts
    final weeklyStreakCount = List<double>.filled(7, 0);

    for (final habit in habits) {
      final streak = (habit['streak'] as num?)?.toInt() ?? 0;
      totalStreak += streak;
      
      // Longest streak is the maximum streak value from all habits
      if (streak > longest) {
        longest = streak;
      }

      // For weekly chart: if streak is N, it means last N days are completed
      // Chart shows: Mon, Tue, Wed, Thu, Fri, Sat, Sun
      // If today is Sunday and streak is 5, then Wed-Sun are completed
      // We need to map: today (index 6) = Sun, yesterday (index 5) = Sat, etc.
      // For each day in the week (0=Mon, 6=Sun), check if it's within the streak
      // If streak is 5, days 2-6 (Wed-Sun) should be marked
      for (var chartDayIndex = 0; chartDayIndex < 7; chartDayIndex++) {
        // chartDayIndex: 0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun
        // We assume today is Sunday (index 6)
        // Days from today backwards: 6=Sun, 5=Sat, 4=Fri, 3=Thu, 2=Wed, 1=Tue, 0=Mon
        // If streak is N, it covers days: 6, 5, 4, ..., (7-N+1)
        // So day is covered if: (6 - chartDayIndex + 1) <= streak
        // Which simplifies to: chartDayIndex >= (7 - streak)
        final daysFromToday = 6 - chartDayIndex; // 6 for Mon, 0 for Sun
        final dayNumber = daysFromToday + 1; // 1-based: 7 for Mon, 1 for Sun
        if (streak >= dayNumber) {
          weeklyStreakCount[chartDayIndex] += 1;
        }
      }
    }

    // Adherence: average streak / 30 days * 100
    final adherencePercent =
        (((totalStreak / totalHabits) / 30) * 100).clamp(0, 100).toDouble();
    
    // Weekly data: normalize to percentage or show as count
    // Show as total streak count per day (not percentage)
    final weeklyData = weeklyStreakCount.map((count) => count).toList();

    setState(() {
      _adherence = adherencePercent;
      _longestStreak = longest;
      _weeklyData = weeklyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF6B46C1),
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                  const SizedBox(width: 48), // Balance the back button
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
                            '${_adherence.toStringAsFixed(0)}%',
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
                            '$_longestStreak days',
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
                            _weeklyData.length,
                            (index) => _buildBar(
                              _dayLabels[index],
                              _weeklyData[index],
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
            // Share Button
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: _whiteCardDecoration.copyWith(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.send,
                      color: Color(0xFF6B46C1),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double value) {
    // Value is the count of habits that have streak covering this day
    // Normalize to height: find max value first, then scale
    final maxValue = _weeklyData.isEmpty 
        ? 1.0 
        : _weeklyData.reduce((a, b) => a > b ? a : b);
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

