// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediflow/main.dart';

void main() {
  testWidgets('MediFlow app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClinicFlowApp());

    // Wait for initial animations to complete
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify splash screen is shown
    expect(find.byType(Scaffold), findsWidgets);
  });
}
