import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService = HabitService();
  StreamSubscription<List<Habit>>? _habitsSubscription;

  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Habit> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize and start listening to habits for a user
  void initialize(String userId) {
    _setLoading(true);
    _clearError();

    // Cancel existing subscription if any
    _habitsSubscription?.cancel();

    // Listen to real-time updates from Firestore
    _habitsSubscription = _habitService.getHabitsStream(userId).listen(
      (habits) {
        _habits = habits;
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
        _setLoading(false);
        notifyListeners();
      },
    );
  }

  /// Create: Add a new habit
  Future<bool> createHabit({
    required String title,
    String description = '',
    required String userId,
    String emoji = '✨',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _habitService.createHabit(
        title: title,
        description: description,
        userId: userId,
        emoji: emoji,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Read: Get a single habit by ID
  Future<Habit?> getHabit(String habitId) async {
    _setLoading(true);
    _clearError();

    try {
      final habit = await _habitService.getHabit(habitId);
      _setLoading(false);
      return habit;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
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
    _setLoading(true);
    _clearError();

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
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete: Remove a habit
  Future<bool> deleteHabit(String habitId) async {
    _setLoading(true);
    _clearError();

    try {
      await _habitService.deleteHabit(habitId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _habitsSubscription?.cancel();
    super.dispose();
  }
}
