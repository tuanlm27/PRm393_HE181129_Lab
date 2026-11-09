import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab8b/main.dart';

void main() {
  testWidgets('Weather app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Thời tiết'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}