import 'package:intl/intl.dart';

class DateUtils {
  static String formatTaskDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    final difference = taskDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference < 7) {
      return DateFormat('EEEE').format(date); // Day name
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  static bool isOverdue(DateTime date) {
    if (date.isBefore(DateTime.now())) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDate = DateTime(date.year, date.month, date.day);
      return taskDate.isBefore(today);
    }
    return false;
  }

  static DateTime computeNextDue(
    DateTime current,
    String frequency,
    int interval,
  ) {
    switch (frequency) {
      case 'Daily':
        return current.add(Duration(days: 1 * interval));
      case 'Weekly':
        return current.add(Duration(days: 7 * interval));
      case 'Bi-weekly':
        return current.add(Duration(days: 14 * interval));
      case 'Monthly':
        // Handle month rollover correctly
        var year = current.year;
        var month = current.month + interval;
        while (month > 12) {
          year++;
          month -= 12;
        }

        // Handle end of month (e.g. Jan 31 -> Feb 28/29)
        final daysInMonth = DateTime(year, month + 1, 0).day;
        final day = current.day > daysInMonth ? daysInMonth : current.day;

        return DateTime(year, month, day, current.hour, current.minute);
      default:
        return current;
    }
  }
}
