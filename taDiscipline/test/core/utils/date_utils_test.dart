import 'package:flutter_test/flutter_test.dart';
import 'package:ta_discipline/core/utils/date_utils.dart';

void main() {
  group('DateUtils - AppDateUtils', () {
    test('formatDate affiche format français', () {
      final date = DateTime(2024, 6, 5);
      final formatted = AppDateUtils.formatDate(date);
      expect(formatted, contains('juin'));
      expect(formatted, contains('2024'));
    });

    test('relativeDate aujourd\'hui', () {
      final today = DateTime.now();
      expect(AppDateUtils.relativeDate(today), 'Aujourd\'hui');
    });

    test('relativeDate hier', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(AppDateUtils.relativeDate(yesterday), 'Hier');
    });

    test('relativeDate semaine passée', () {
      final lastWeek = DateTime.now().subtract(const Duration(days: 5));
      final result = AppDateUtils.relativeDate(lastWeek);
      expect(result, isNot('Aujourd\'hui'));
      expect(result, isNot('Hier'));
    });

    test('isSameDay true pour même jour', () {
      final d1 = DateTime(2024, 6, 5, 10, 0);
      final d2 = DateTime(2024, 6, 5, 22, 30);
      expect(AppDateUtils.isSameDay(d1, d2), isTrue);
    });

    test('isSameDay false pour jours différents', () {
      final d1 = DateTime(2024, 6, 5);
      final d2 = DateTime(2024, 6, 6);
      expect(AppDateUtils.isSameDay(d1, d2), isFalse);
    });

    test('startOfWeek retourne lundi', () {
      final wednesday = DateTime(2024, 6, 5); // mercredi
      final monday = AppDateUtils.startOfWeek(wednesday);
      expect(monday.weekday, DateTime.monday);
      expect(monday.day, 3);
    });

    test('daysBetween compte correctement', () {
      final start = DateTime(2024, 6, 1);
      final end = DateTime(2024, 6, 10);
      expect(AppDateUtils.daysBetween(start, end), 9);
    });
  });
}
