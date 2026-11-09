import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Exercise 12.2: Pre-cache hình ảnh logo từ asset để tối ưu thời gian hiển thị
    precacheImage(const AssetImage('assets/images/app_logo.png'), context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitTask() {
    if (_textController.text.isNotEmpty) {
      context.read<TaskProvider>().addTask(_textController.text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Const widget tĩnh
        title: const Row(
          children: [
            Image(
              image: AssetImage('assets/images/app_logo.png'),
              width: 32,
              height: 32,
            ),
            SizedBox(width: 10),
            Text('Taskly - Optimized'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập công việc mới...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submitTask(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _submitTask,
                  child: const Text('Thêm'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            // Exercise 12.1: Sử dụng Selector thay vì Consumer/Watch toàn trang
            child: Selector<TaskProvider, List<Task>>(
              selector: (context, provider) => provider.tasks,
              builder: (context, tasks, child) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('Chưa có công việc nào!'),
                  );
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    // Gán ValueKey dựa trên task.id
                    return TaskTile(
                      key: ValueKey(task.id),
                      task: task,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}