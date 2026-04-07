import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tp2/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Basic test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(title: 'Test'),
      ),
    );
  });
}