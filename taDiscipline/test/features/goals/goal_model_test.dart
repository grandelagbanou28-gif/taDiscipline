import 'package:flutter_test/flutter_test.dart';
import 'package:ta_discipline/data/models/goal.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';

void main() {
  group('Goal model', () {
    test('toJson / fromJson round-trip', () {
      final goal = Goal(
        id: 'test-id',
        userId: 'user-1',
        title: 'Courir un marathon',
        description: 'Se préparer pour Paris 2025',
        category: GoalCategory.health,
        deadline: DateTime(2025, 12, 31),
        progress: 50.0,
        status: GoalStatus.inProgress,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final json = goal.toJson();
      final restored = Goal.fromJson(json);

      expect(restored.id, goal.id);
      expect(restored.title, goal.title);
      expect(restored.description, goal.description);
      expect(restored.category, goal.category);
      expect(restored.progress, goal.progress);
      expect(restored.status, goal.status);
    });

    test('copyWith preserves fields', () {
      final goal = Goal(
        id: 'id',
        userId: 'uid',
        title: 'Original',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final modified = goal.copyWith(title: 'Modifié', progress: 75.0);
      expect(modified.title, 'Modifié');
      expect(modified.progress, 75.0);
      expect(modified.id, goal.id);
      expect(modified.userId, goal.userId);
    });
  });

  group('SubTask model', () {
    test('toJson / fromJson round-trip', () {
      final task = SubTask(
        id: 'task-1',
        goalId: 'goal-1',
        title: 'Acheter des baskets',
        completed: false,
        order: 1,
      );
      final json = task.toJson();
      final restored = SubTask.fromJson(json);
      expect(restored.title, task.title);
      expect(restored.completed, task.completed);
      expect(restored.order, task.order);
    });

    test('copyWith toggle completed', () {
      final task = SubTask(
        id: 't1',
        goalId: 'g1',
        title: 'Test',
        completed: false,
      );
      expect(task.copyWith(completed: true).completed, isTrue);
    });
  });
}
