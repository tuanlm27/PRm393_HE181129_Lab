import '../models/task.dart';

class TaskRepository {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  void addTask(Task task) {
    _tasks.add(task);
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
  }

  void updateTask(String id, String newTitle) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].title = newTitle;
    }
  }
}
