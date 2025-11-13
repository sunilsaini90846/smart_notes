// This is a basic Flutter widget test for the Account Note Book app.

import 'package:flutter_test/flutter_test.dart';
import 'package:account_note_book/main.dart';

void main() {
  testWidgets('Account Note Book app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NotesApp());

    // Verify that the app launches with the home screen
    expect(find.text('My Notes'), findsOneWidget);
  });
}
