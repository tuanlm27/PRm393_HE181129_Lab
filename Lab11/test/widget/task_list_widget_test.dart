import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Giả lập giao diện TaskListScreen đơn giản để phục vụ Widget Test
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<String> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TaskList')),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            key: const Key('taskTextField'),
            decoration: const InputDecoration(labelText: 'Enter Task'),
          ),
          ElevatedButton(
            key: const Key('addButton'),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  _tasks.add(_controller.text);
                  _controller.clear();
                });
              }
            },
            child: const Text('Add'),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks yet. Add one!'))
                : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_tasks[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('TaskListScreen Widget Tests', () {

    // Test 1: Kiểm tra trạng thái rỗng (Empty State)
    testWidgets('Hiển thị thông báo "No tasks yet. Add one!" khi danh sách rỗng', (WidgetTester tester) async {
      // Render giao diện TaskListScreen vào môi trường test
      await tester.pumpWidget(const MaterialApp(home: TaskListScreen()));

      // Kiểm tra xem dòng chữ thông báo có xuất hiện trên màn hình không
      expect(find.text('No tasks yet. Add one!'), findsOneWidget);
    });

    // Test 2: Thêm 1 task và xác nhận giao diện cập nhật (Add Task)
    testWidgets('Nhập văn bản -> nhấn Add -> hiển thị task trên UI', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaskListScreen()));

      // Nhập nội dung "Món ăn sáng" vào ô TextField
      await tester.enterText(find.byKey(const Key('taskTextField')), 'Món ăn sáng');

      // Chạm (tap) vào nút Add
      await tester.tap(find.byKey(const Key('addButton')));

      // Cập nhật lại khung hình (frame) của UI sau khi bấm nút
      await tester.pump();

      // Kiểm tra xem task vừa thêm có xuất hiện và dòng thông báo rỗng có biến mất không
      expect(find.text('Món ăn sáng'), findsOneWidget);
      expect(find.text('No tasks yet. Add one!'), findsNothing);
    });

    // Test 3: Thêm nhiều task (Multiple Tasks)
    testWidgets('Thêm hai task -> xác nhận cả hai đều hiển thị', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaskListScreen()));

      // Thêm task 1
      await tester.enterText(find.byKey(const Key('taskTextField')), 'Task 1');
      await tester.tap(find.byKey(const Key('addButton')));
      await tester.pump();

      // Thêm task 2
      await tester.enterText(find.byKey(const Key('taskTextField')), 'Task 2');
      await tester.tap(find.byKey(const Key('addButton')));
      await tester.pump();

      // Xác nhận cả Task 1 và Task 2 đều cùng xuất hiện trên màn hình
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });
  });
}