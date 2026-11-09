import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Màn hình chi tiết công việc (TaskDetailScreen)
class TaskDetailScreen extends StatelessWidget {
  final String initialTitle;
  const TaskDetailScreen({super.key, required this.initialTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          key: const Key('detailTitleField'),
          controller: TextEditingController(text: initialTitle),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Điều hướng từ Task List sang Task Detail và xác nhận UI', (WidgetTester tester) async {
    // 1. Khởi tạo ứng dụng với màn hình chính chứa 1 task đã được seeded
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ListTile(
                key: const Key('seededTaskItem'),
                title: const Text('Task seeded sẵn'),
                onTap: () {
                  // Chuyển màn hình khi bấm vào Task
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskDetailScreen(initialTitle: 'Task seeded sẵn'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    // 2. Chạm vào task có sẵn
    await tester.tap(find.byKey(const Key('seededTaskItem')));

    // 3. Đợi tất cả chuyển cảnh/hiệu ứng điều hướng (Navigation) hoàn tất
    await tester.pumpAndSettle();

    // 4. Validate kết quả ở màn hình mới
    // Kiểm tra tiêu đề AppBar có đúng là "Task Detail"
    expect(find.text('Task Detail'), findsOneWidget);

    // Kiểm tra xem TextField với key 'detailTitleField' có xuất hiện hay không
    expect(find.byKey(const Key('detailTitleField')), findsOneWidget);
  });
}