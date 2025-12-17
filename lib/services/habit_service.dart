import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'habits';

  /// Get a reference to the habits collection
  CollectionReference<Map<String, dynamic>> _habitsCollection() {
    return _firestore.collection(_collectionName);
  }

  /// Get a reference to a specific habit document
  DocumentReference<Map<String, dynamic>> _habitDoc(String habitId) {
    return _habitsCollection().doc(habitId);
  }

  /// Create: Add a new habit to Firestore
  Future<String> createHabit({
    required String title,
    String description = '',
    required String userId,
    String emoji = '✨',
  }) async {
    try {
      final docRef = await _habitsCollection().add({
        'title': title,
        'description': description,
        'isCompleted': false,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'emoji': emoji,
        'streak': 0,
        'bestStreak': 0,
        'completionHistory': <String, bool>{},
      });
      return docRef.id;
    } catch (e) {
      throw 'Failed to create habit: ${e.toString()}';
    }
  }

  /// Read: Get a single habit by ID
  Future<Habit?> getHabit(String habitId) async {
    try {
      final doc = await _habitDoc(habitId).get();
      if (!doc.exists) return null;
      return Habit.fromFirestore(doc);
    } catch (e) {
      throw 'Failed to get habit: ${e.toString()}';
    }
  }

  /// Read: Get all habits for a specific user (real-time stream)
  Stream<List<Habit>> getHabitsStream(String userId) {
    return _habitsCollection()
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Habit.fromFirestore(doc))
          .toList();
    });
  }

  /// Read: Get all habits for a specific user (one-time)
  Future<List<Habit>> getHabits(String userId) async {
    try {
      final snapshot = await _habitsCollection()
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Habit.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get habits: ${e.toString()}';
    }
  }

  /// Update: Update an existing habit
  Future<void> updateHabit({
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
      final updateData = <String, dynamic>{};
      
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (isCompleted != null) updateData['isCompleted'] = isCompleted;
      if (emoji != null) updateData['emoji'] = emoji;
      if (streak != null) updateData['streak'] = streak;
      if (bestStreak != null) updateData['bestStreak'] = bestStreak;
      if (completionHistory != null) updateData['completionHistory'] = completionHistory;
      
      if (updateData.isEmpty) return;
      
      await _habitDoc(habitId).update(updateData);
    } catch (e) {
      throw 'Failed to update habit: ${e.toString()}';
    }
  }

  /// Delete: Remove a habit from Firestore
  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitDoc(habitId).delete();
    } catch (e) {
      throw 'Failed to delete habit: ${e.toString()}';
    }
  }
}

