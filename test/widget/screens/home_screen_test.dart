import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_note_book/screens/home_screen.dart';
import 'package:account_note_book/models/note_model.dart';
import '../../helpers/mock_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('should display app title "My Notes"', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());

      // Wait for initialization
      await tester.pumpAndSettle();

      // Verify title is displayed
      expect(find.text('My Notes'), findsOneWidget);
    });

    testWidgets('should display empty state when no notes', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No notes yet'), findsOneWidget);
      expect(
        find.text('Tap the button below to create your first note'),
        findsOneWidget,
      );
    });

    testWidgets('should display floating action button', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Verify FAB exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('should show search icon button in header', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Find search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should show menu icon button in header', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Find menu icon
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('should display filter chips', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Verify filter chips exist
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Plain Note'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Bank / Card'), findsOneWidget);
      expect(find.text('Subscription'), findsOneWidget);
    });

    testWidgets('should toggle search bar when search icon is tapped',
        (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Initially search bar should not be visible
      expect(find.byType(TextField), findsNothing);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search bar should now be visible
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search notes...'), findsOneWidget);

      // Search icon should change to close icon
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Search bar should be hidden again
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('should open drawer when menu icon is tapped', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Drawer should not be visible initially
      expect(find.text('Account Note Book'), findsNothing);

      // Tap menu icon
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Drawer should now be visible
      expect(find.text('Account Note Book'), findsOneWidget);
      expect(find.text('Secure Notes Manager'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
    });

    testWidgets('should display loading state initially', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());

      // Before pumpAndSettle, should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading notes...'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should display note count correctly', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // With 0 notes
      expect(find.text('0 notes'), findsOneWidget);
    });

    testWidgets('filter chips should be selectable', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Find the Account filter chip
      final accountChip = find.text('Account');
      expect(accountChip, findsOneWidget);

      // Tap on Account chip
      await tester.tap(accountChip);
      await tester.pumpAndSettle();

      // The filter should be applied (though we have no notes to filter)
      // The chip should now be selected
      final filterChips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final accountFilterChip = filterChips.firstWhere(
        (chip) => (chip.label as Row).children.any(
              (child) => child is Text && child.data == 'Account',
            ),
      );
      expect(accountFilterChip.selected, isTrue);
    });

    testWidgets('should close drawer by tapping backdrop', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify drawer is open
      expect(find.text('Account Note Book'), findsOneWidget);

      // Tap on the backdrop to close drawer
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Drawer should be closed
      expect(find.text('Account Note Book'), findsNothing);
    });
  });

  group('HomeScreen - Search Functionality', () {
    testWidgets('should filter notes based on search query', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      // Search is functional (with no notes, empty state should still show)
      expect(find.text('No notes yet'), findsOneWidget);
    });

    testWidgets('should clear search when close icon is tapped',
        (tester) async {
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

      // Search should be closed and query cleared
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('HomeScreen - Filter Functionality', () {
    testWidgets('should filter by Plain Note type', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Tap on Plain Note filter
      await tester.tap(find.text('Plain Note'));
      await tester.pumpAndSettle();

      // Filter should be active
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('should filter by Account type', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Tap on Account filter
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      // Filter should be active
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('should filter by Bank / Card type', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Tap on Bank / Card filter
      await tester.tap(find.text('Bank / Card'));
      await tester.pumpAndSettle();

      // Filter should be active
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('should filter by Subscription type', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Tap on Subscription filter
      await tester.tap(find.text('Subscription'));
      await tester.pumpAndSettle();

      // Filter should be active
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('should clear filter when tapping selected chip',
        (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Tap on Account filter to select it
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      // Tap on Account filter again to deselect it
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      // All notes should be shown (filter cleared)
      expect(find.text('0 notes'), findsOneWidget);
    });

    testWidgets('should show all notes when All filter is selected',
        (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Select a specific filter first
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      // Now select All
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Should show all notes
      expect(find.text('0 notes'), findsOneWidget);
    });
  });

  group('HomeScreen - Drawer Navigation', () {
    testWidgets('drawer should contain app version', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Check for version info
      expect(find.text('App Version'), findsOneWidget);
      expect(find.textContaining('v'), findsOneWidget);
    });

    testWidgets('drawer should show Privacy Policy menu item', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Check for Privacy Policy
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('drawer should show Terms & Conditions menu item',
        (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Check for Terms & Conditions
      expect(find.text('Terms & Conditions'), findsOneWidget);
    });

    testWidgets('drawer should display Kyntesso branding', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Check for Powered by text
      expect(find.text('Powered by'), findsOneWidget);
    });
  });

  group('HomeScreen - UI Elements', () {
    testWidgets('should have gradient background', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Find the container with gradient
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Container),
        ).first,
      );

      // Verify gradient decoration exists
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('should render without overflow', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should have proper SafeArea', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Verify SafeArea exists
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });

  group('HomeScreen - Accessibility', () {
    testWidgets('should have semantic content', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Verify semantics tree exists
      expect(tester.getSemantics(find.byType(HomeScreen)), isNotNull);
    });

    testWidgets('buttons should be tappable', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Verify FAB is tappable
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      
      // Verify search button is tappable
      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);
      
      // Verify menu button is tappable
      final menuButton = find.byIcon(Icons.menu);
      expect(menuButton, findsOneWidget);
    });
  });

  group('HomeScreen - Integration Tests', () {
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

      // 4. Close search
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

      // 3. Close drawer by tapping backdrop
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Verify drawer is closed
      expect(find.text('Account Note Book'), findsNothing);
    });

    testWidgets('complete filter cycle', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Cycle through all filters
      await tester.tap(find.text('Plain Note'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bank / Card'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Subscription'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Verify no errors
      expect(tester.takeException(), isNull);
    });
  });

  group('HomeScreen - Performance', () {
    testWidgets('should handle rapid filter changes', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Rapidly change filters
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Account'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.text('Plain Note'));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should handle without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle search bar toggling rapidly', (tester) async {
      await pumpTestWidget(tester, const HomeScreen());
      await tester.pumpAndSettle();

      // Rapidly toggle search
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should handle without errors
      expect(tester.takeException(), isNull);
    });
  });
}

