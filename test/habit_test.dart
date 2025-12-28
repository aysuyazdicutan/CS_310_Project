import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpetua/models/habit.dart';

void main() {
  group('Habit Model Tests', () {
    test('Habit should be created with default values', () {
      final habit = Habit(
        id: 'test-id',
        title: 'Test Habit',
        createdBy: 'user123',
        createdAt: Timestamp.now(),
      );

      expect(habit.id, 'test-id');
      expect(habit.title, 'Test Habit');
      expect(habit.description, '');
      expect(habit.isCompleted, false);
      expect(habit.createdBy, 'user123');
      expect(habit.emoji, '✨');
      expect(habit.streak, 0);
      expect(habit.bestStreak, 0);
      expect(habit.completionHistory, isEmpty);
    });

    test('Habit.toFirestore should convert to Firestore format', () {
      final timestamp = Timestamp.now();
      final completionHistory = {
        '2024-01-01': true,
        '2024-01-02': true,
      };

      final habit = Habit(
        id: 'test-id-3',
        title: 'ToFirestore Test',
        description: 'Test Desc',
        isCompleted: true,
        createdBy: 'user999',
        createdAt: timestamp,
        emoji: '🎯',
        streak: 2,
        bestStreak: 5,
        completionHistory: completionHistory,
      );

      final firestoreData = habit.toFirestore();

      expect(firestoreData['title'], 'ToFirestore Test');
      expect(firestoreData['description'], 'Test Desc');
      expect(firestoreData['isCompleted'], true);
      expect(firestoreData['createdBy'], 'user999');
      expect(firestoreData['createdAt'], timestamp);
      expect(firestoreData['emoji'], '🎯');
      expect(firestoreData['streak'], 2);
      expect(firestoreData['bestStreak'], 5);
      expect(firestoreData['completionHistory'], completionHistory);
    });
  });
}

