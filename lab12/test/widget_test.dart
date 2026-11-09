import 'package:flutter_test/flutter_test.dart';
import 'package:lab12/main.dart';

void main() {
  testWidgets('Taskly app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that app title and initial tasks are rendered.
    expect(find.text('Taskly - Optimized'), findsOneWidget);
    expect(find.text('Học bài Performance Optimization'), findsOneWidget);
  });
}
