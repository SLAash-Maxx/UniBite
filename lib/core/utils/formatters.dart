import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _currency = NumberFormat.currency(
    locale: 'en_LK',
    symbol: 'LKR ',
    decimalDigits: 2,
  );

  static final _date = DateFormat('MMM d, yyyy');
  static final _time = DateFormat('h:mm a');
  static final _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  static String formatPrice(double amount) => _currency.format(amount);

  static String formatPriceShort(double amount) {
    if (amount == amount.truncate()) {
      return 'LKR ${amount.toInt()}';
    }
    return _currency.format(amount);
  }

  static String formatDate(DateTime date) => _date.format(date);

  static String formatTime(DateTime time) => _time.format(time);

  static String formatDateTime(DateTime dt) => _dateTime.format(dt);

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  static String toTitleCase(String s) {
    return s
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  static String formatRating(double rating) => rating.toStringAsFixed(1);

  static String formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}
