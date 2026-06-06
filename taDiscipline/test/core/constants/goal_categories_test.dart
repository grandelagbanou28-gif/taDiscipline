import 'package:flutter_test/flutter_test.dart';
import 'package:apex/core/constants/goal_categories.dart';

void main() {
  group('GoalCategory', () {
    test('toutes les catégories ont un label non vide', () {
      for (final cat in GoalCategory.values) {
        expect(cat.label, isNotEmpty);
        expect(cat.displayName, contains(cat.emoji));
      }
    });

    test('health est bien défini', () {
      expect(GoalCategory.health.label, 'santé');
    });
  });

  group('HabitFrequency', () {
    test('daily a le bon hint', () {
      expect(HabitFrequency.daily.hint, 'Tous les jours');
    });
  });

  group('Mood', () {
    test('good a la valeur 4', () {
      expect(Mood.good.value, 4);
    });

    test('les valeurs sont uniques', () {
      final values = Mood.values.map((m) => m.value).toSet();
      expect(values.length, Mood.values.length);
    });
  });

  group('GoalStatus', () {
    test('completed a le bon label', () {
      expect(GoalStatus.completed.label, 'Atteint');
    });
  });

  group('BadgeType', () {
    test('tous les badges ont un label', () {
      for (final badge in BadgeType.values) {
        expect(badge.label, isNotEmpty);
        expect(badge.icon, isNotEmpty);
      }
    });
  });
}
