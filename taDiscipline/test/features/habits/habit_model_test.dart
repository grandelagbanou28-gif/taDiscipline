import 'package:flutter_test/flutter_test.dart';
import 'package:ta_discipline/data/models/habit.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';

void main() {
  group('Habit model', () {
    test('toJson / fromJson round-trip', () {
      final habit = Habit(
        id: 'habit-1',
        userId: 'user-1',
        name: 'Méditer',
        description: '10 min le matin',
        frequency: HabitFrequency.daily,
        target: 1,
        color: '#7C3AED',
        icon: '🧘',
        isPositive: true,
        createdAt: DateTime(2024, 1, 1),
      );
      final json = habit.toJson();
      final restored = Habit.fromJson(json);
      expect(restored.name, habit.name);
      expect(restored.frequency, habit.frequency);
      expect(restored.target, habit.target);
      expect(restored.isPositive, habit.isPositive);
    });
  });

  group('HabitLog model', () {
    test('toJson / fromJson round-trip', () {
      final log = HabitLog(
        id: 'log-1',
        habitId: 'habit-1',
        date: DateTime(2024, 6, 5),
        completed: true,
        value: 1.0,
      );
      final json = log.toJson();
      final restored = HabitLog.fromJson(json);
      expect(restored.completed, isTrue);
      expect(restored.date, DateTime(2024, 6, 5));
    });
  });
}
