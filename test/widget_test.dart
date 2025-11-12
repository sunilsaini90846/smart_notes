// This is a basic Flutter widget test for the Notes Manager app.

import 'package:flutter_test/flutter_test.dart';
import 'package:notes_manager/main.dart';

void main() {
  testWidgets('Notes app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NotesApp());

    // Verify that the app launches with the home screen
    expect(find.text('My Notes'), findsOneWidget);
  });
}
