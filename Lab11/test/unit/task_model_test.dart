import 'package:flutter_test/flutter_test.dart';
import 'package:lab11/models/task.dart';

void main() {
  // Nhóm các bài unit test dành cho Task Model
  group('Task Model Unit Tests', () {

    // Test 1: Kiểm tra giá trị khởi tạo mặc định của thuộc tính isCompleted
    test('Giá trị isCompleted mặc định phải là false khi khởi tạo Task', () {
      // Arrange (Chuẩn bị dữ liệu)
      final task = Task(id: '1', title: 'Học Flutter Test');

      // Act & Assert (Thực thi và kiểm tra kết quả)
      expect(task.isCompleted, isFalse);
    });

    // Test 2: Kiểm tra hàm toggle() chuyển đổi trạng thái giữa true và false
    test('Hàm toggle() phải chuyển đổi isCompleted từ false -> true và ngược lại', () {
      // AAA Pattern: Arrange -> Act -> Assert

      // Arrange: Tạo task với isCompleted = false
      final task = Task(id: '1', title: 'Làm bài tập Lab 11');
      expect(task.isCompleted, isFalse); // Đảm bảo ban đầu là false

      // Act 1: Gọi hàm toggle lần đầu
      task.toggle();

      // Assert 1: Kiểm tra xem isCompleted đã đổi thành true chưa
      expect(task.isCompleted, isTrue);

      // Act 2: Gọi hàm toggle lần thứ hai
      task.toggle();

      // Assert 2: Kiểm tra xem isCompleted đã quay về false chưa
      expect(task.isCompleted, isFalse);
    });
  });
}