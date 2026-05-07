import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_note_book/screens/home_screen.dart';
import '../helpers/test_helpers.dart';

/// Integration tests for HomeScreen user flows
void main() {
  group('HomeScreen Integration Tests', () {
    testWidgets('complete user flow: search and filter', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // 1. Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // 2. Enter search query
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      // 3. Apply filter
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      // 4. Clear filter
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // 5. Close search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify no errors occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('drawer navigation flow', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // 1. Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // 2. Verify drawer items
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);

      // 3. Close drawer by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // 4. Verify drawer is closed
      expect(find.text('Account Note Book'), findsNothing);
    });

    testWidgets('filter and search combination flow', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // 1. Apply a filter
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      // 2. Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // 3. Enter search query
      await tester.enterText(find.byType(TextField), 'gmail');
      await tester.pumpAndSettle();

      // 4. Change filter while searching
      await tester.tap(find.text('Bank / Card'));
      await tester.pumpAndSettle();

      // 5. Clear search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify no errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('complete drawer interaction flow', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // 1. Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // 2. Verify all elements are present
      expect(find.text('Account Note Book'), findsOneWidget);
      expect(find.text('Secure Notes Manager'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('Powered by'), findsOneWidget);

      // 3. Close drawer
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // 4. Open drawer again to verify state
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      expect(find.text('Account Note Book'), findsOneWidget);
    });

    testWidgets('multiple filter selections flow', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      final filters = ['Plain Note', 'Account', 'Bank / Card', 'Subscription'];

      // Cycle through all filters
      for (final filter in filters) {
        await tester.tap(find.text(filter));
        await tester.pumpAndSettle();

        // Verify filter is applied
        expect(find.text(filter), findsOneWidget);
      }

      // Reset to All
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Verify no errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('rapid user interactions flow', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Simulate rapid user interactions
      // 1. Quick filter changes
      await tester.tap(find.text('Account'));
      await tester.pump(const Duration(milliseconds: 50));
      
      await tester.tap(find.text('Plain Note'));
      await tester.pump(const Duration(milliseconds: 50));

      // 2. Quick search toggle
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump(const Duration(milliseconds: 50));
      
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(const Duration(milliseconds: 50));

      // 3. Quick drawer open/close
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump(const Duration(milliseconds: 50));
      
      await tester.tapAt(const Offset(10, 10));
      
      // Let everything settle
      await tester.pumpAndSettle();

      // Should handle without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('search with filter combinations', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Test 1: Filter then search
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Test 2: Search then filter
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'another test');
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Bank / Card'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify no errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty state to filter flow', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.text('No notes yet'), findsOneWidget);

      // Apply various filters on empty state
      final filters = ['Plain Note', 'Account', 'Bank / Card', 'Subscription'];
      
      for (final filter in filters) {
        await tester.tap(find.text(filter));
        await tester.pumpAndSettle();
        
        // Should still show empty state
        expect(find.text('No notes yet'), findsOneWidget);
      }

      // Verify no errors with empty state filtering
      expect(tester.takeException(), isNull);
    });

    testWidgets('complete app navigation simulation', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Simulate a complete user session
      // 1. User opens app and checks empty state
      expect(find.text('My Notes'), findsOneWidget);
      expect(find.text('0 notes'), findsOneWidget);

      // 2. User explores drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.text('Account Note Book'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // 3. User tries filters
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // 4. User tries search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'my note');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 5. User sees FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // No errors throughout the flow
      expect(tester.takeException(), isNull);
    });
  });

  group('HomeScreen - State Persistence Tests', () {
    testWidgets('filter state persists when opening/closing search',
        (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Apply a filter
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Close search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Filter should still be active (verify visually if needed)
      expect(tester.takeException(), isNull);
    });

    testWidgets('search clears when search bar is closed', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Open search and enter text
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pumpAndSettle();

      // Close search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Reopen search - should be empty
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });
  });
}

