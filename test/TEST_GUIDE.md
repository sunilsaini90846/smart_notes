# Testing Guide for Account Note Book

This guide explains the testing infrastructure and best practices for the Account Note Book app.

## 📁 Test Structure

```
test/
├── helpers/
│   ├── test_helpers.dart       # Reusable test utilities
│   └── mock_data.dart          # Mock note data for testing
├── mocks/
│   └── mock_note_repository.dart  # Mock repository implementation
├── widget/
│   └── screens/
│       └── home_screen_test.dart  # HomeScreen widget tests
├── unit/
│   ├── models/
│   │   └── note_model_test.dart   # NoteModel unit tests
│   └── utils/
│       └── date_formatter_test.dart  # Utility function tests
├── integration/
│   └── home_screen_flow_test.dart   # Integration tests
├── widget_test.dart            # Basic widget test
└── TEST_GUIDE.md              # This file
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run All Tests

```bash
# Run all tests
flutter test

# Run with verbose output
flutter test --verbose

# Run specific test file
flutter test test/widget/screens/home_screen_test.dart

# Run tests with coverage
flutter test --coverage
```

### 3. View Coverage Report

```bash
# Generate HTML coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open in browser (macOS)
open coverage/html/index.html

# Open in browser (Linux)
xdg-open coverage/html/index.html
```

## 📝 Test Types

### 1. Unit Tests

Test individual functions and classes in isolation.

**Location:** `test/unit/`

**Example:**
```dart
test('should format date correctly', () {
  final date = DateTime.now();
  final formatted = DateFormatter.formatDate(date);
  expect(formatted, equals('Just now'));
});
```

**What to test:**
- Business logic
- Data models
- Utility functions
- Service methods

### 2. Widget Tests

Test UI components and user interactions.

**Location:** `test/widget/`

**Example:**
```dart
testWidgets('should display app title', (tester) async {
  await tester.pumpWidget(HomeScreen());
  expect(find.text('My Notes'), findsOneWidget);
});
```

**What to test:**
- Widget rendering
- User interactions (taps, swipes)
- UI state changes
- Navigation flows

### 3. Integration Tests

Test complete user flows and feature interactions.

**Location:** `test/integration/`

**Example:**
```dart
testWidgets('complete search and filter flow', (tester) async {
  // Test multiple steps working together
  await openSearch();
  await enterSearchQuery('test');
  await applyFilter('Account');
  await verifyResults();
});
```

**What to test:**
- End-to-end user journeys
- Multiple features working together
- Complex state interactions

## 🛠️ Test Helpers

### Test Helpers (`test_helpers.dart`)

Provides reusable utilities for testing:

```dart
// Wrap widget in MaterialApp for testing
await pumpTestWidget(tester, MyWidget());

// Find widgets easily
findText('My Text');
findByKey('my_key');
findByType<MyWidget>();

// Verify widget existence
verifyExists(find.text('Hello'));
verifyNotExists(find.text('Goodbye'));
verifyMultiple(find.byType(ListTile), 5);
```

### Mock Data (`mock_data.dart`)

Create test notes easily:

```dart
// Create a plain note
final note = MockNoteData.createPlainNote();

// Create an account note with sub-accounts
final account = MockNoteData.createAccountNote(
  withSubAccounts: true,
);

// Create multiple notes
final notes = MockNoteData.createMixedNotes();
```

### Mock Repository (`mock_note_repository.dart`)

Test without Hive database:

```dart
final mockRepo = MockNoteRepository();
mockRepo.setMockNotes([note1, note2, note3]);

// Test repository methods
final allNotes = mockRepo.getAllNotes();
final searchResults = mockRepo.searchNotes('test');
```

## ✅ Best Practices

### DO:

✅ **Write descriptive test names**
```dart
testWidgets('should display empty state when no notes exist', (tester) async {
  // Test implementation
});
```

✅ **Group related tests**
```dart
group('HomeScreen - Search Functionality', () {
  testWidgets('test 1', (tester) async { });
  testWidgets('test 2', (tester) async { });
});
```

✅ **Use arrange-act-assert pattern**
```dart
testWidgets('example test', (tester) async {
  // Arrange: Set up test data
  final widget = MyWidget();
  
  // Act: Perform actions
  await tester.pumpWidget(widget);
  await tester.tap(find.byIcon(Icons.add));
  
  // Assert: Verify results
  expect(find.text('Added'), findsOneWidget);
});
```

✅ **Test user-visible behavior, not implementation**
```dart
// Good: Tests what user sees
expect(find.text('My Notes'), findsOneWidget);

// Bad: Tests internal state
expect(widget._privateVariable, equals(5));
```

✅ **Mock external dependencies**
```dart
final mockRepo = MockNoteRepository();
// Use mockRepo instead of real repository
```

✅ **Clean up after tests**
```dart
tearDown(() {
  // Clean up resources
});
```

### DON'T:

❌ **Don't test private methods**
```dart
// Bad: Testing private method
expect(widget._formatDate(date), equals('Today'));

// Good: Extract to public utility and test that
expect(DateFormatter.formatDate(date), equals('Today'));
```

❌ **Don't use real databases/network in tests**
```dart
// Bad: Using real Hive database
await Hive.openBox('realBox');

// Good: Using mock repository
final mockRepo = MockNoteRepository();
```

❌ **Don't make tests dependent on each other**
```dart
// Bad: Tests depend on execution order
test('test 1', () => value = 5);
test('test 2', () => expect(value, equals(5))); // Depends on test 1

// Good: Each test is independent
test('test 1', () {
  final value = 5;
  expect(value, equals(5));
});
```

❌ **Don't hard-code delays**
```dart
// Bad: Hard-coded delay
await Future.delayed(Duration(seconds: 2));

// Good: Use pumpAndSettle
await tester.pumpAndSettle();
```

❌ **Don't test Flutter framework code**
```dart
// Bad: Testing Flutter's ListView
expect(find.byType(ListView), findsOneWidget);

// Good: Test your content in the list
expect(find.text('My Note'), findsOneWidget);
```

## 🎯 Coverage Goals

Aim for these coverage targets:

- **Unit Tests:** 80%+ coverage
- **Widget Tests:** 70%+ coverage
- **Critical Paths:** 100% coverage

**Critical paths include:**
- Note creation/editing
- Encryption/decryption
- Search and filter
- Data persistence

## 🔍 Running Specific Tests

### Run tests by file
```bash
flutter test test/widget/screens/home_screen_test.dart
```

### Run tests by name pattern
```bash
flutter test --name "should display"
```

### Run tests by group
```bash
flutter test --name "HomeScreen - Search"
```

### Run with real-time updates (watch mode)
```bash
# Use with entr (install via brew install entr)
find . -name "*.dart" | entr -c flutter test
```

## 🐛 Debugging Tests

### Print debug info
```dart
testWidgets('debug test', (tester) async {
  await tester.pumpWidget(MyWidget());
  
  // Print widget tree
  debugDumpApp();
  
  // Print render tree
  debugDumpRenderTree();
  
  // Print layer tree
  debugDumpLayerTree();
});
```

### Find what's on screen
```dart
// Print all text widgets
final textWidgets = find.byType(Text).evaluate();
for (var widget in textWidgets) {
  print((widget.widget as Text).data);
}
```

### Take screenshots during tests
```bash
# Run with --update-goldens to generate images
flutter test --update-goldens
```

## 📊 Test Reports

### Generate test reports
```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# View report
open coverage/html/index.html
```

### CI/CD Integration

Add to your CI pipeline:

```yaml
# Example GitHub Actions
- name: Run tests
  run: flutter test --coverage
  
- name: Upload coverage
  uses: codecov/codecov-action@v2
  with:
    file: ./coverage/lcov.info
```

## 🎓 Learning Resources

### Official Flutter Testing Docs
- [Introduction to testing](https://docs.flutter.dev/testing)
- [Widget testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration testing](https://docs.flutter.dev/testing/integration-tests)

### Best Practices
- [Testing best practices](https://docs.flutter.dev/cookbook/testing/widget/finders)
- [Mocking dependencies](https://docs.flutter.dev/cookbook/testing/unit/mocking)

## 🤝 Contributing Tests

When adding new features:

1. **Write tests first (TDD approach)**
   ```dart
   // 1. Write failing test
   testWidgets('should add new note', (tester) async {
     // Test implementation
   });
   
   // 2. Implement feature
   // 3. Make test pass
   // 4. Refactor
   ```

2. **Update existing tests if behavior changes**

3. **Add integration tests for new user flows**

4. **Maintain test coverage above 70%**

## 📝 Example Test Workflow

```bash
# 1. Write test
# Create test/widget/my_feature_test.dart

# 2. Run test (it should fail)
flutter test test/widget/my_feature_test.dart

# 3. Implement feature
# Update lib/screens/my_feature.dart

# 4. Run test again (it should pass)
flutter test test/widget/my_feature_test.dart

# 5. Check coverage
flutter test --coverage

# 6. Commit changes
git add .
git commit -m "Add my_feature with tests"
```

## 🆘 Common Issues

### Issue: "No Material widget found"
**Solution:** Wrap widget in MaterialApp
```dart
await tester.pumpWidget(MaterialApp(home: MyWidget()));
```

### Issue: "Hive box not initialized"
**Solution:** Use MockNoteRepository instead of real repository

### Issue: "Animations not completing"
**Solution:** Use `pumpAndSettle()`
```dart
await tester.pumpAndSettle();
```

### Issue: "Can't find widget"
**Solution:** Use debugDumpApp() to see what's rendered
```dart
debugDumpApp();
```

## 🎉 Quick Test Examples

### Test button tap
```dart
testWidgets('button tap test', (tester) async {
  await tester.pumpWidget(MyWidget());
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  expect(find.text('Added'), findsOneWidget);
});
```

### Test text input
```dart
testWidgets('text input test', (tester) async {
  await tester.pumpWidget(MyWidget());
  await tester.enterText(find.byType(TextField), 'Hello');
  expect(find.text('Hello'), findsOneWidget);
});
```

### Test navigation
```dart
testWidgets('navigation test', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
  expect(find.text('Second Page'), findsOneWidget);
});
```

---

**Happy Testing! 🧪**

For questions or issues, refer to the Flutter testing documentation or create an issue in the project repository.

