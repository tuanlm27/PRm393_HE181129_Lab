import 'package:flutter/material.dart';

class TaskDetailScreen extends StatefulWidget {
  final String initialTitle;
  const TaskDetailScreen({super.key, required this.initialTitle});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              key: const Key('detailTitleField'),
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Task Title',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('saveButton'),
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
