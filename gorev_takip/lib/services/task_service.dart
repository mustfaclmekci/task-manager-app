import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _taskCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    await _taskCollection.add(task.toMap());
  }

  Stream<List<Task>> getTasks() {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return _taskCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Burası eksik olan kısım: getTasksOnce()
  Future<List<Task>> getTasksOnce() async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await _taskCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('dueDate')
        .get();
    return snapshot.docs.map((doc) {
      return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> updateTaskCompletion(String id, bool isCompleted) async {
    await _taskCollection.doc(id).update({'isCompleted': isCompleted});
  }

  Future<void> deleteTask(String id) async {
    await _taskCollection.doc(id).delete();
  }
}
