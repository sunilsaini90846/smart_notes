import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_note_book/utils/app_theme.dart';

/// Widget wrapper for testing that provides MaterialApp context
Widget createTestWidget(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(
      primaryColor: AppTheme.primaryColor,
      scaffoldBackgroundColor: AppTheme.backgroundColor,
    ),
    home: child,
  );
}

/// Pump widget and settle all animations.
Future<void> pumpTestWidget(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(createTestWidget(widget));
  await tester.pumpAndSettle();
}

/// Find widget by text
Finder findText(String text) => find.text(text);

/// Find widget by key
Finder findByKey(String key) => find.byKey(Key(key));

/// Find widget by type
Finder findByType<T>() => find.byType(T);

/// Verify widget exists
void verifyExists(Finder finder) {
  expect(finder, findsOneWidget);
}

/// Verify widget doesn't exist
void verifyNotExists(Finder finder) {
  expect(finder, findsNothing);
}

/// Verify multiple widgets exist
void verifyMultiple(Finder finder, int count) {
  expect(finder, findsNWidgets(count));
}

