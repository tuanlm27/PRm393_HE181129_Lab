import 'package:flutter_test/flutter_test.dart';

// Giả định TaskRepository quản lý danh sách công việc
class TaskRepository {
  final List<dynamic> _tasks = [];

  List<dynamic> get tasks => List.unmodifiable(_tasks);

  void addTask(dynamic task) {
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

class MockTask {
  String id;
  String title;
  MockTask({required this.id, required this.title});
}

void main() {
  group('TaskRepository Unit Tests (Sử dụng AAA Pattern)', () {
    late TaskRepository repository;

    // Hàm setUp chạy trước mỗi bài test để khởi tạo lại repository sạch
    setUp(() {
      repository = TaskRepository();
    });

    // Test kiểm tra tính năng addTask()
    test('addTask() phải thêm một task mới vào repository', () {
      // Arrange: Khởi tạo dữ liệu đầu vào
      final task = MockTask(id: '1', title: 'Mua sữa');

      // Act: Gọi phương thức cần test
      repository.addTask(task);

      // Assert: Xác nhận kết quả
      expect(repository.tasks.length, equals(1));
      expect(repository.tasks.first.title, equals('Mua sữa'));
    });

    // Test kiểm tra tính năng deleteTask()
    test('deleteTask() phải xóa task tương ứng theo ID', () {
      // Arrange: Tạo và thêm sẵn task vào repository
      final task = MockTask(id: '1', title: 'Đi tập gym');
      repository.addTask(task);
      expect(repository.tasks.length, equals(1));

      // Act: Thực hiện xóa task
      repository.deleteTask('1');

      // Assert: Đảm bảo danh sách đã rỗng
      expect(repository.tasks.isEmpty, isTrue);
    });

    // Test kiểm tra tính năng updateTask()
    test('updateTask() phải cập nhật tiêu đề của task theo ID', () {
      // Arrange: Thêm task ban đầu
      final task = MockTask(id: '1', title: 'Tên cũ');
      repository.addTask(task);

      // Act: Gọi hàm cập nhật tiêu đề
      repository.updateTask('1', 'Tên mới đã cập nhật');

      // Assert: Kiểm tra tiêu đề mới
      expect(repository.tasks.first.title, equals('Tên mới đã cập nhật'));
    });
  });
}