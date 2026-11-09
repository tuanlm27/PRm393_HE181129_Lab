import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  // Sử dụng const constructor cho widget tĩnh
  const TaskTile({
    super.key, // Khóa Key (ValueKey) truyền từ cha vào
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) {
          // Chỉ gọi hàm không lắng nghe sự thay đổi UI toàn trang
          context.read<TaskProvider>().toggleTask(task.id);
        },
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Colors.grey : Colors.black,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          context.read<TaskProvider>().deleteTask(task.id);
        },
      ),
    );
  }
}