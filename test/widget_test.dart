// Basic smoke test for the Account Note Book app.
// For comprehensive tests, see:
// - test/widget/screens/home_screen_test.dart (Widget tests)
// - test/unit/ (Unit tests)
// - test/integration/ (Integration tests)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_note_book/main.dart';

void main() {
  group('Account Note Book - Smoke Tests', () {
    testWidgets('app launches successfully', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const NotesApp());

      // Wait for app to initialize
      await tester.pumpAndSettle();

      // Verify that the app launches with the home screen
      expect(find.text('My Notes'), findsOneWidget);
    });

    testWidgets('app has floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(const NotesApp());
      await tester.pumpAndSettle();

      // Verify FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('app displays filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(const NotesApp());
      await tester.pumpAndSettle();

      // Verify filter chips are present
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Plain Note'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('app renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const NotesApp());
      await tester.pumpAndSettle();

      // Verify no exceptions were thrown
      expect(tester.takeException(), isNull);
    });
  });
}
