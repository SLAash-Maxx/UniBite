import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _currency = NumberFormat.currency(
    locale: 'en_LK', symbol: 'LKR ', decimalDigits: 2,
  );

  static final _date     = DateFormat('MMM d, yyyy');
  static final _time     = DateFormat('h:mm a');
  static final _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  /// e.g. LKR 350.00
  static String formatPrice(double amount) => _currency.format(amount);

  /// e.g. LKR 350 (no decimals for whole numbers)
  static String formatPriceShort(double amount) {
    if (amount == amount.truncate()) {
      return 'LKR ${amount.toInt()}';
    }
    return _currency.format(amount);
  }

  /// e.g. Jan 5, 2025
  static String formatDate(DateTime date) => _date.format(date);

  /// e.g. 9:30 AM
  static String formatTime(DateTime time) => _time.format(time);

  /// e.g. Jan 5, 2025 • 9:30 AM
  static String formatDateTime(DateTime dt) => _dateTime.format(dt);

  /// e.g. "2 hours ago", "Just now"
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    if (diff.inDays < 7)      return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  /// Capitalize first letter of each word
  static String toTitleCase(String s) {
    return s.split(' ').map((w) =>
      w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
    ).join(' ');
  }

  /// e.g. 4.8 → "4.8"
  static String formatRating(double rating) => rating.toStringAsFixed(1);

  /// e.g. 1200 → "1.2k"
  static String formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}
