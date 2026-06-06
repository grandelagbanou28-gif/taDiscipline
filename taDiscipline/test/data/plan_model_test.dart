import 'package:flutter_test/flutter_test.dart';
import 'package:apex/data/models/plan.dart';

void main() {
  group('Plan model', () {
    test('toJson / fromJson round-trip', () {
      final plan = Plan(
        id: 'plan-1',
        userId: 'user-1',
        weekStart: DateTime(2024, 6, 3),
        title: 'Semaine chargée',
        createdAt: DateTime(2024, 6, 1),
      );
      final json = plan.toJson();
      final restored = Plan.fromJson(json);
      expect(restored.title, plan.title);
      expect(restored.weekStart, plan.weekStart);
    });

    test('copyWith preserve userId', () {
      final plan = Plan(
        id: 'p1',
        userId: 'u1',
        weekStart: DateTime(2024, 6, 3),
        createdAt: DateTime(2024, 6, 1),
      );
      final modified = plan.copyWith(title: 'Nouveau plan');
      expect(modified.title, 'Nouveau plan');
      expect(modified.userId, 'u1');
    });
  });

  group('PlanTask model', () {
    test('toJson / fromJson round-trip', () {
      final task = PlanTask(
        id: 'pt-1',
        planId: 'plan-1',
        title: 'Réunion équipe',
        date: DateTime(2024, 6, 5),
        completed: false,
        timeSlot: 3,
        createdAt: DateTime(2024, 6, 1),
      );
      final json = task.toJson();
      final restored = PlanTask.fromJson(json);
      expect(restored.title, task.title);
      expect(restored.date, task.date);
      expect(restored.timeSlot, 3);
      expect(restored.completed, false);
    });

    test('copyWith toggle completed', () {
      final task = PlanTask(
        id: 'pt-2',
        planId: 'plan-1',
        title: 'Sport',
        date: DateTime(2024, 6, 5),
        completed: false,
        createdAt: DateTime(2024, 6, 1),
      );
      final toggled = task.copyWith(completed: true);
      expect(toggled.completed, isTrue);
      expect(toggled.title, 'Sport');
    });
  });
}
