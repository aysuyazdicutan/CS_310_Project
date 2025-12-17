import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String createdBy;
  final Timestamp createdAt;
  
  // App-specific fields
  final String emoji;
  final int streak;
  final int bestStreak;
  final Map<String, bool> completionHistory; // date string -> completed

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdBy,
    required this.createdAt,
    this.emoji = '✨',
    this.streak = 0,
    this.bestStreak = 0,
    Map<String, bool>? completionHistory,
  }) : completionHistory = completionHistory ?? {};

  factory Habit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    final rawTitle = data['title'];
    final rawDescription = data['description'];
    final rawIsCompleted = data['isCompleted'];
    final rawCreatedBy = data['createdBy'];
    final rawCreatedAt = data['createdAt'];
    final rawEmoji = data['emoji'];
    final rawStreak = data['streak'];
    final rawBestStreak = data['bestStreak'];
    final rawCompletionHistory = data['completionHistory'];

    // Parse completionHistory
    Map<String, bool> parsedHistory = {};
    if (rawCompletionHistory is Map) {
      rawCompletionHistory.forEach((key, value) {
        if (key is String && value is bool) {
          parsedHistory[key] = value;
        }
      });
    }

    return Habit(
      id: doc.id,
      title: rawTitle is String && rawTitle.trim().isNotEmpty
          ? rawTitle
          : 'Untitled Habit',
      description: rawDescription is String ? rawDescription : '',
      isCompleted: rawIsCompleted is bool ? rawIsCompleted : false,
      createdBy: rawCreatedBy is String ? rawCreatedBy : '',
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt : Timestamp.now(),
      emoji: rawEmoji is String && rawEmoji.isNotEmpty ? rawEmoji : '✨',
      streak: rawStreak is int ? rawStreak : (rawStreak is num ? rawStreak.toInt() : 0),
      bestStreak: rawBestStreak is int ? rawBestStreak : (rawBestStreak is num ? rawBestStreak.toInt() : 0),
      completionHistory: parsedHistory,
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'emoji': emoji,
      'streak': streak,
      'bestStreak': bestStreak,
      'completionHistory': completionHistory,
    };
  }
  
  // Convenience getter for name (alias for title)
  String get name => title;
}


