import 'package:flutter/foundation.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [
    const Task(id: '1', title: 'Học bài Performance Optimization'),
    const Task(id: '2', title: 'Tối ưu Rebuild Widgets với Selector'),
    const Task(id: '3', title: 'Pre-cache ảnh logo app'),
  ];

  List<Task> get tasks => List.unmodifiable(_tasks);

  void addTask(String title) {
    if (title.trim().isEmpty) return;
    _tasks.add(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
    ));
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}