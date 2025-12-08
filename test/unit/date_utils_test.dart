import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/utils/date_utils.dart' as app_date_utils;

void main() {
  group('DateUtils.computeNextDue', () {
    test('Daily frequency adds 1 day', () {
      final current = DateTime(2023, 1, 1, 10, 0);
      final next = app_date_utils.DateUtils.computeNextDue(current, 'Daily', 1);
      expect(next, DateTime(2023, 1, 2, 10, 0));
    });

    test('Weekly frequency adds 7 days', () {
      final current = DateTime(2023, 1, 1, 10, 0);
      final next = app_date_utils.DateUtils.computeNextDue(
        current,
        'Weekly',
        1,
      );
      expect(next, DateTime(2023, 1, 8, 10, 0));
    });

    test('Bi-weekly frequency adds 14 days', () {
      final current = DateTime(2023, 1, 1, 10, 0);
      final next = app_date_utils.DateUtils.computeNextDue(
        current,
        'Bi-weekly',
        1,
      );
      expect(next, DateTime(2023, 1, 15, 10, 0));
    });

    test('Monthly frequency adds 1 month (standard)', () {
      final current = DateTime(2023, 1, 1, 10, 0);
      final next = app_date_utils.DateUtils.computeNextDue(
        current,
        'Monthly',
        1,
      );
      expect(next, DateTime(2023, 2, 1, 10, 0));
    });

    test('Monthly frequency handles year rollover', () {
      final current = DateTime(2023, 12, 1, 10, 0);
      final next = app_date_utils.DateUtils.computeNextDue(
        current,
        'Monthly',
        1,
      );
      expect(next, DateTime(2024, 1, 1, 10, 0));
    });

    test(
      'Monthly frequency handles end of month overflow (Jan 31 -> Feb 28)',
      () {
        final current = DateTime(2023, 1, 31, 10, 0);
        final next = app_date_utils.DateUtils.computeNextDue(
          current,
          'Monthly',
          1,
        );
        expect(next, DateTime(2023, 2, 28, 10, 0));
      },
    );

    test(
      'Monthly frequency handles leap year (Jan 31 2024 -> Feb 29 2024)',
      () {
        final current = DateTime(2024, 1, 31, 10, 0);
        final next = app_date_utils.DateUtils.computeNextDue(
          current,
          'Monthly',
          1,
        );
        expect(next, DateTime(2024, 2, 29, 10, 0));
      },
    );

    test('Custom interval (Every 2 days)', () {
      final current = DateTime(2023, 1, 1, 10, 0);
      final next = app_date_utils.DateUtils.computeNextDue(current, 'Daily', 2);
      expect(next, DateTime(2023, 1, 3, 10, 0));
    });
  });
}
