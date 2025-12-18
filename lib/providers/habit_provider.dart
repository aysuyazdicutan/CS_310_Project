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
    // Cancel existing subscription if any
    _habitsSubscription?.cancel();

    _setLoading(true);
    _clearError();

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
      cancelOnError: false, // Keep listening even if there's an error
    );
  }

  /// Create: Add a new habit
  Future<bool> createHabit({
    required String title,
    String description = '',
    required String userId,
    String emoji = '✨',
  }) async {
    _clearError();

    try {
      // Ensure stream is initialized before creating habit
      if (_habitsSubscription == null) {
        initialize(userId);
        // Wait a bit for stream to be ready
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      await _habitService.createHabit(
        title: title,
        description: description,
        userId: userId,
        emoji: emoji,
      );
      // Don't set loading state here - the stream will automatically update
      // when the new habit is added to Firestore
      return true;
    } catch (e) {
      _setError(e.toString());
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
      // Don't set loading state here - the stream will automatically update
      // when the habit is updated in Firestore
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Delete: Remove a habit
  Future<bool> deleteHabit(String habitId) async {
    _clearError();

    try {
      await _habitService.deleteHabit(habitId);
      // Don't set loading state here - the stream will automatically update
      // when the habit is deleted from Firestore
      return true;
    } catch (e) {
      _setError(e.toString());
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
