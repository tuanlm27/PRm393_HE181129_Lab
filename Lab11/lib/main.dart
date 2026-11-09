// lib/main.dart
import 'package:flutter/material.dart';
import 'package:lab11/screens/task_list_screen.dart'; // Import màn hình danh sách task

void main() {
  runApp(const TasklyApp());
}

class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskly',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TaskListScreen(), // Màn hình chính
    );
  }
}