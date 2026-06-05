import 'package:intl/intl.dart';

class DateFormats {
  DateFormats._();

  static final DateFormat fullDate = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
  static final DateFormat shortDate = DateFormat('dd/MM/yyyy', 'fr_FR');
  static final DateFormat dayMonth = DateFormat('d MMM', 'fr_FR');
  static final DateFormat monthYear = DateFormat('MMMM yyyy', 'fr_FR');
  static final DateFormat weekDay = DateFormat('EEEE', 'fr_FR');
  static final DateFormat hourMinute = DateFormat('HH:mm', 'fr_FR');
  static final DateFormat iso = DateFormat('yyyy-MM-dd', 'fr_FR');
  static final DateFormat isoDateTime = DateFormat(
    "yyyy-MM-dd'T'HH:mm:ss'Z'",
    'fr_FR',
  );

  static String relative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'à l\'instant';
    if (difference.inMinutes < 60) return 'il y a ${difference.inMinutes}min';
    if (difference.inHours < 24) return 'il y a ${difference.inHours}h';
    if (difference.inDays == 1) return 'hier';
    if (difference.inDays < 7) return 'il y a ${difference.inDays} jours';
    return dayMonth.format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return endOfDay(date.add(Duration(days: 7 - weekday)));
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    final first = startOfMonth(date);
    final last = endOfMonth(date);
    final days = <DateTime>[];
    var current = first;
    while (!current.isAfter(last)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  static String timeAgoFrench(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365} ans';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} mois';
    return relative(date);
  }
}
