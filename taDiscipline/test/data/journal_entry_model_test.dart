import 'package:flutter_test/flutter_test.dart';
import 'package:ta_discipline/data/models/journal_entry.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';

void main() {
  group('PomodoroSession', () {
    test('toJson / fromJson round-trip', () {
      final session = PomodoroSession(
        id: 'p-1',
        userId: 'u-1',
        durationMinutes: 25,
        completedAt: DateTime(2024, 6, 5, 10, 30),
        taskId: 'task-1',
        createdAt: DateTime(2024, 6, 5, 10, 0),
      );
      final json = session.toJson();
      final restored = PomodoroSession.fromJson(json);
      expect(restored.id, session.id);
      expect(restored.durationMinutes, 25);
      expect(restored.completedAt, DateTime(2024, 6, 5, 10, 30));
    });

    test('fromJson gère completedAt null', () {
      final json = {
        'id': 'p-2',
        'user_id': 'u-1',
        'duration': 25,
        'completed_at': null,
        'task_id': null,
        'created_at': '2024-06-05T10:00:00.000',
      };
      final restored = PomodoroSession.fromJson(json);
      expect(restored.completedAt, isNull);
      expect(restored.taskId, isNull);
    });

    test('fromJson gère duration manquant', () {
      final json = {
        'id': 'p-3',
        'user_id': 'u-1',
        'created_at': '2024-06-05T10:00:00.000',
      };
      final restored = PomodoroSession.fromJson(json);
      expect(restored.durationMinutes, 25);
    });
  });

  group('ChatMessage', () {
    test('toJson / fromJson round-trip', () {
      final msg = ChatMessage(
        id: 'm-1',
        userId: 'u-1',
        role: 'assistant',
        content: 'Bonjour !',
        createdAt: DateTime(2024, 6, 5),
      );
      final json = msg.toJson();
      final restored = ChatMessage.fromJson(json);
      expect(restored.role, 'assistant');
      expect(restored.content, 'Bonjour !');
    });

    test('fromJson valeurs par défaut', () {
      final json = {
        'id': 'm-2',
        'user_id': 'u-1',
        'content': 'Hello',
        'created_at': '2024-06-05T10:00:00.000',
      };
      final restored = ChatMessage.fromJson(json);
      expect(restored.role, 'user');
    });
  });

  group('Achievement', () {
    test('toJson / fromJson round-trip', () {
      final achievement = Achievement(
        id: 'a-1',
        userId: 'u-1',
        badge: BadgeType.sevenDayStreak,
        unlockedAt: DateTime(2024, 6, 5),
      );
      final json = achievement.toJson();
      final restored = Achievement.fromJson(json);
      expect(restored.badge, BadgeType.sevenDayStreak);
      expect(restored.badge.label, '7 jours');
    });

    test('fromJson badge inconnu = firstGoal', () {
      final json = {
        'id': 'a-2',
        'user_id': 'u-1',
        'badge_id': 'unknown_badge',
        'unlocked_at': '2024-06-05T10:00:00.000',
      };
      final restored = Achievement.fromJson(json);
      expect(restored.badge, BadgeType.firstGoal);
    });
  });

  group('UserSettings', () {
    test('toJson / fromJson round-trip', () {
      final settings = UserSettings(
        id: 's-1',
        userId: 'u-1',
        theme: 'dark',
        notificationsEnabled: true,
        lockTimeoutMinutes: 5,
        language: 'fr',
      );
      final json = settings.toJson();
      final restored = UserSettings.fromJson(json);
      expect(restored.theme, 'dark');
      expect(restored.lockTimeoutMinutes, 5);
    });

    test('copyWith préserve les champs non modifiés', () {
      final settings = UserSettings(
        id: 's-1',
        userId: 'u-1',
        theme: 'dark',
      );
      final mod = settings.copyWith(notificationsEnabled: false);
      expect(mod.notificationsEnabled, false);
      expect(mod.theme, 'dark');
      expect(mod.lockTimeoutMinutes, 2);
    });
  });
}
