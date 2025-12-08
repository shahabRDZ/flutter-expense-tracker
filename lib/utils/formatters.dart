import 'package:intl/intl.dart';

/// A collection of pure utility functions for formatting monetary values
/// and dates throughout the app.
abstract class Formatters {
  Formatters._();

  // ── Currency ──────────────────────────────────────────────────────────────

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Format [amount] as a USD currency string, e.g. `\$1,234.56`.
  static String currency(double amount) => _currency.format(amount);

  /// Compact currency string that drops trailing zeros, e.g. `\$12`.
  static String currencyCompact(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}k';
    }
    // Remove ".00" suffix for whole numbers.
    final formatted = _currency.format(amount);
    return formatted.endsWith('.00')
        ? formatted.substring(0, formatted.length - 3)
        : formatted;
  }

  // ── Dates ─────────────────────────────────────────────────────────────────

  static final DateFormat _dateShort = DateFormat('MMM d, y');
  static final DateFormat _dateLong = DateFormat('EEEE, MMMM d, y');
  static final DateFormat _monthYear = DateFormat('MMMM y');
  static final DateFormat _time = DateFormat('h:mm a');

  /// e.g. `Mar 28, 2026`
  static String dateShort(DateTime date) => _dateShort.format(date);

  /// e.g. `Saturday, March 28, 2026`
  static String dateLong(DateTime date) => _dateLong.format(date);

  /// e.g. `March 2026`
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// e.g. `9:41 AM`
  static String time(DateTime date) => _time.format(date);

  /// Relative label: "Today", "Yesterday", or [dateShort].
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return dateShort(date);
  }

  // ── Misc ──────────────────────────────────────────────────────────────────

  /// Returns a human-readable month name for [month] (1–12).
  static String monthName(int month) =>
      DateFormat('MMMM').format(DateTime(0, month));

  /// Returns an abbreviated month name (e.g. `Jan`) for [month] (1–12).
  static String monthNameShort(int month) =>
      DateFormat('MMM').format(DateTime(0, month));
}
