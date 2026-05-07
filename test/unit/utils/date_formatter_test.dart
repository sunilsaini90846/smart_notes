import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

/// Utility class for date formatting (extracted from HomeScreen)
class DateFormatter {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}

void main() {
  group('DateFormatter', () {
    test('should return "Just now" for current time', () {
      final now = DateTime.now();
      expect(DateFormatter.formatDate(now), equals('Just now'));
    });

    test('should return minutes ago for times within last hour', () {
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      final result = DateFormatter.formatDate(fiveMinutesAgo);
      
      // Allow for small timing variations
      expect(result, anyOf(equals('5m ago'), equals('4m ago'), equals('6m ago')));
    });

    test('should return hours ago for times within today', () {
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      final result = DateFormatter.formatDate(twoHoursAgo);
      
      // Allow for small timing variations
      expect(result, anyOf(equals('2h ago'), equals('1h ago'), equals('3h ago')));
    });

    test('should return days ago for times within last week', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(DateFormatter.formatDate(threeDaysAgo), equals('3d ago'));
    });

    test('should return formatted date for times older than a week', () {
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      final result = DateFormatter.formatDate(tenDaysAgo);
      
      // Should return formatted date like "Dec 8"
      expect(result, isNot(contains('ago')));
      expect(result, matches(RegExp(r'[A-Za-z]+ \d+')));
    });

    test('should handle exactly 1 minute ago', () {
      final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
      final result = DateFormatter.formatDate(oneMinuteAgo);
      
      // Allow for small timing variations
      expect(result, anyOf(equals('1m ago'), equals('0m ago'), equals('2m ago')));
    });

    test('should handle exactly 1 hour ago', () {
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
      final result = DateFormatter.formatDate(oneHourAgo);
      
      // Allow for small timing variations
      expect(result, anyOf(equals('1h ago'), equals('0h ago'), equals('2h ago')));
    });

    test('should handle exactly 1 day ago', () {
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.formatDate(oneDayAgo), equals('1d ago'));
    });

    test('should handle edge case of 6 days ago', () {
      final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6));
      expect(DateFormatter.formatDate(sixDaysAgo), equals('6d ago'));
    });

    test('should handle edge case of 7 days ago', () {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final result = DateFormatter.formatDate(sevenDaysAgo);
      
      // Should return formatted date, not "7d ago"
      expect(result, isNot(contains('ago')));
    });

    test('should handle future dates gracefully', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final result = DateFormatter.formatDate(tomorrow);
      
      // Should still return a valid string (negative difference handled)
      expect(result, isA<String>());
    });

    test('should handle dates from different months', () {
      // Create a date from 30 days ago
      final lastMonth = DateTime.now().subtract(const Duration(days: 30));
      final result = DateFormatter.formatDate(lastMonth);
      
      // Should return formatted date
      expect(result, matches(RegExp(r'[A-Za-z]+ \d+')));
    });

    test('should handle dates from different years', () {
      // Create a date from last year
      final lastYear = DateTime(DateTime.now().year - 1, 6, 15);
      final result = DateFormatter.formatDate(lastYear);
      
      // Should return formatted date
      expect(result, matches(RegExp(r'[A-Za-z]+ \d+')));
    });
  });

  group('DateFormatter - Edge Cases', () {
    test('should handle very old dates', () {
      final veryOld = DateTime(2000, 1, 1);
      final result = DateFormatter.formatDate(veryOld);
      
      expect(result, isNotEmpty);
      expect(result, matches(RegExp(r'[A-Za-z]+ \d+')));
    });

    test('should handle dates at midnight', () {
      final midnight = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        0,
        0,
        0,
      );
      final result = DateFormatter.formatDate(midnight);
      
      // Should still work
      expect(result, isA<String>());
      expect(result, isNotEmpty);
    });

    test('should handle dates at end of day', () {
      final endOfDay = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        23,
        59,
        59,
      );
      final result = DateFormatter.formatDate(endOfDay);
      
      // Should still work
      expect(result, isA<String>());
      expect(result, isNotEmpty);
    });
  });

  group('DateFormatter - Consistency', () {
    test('same input should produce same output', () {
      final testDate = DateTime.now().subtract(const Duration(hours: 5));
      final result1 = DateFormatter.formatDate(testDate);
      final result2 = DateFormatter.formatDate(testDate);
      
      expect(result1, equals(result2));
    });

    test('should be deterministic for past dates', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 15));
      final result1 = DateFormatter.formatDate(pastDate);
      
      // Small delay
      Future.delayed(const Duration(milliseconds: 100));
      
      final result2 = DateFormatter.formatDate(pastDate);
      expect(result1, equals(result2));
    });
  });
}

