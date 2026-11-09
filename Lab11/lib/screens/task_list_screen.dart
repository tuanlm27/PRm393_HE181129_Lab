import 'package:flutter/material.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<String> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(_controller.text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TaskList')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    key: const Key('taskTextField'),
                    decoration: const InputDecoration(labelText: 'Enter Task'),
                  ),
                ),
                ElevatedButton(
                  key: const Key('addButton'),
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks yet. Add one!'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) => ListTile(
                      key: Key('taskListItem_$index'),
                      title: Text(_tasks[index]),
                      onTap: () async {
                        final updatedText = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(
                              initialTitle: _tasks[index],
                            ),
                          ),
                        );
                        if (updatedText != null && updatedText.isNotEmpty) {
                          setState(() {
                            _tasks[index] = updatedText;
                          });
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
