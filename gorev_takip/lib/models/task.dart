import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String title;
  String userId;
  String description;
  String category;
  DateTime dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.userId,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'userId': userId,
      'description': description,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'createdAt': FieldValue.serverTimestamp(), // Firestore server zamanı
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      userId: map['userId'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
