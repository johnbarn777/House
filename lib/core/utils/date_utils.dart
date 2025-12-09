class DateUtils {
  static DateTime computeNextDue(
    DateTime currentDue,
    String frequency,
    int interval,
  ) {
    // Ensure we are working with just the date part if needed,
    // but for now we'll respect the time component as well.

    switch (frequency) {
      case 'Daily':
        return currentDue.add(Duration(days: interval));
      case 'Weekly':
        return currentDue.add(Duration(days: 7 * interval));
      case 'Bi-weekly':
        return currentDue.add(Duration(days: 14 * interval));
      case 'Monthly':
        // Handle month overflow logic
        // e.g., Jan 31 + 1 month -> Feb 28 (or 29)
        int newMonth = currentDue.month + interval;
        int newYear = currentDue.year;

        while (newMonth > 12) {
          newMonth -= 12;
          newYear++;
        }

        // Determine the day. If the current day is 31, and new month has 30, use 30.
        int newDay = currentDue.day;
        int daysInNewMonth = _getDaysInMonth(newYear, newMonth);
        if (newDay > daysInNewMonth) {
          newDay = daysInNewMonth;
        }

        return DateTime(
          newYear,
          newMonth,
          newDay,
          currentDue.hour,
          currentDue.minute,
          currentDue.second,
          currentDue.millisecond,
          currentDue.microsecond,
        );
      default:
        // Default to daily if unknown
        return currentDue.add(Duration(days: interval));
    }
  }

  static int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
        return 29;
      }
      return 28;
    }
    const daysInMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month];
  }
}
