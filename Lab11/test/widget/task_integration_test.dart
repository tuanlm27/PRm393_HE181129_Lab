import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mô phỏng luồng hoàn chỉnh của App
class AppFlowWidget extends StatefulWidget {
  const AppFlowWidget({super.key});

  @override
  State<AppFlowWidget> createState() => _AppFlowWidgetState();
}

class _AppFlowWidgetState extends State<AppFlowWidget> {
  String taskTitle = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Integration Test App')),
        body: Builder(
        builder: (context) => taskTitle.isEmpty
            ? Center(
          child: ElevatedButton(
            key: const Key('addInitialTaskBtn'),
            onPressed: () {
              setState(() {
                taskTitle = 'Original title';
              });
            },
            child: const Text('Add Original Task'),
          ),
        )
            : ListTile(
          key: const Key('taskListItem'),
          title: Text(taskTitle),
          onTap: () async {
            // Chuyển tới màn hình chỉnh sửa và nhận lại kết quả cập nhật
            final updatedText = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) => EditDetailScreen(currentTitle: taskTitle),
              ),
            );
            if (updatedText != null) {
              setState(() {
                taskTitle = updatedText;
              });
            }
          },
        ),
      ),
      ),
    );
  }
}

class EditDetailScreen extends StatefulWidget {
  final String currentTitle;
  const EditDetailScreen({super.key, required this.currentTitle});

  @override
  State<EditDetailScreen> createState() => _EditDetailScreenState();
}

class _EditDetailScreenState extends State<EditDetailScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Column(
        children: [
          TextField(
            key: const Key('editTitleField'),
            controller: _controller,
          ),
          ElevatedButton(
            key: const Key('saveButton'),
            onPressed: () {
              Navigator.pop(context, _controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Mô phỏng full flow: Thêm -> Mở chi tiết -> Sửa -> Lưu -> Kiểm tra UI', (WidgetTester tester) async {
    // Bắt đầu chạy App
    await tester.pumpWidget(const AppFlowWidget());

    // 1. Thêm task "Original title"
    await tester.tap(find.byKey(const Key('addInitialTaskBtn')));
    await tester.pumpAndSettle();
    expect(find.text('Original title'), findsOneWidget);

    // 2. Chạm vào task để mở màn hình Detail
    await tester.tap(find.byKey(const Key('taskListItem')));
    await tester.pumpAndSettle();

    // 3. Nhập tiêu đề mới "Updated title" vào ô chỉnh sửa
    await tester.enterText(find.byKey(const Key('editTitleField')), 'Updated title');

    // 4. Bấm nút Save
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();

    // 5. Xác nhận tiêu đề đã được cập nhật hiển thị ở danh sách chính
    expect(find.text('Updated title'), findsOneWidget);
    expect(find.text('Original title'), findsNothing);
  });
}