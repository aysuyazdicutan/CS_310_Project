import 'package:flutter/foundation.dart';

import '../models/habit.dart';

/// Simple global state holder for habits.
/// Firestore access should be handled in the existing service layer;
/// this provider only exposes app-wide state and notifies listeners.
class HabitProvider extends ChangeNotifier {
  final List<Habit> _habits = [];

  List<Habit> get habits => List.unmodifiable(_habits);

  // Additional methods can be added later to sync with Firestore services.
}


