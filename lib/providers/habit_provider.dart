import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService = HabitService();

  /// Get the habit service (for StreamBuilder/FutureBuilder access)
  HabitService get habitService => _habitService;

  /// Create: Add a new habit
  Future<bool> createHabit({
    required String title,
    String description = '',
    required String userId,
    String emoji = '✨',
  }) async {
    try {
      await _habitService.createHabit(
        title: title,
        description: description,
        userId: userId,
        emoji: emoji,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Read: Get a single habit by ID
  Future<Habit?> getHabit(String habitId) async {
    try {
      return await _habitService.getHabit(habitId);
    } catch (e) {
      return null;
    }
  }

  /// Update: Update an existing habit
  Future<bool> updateHabit({
    required String habitId,
    String? title,
    String? description,
    bool? isCompleted,
    String? emoji,
    int? streak,
    int? bestStreak,
    Map<String, bool>? completionHistory,
  }) async {
    try {
      await _habitService.updateHabit(
        habitId: habitId,
        title: title,
        description: description,
        isCompleted: isCompleted,
        emoji: emoji,
        streak: streak,
        bestStreak: bestStreak,
        completionHistory: completionHistory,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete: Remove a habit
  Future<bool> deleteHabit(String habitId) async {
    try {
      await _habitService.deleteHabit(habitId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
