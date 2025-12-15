import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String createdBy;
  final Timestamp createdAt;

  const Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdBy,
    required this.createdAt,
  });

  factory Habit.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    final rawTitle = data['title'];
    final rawDescription = data['description'];
    final rawIsCompleted = data['isCompleted'];
    final rawCreatedBy = data['createdBy'];
    final rawCreatedAt = data['createdAt'];

    return Habit(
      id: doc.id,
      title: rawTitle is String && rawTitle.trim().isNotEmpty
          ? rawTitle
          : 'Untitled Habit',
      description: rawDescription is String ? rawDescription : '',
      isCompleted: rawIsCompleted is bool ? rawIsCompleted : false,
      createdBy: rawCreatedBy is String ? rawCreatedBy : '',
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt : Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}


