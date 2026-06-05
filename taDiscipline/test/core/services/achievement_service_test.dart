import 'package:flutter_test/flutter_test.dart';
import 'package:ta_discipline/core/services/achievement_service.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';

void main() {
  group('AchievementService', () {
    test('BadgeType labels sont corrects', () {
      expect(BadgeType.firstGoal.label, 'Premier objectif');
      expect(BadgeType.sevenDayStreak.label, '7 jours');
      expect(BadgeType.thirtyDayStreak.label, '30 jours');
      expect(BadgeType.hundredDayStreak.label, '100 jours');
      expect(BadgeType.tenGoals.label, 'Dix objectifs');
      expect(BadgeType.pomodoroMaster.label, 'Maître Pomodoro');
      expect(BadgeType.journaling.label, 'Journalier');
    });
  });
}
