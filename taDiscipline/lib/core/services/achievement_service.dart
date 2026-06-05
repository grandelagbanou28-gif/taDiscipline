import 'package:flutter/foundation.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';
import 'package:ta_discipline/data/repositories/achievement_repository.dart';
import 'package:ta_discipline/data/repositories/goal_repository.dart';
import 'package:ta_discipline/data/repositories/habit_repository.dart';
import 'package:ta_discipline/data/repositories/journal_repository.dart';
import 'package:ta_discipline/data/repositories/pomodoro_repository.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';
import 'package:ta_discipline/core/services/notification_service.dart';

class AchievementService {
  final AchievementRepository _achievementRepo = AchievementRepository();
  final GoalRepository _goalRepo = GoalRepository();
  final HabitRepository _habitRepo = HabitRepository();
  final JournalRepository _journalRepo = JournalRepository();
  final PomodoroRepository _pomodoroRepo = PomodoroRepository();

  Future<List<Achievement>> getAchievements() async {
    final userId = AppSupabase.currentUser?.id;
    if (userId == null) return [];
    return _achievementRepo.getAchievements(userId);
  }

  Future<void> checkAndUnlock() async {
    final userId = AppSupabase.currentUser?.id;
    if (userId == null) return;

    final unlocked = await _achievementRepo.getUnlockedBadges(userId);

    await _checkFirstGoal(userId, unlocked);
    await _checkStreaks(userId, unlocked);
    await _checkTenGoals(userId, unlocked);
    await _checkPomodoroMaster(userId, unlocked);
    await _checkJournaling(userId, unlocked);
  }

  Future<void> _checkFirstGoal(
    String userId,
    Set<BadgeType> unlocked,
  ) async {
    if (unlocked.contains(BadgeType.firstGoal)) return;
    final count = await _goalRepo.getGoalsCount(userId);
    if (count >= 1) {
      await _unlock(userId, BadgeType.firstGoal);
    }
  }

  Future<void> _checkStreaks(
    String userId,
    Set<BadgeType> unlocked,
  ) async {
    final habits = await _habitRepo.getHabits(userId);
    int maxStreak = 0;
    for (final habit in habits) {
      final streak = await _habitRepo.getCurrentStreak(habit.id);
      if (streak > maxStreak) maxStreak = streak;
    }

    if (maxStreak >= 100 && !unlocked.contains(BadgeType.hundredDayStreak)) {
      await _unlock(userId, BadgeType.hundredDayStreak);
    } else if (maxStreak >= 30 && !unlocked.contains(BadgeType.thirtyDayStreak)) {
      await _unlock(userId, BadgeType.thirtyDayStreak);
    } else if (maxStreak >= 7 && !unlocked.contains(BadgeType.sevenDayStreak)) {
      await _unlock(userId, BadgeType.sevenDayStreak);
    }
  }

  Future<void> _checkTenGoals(
    String userId,
    Set<BadgeType> unlocked,
  ) async {
    if (unlocked.contains(BadgeType.tenGoals)) return;
    final count = await _goalRepo.getGoalsCount(userId);
    if (count >= 10) {
      await _unlock(userId, BadgeType.tenGoals);
    }
  }

  Future<void> _checkPomodoroMaster(
    String userId,
    Set<BadgeType> unlocked,
  ) async {
    if (unlocked.contains(BadgeType.pomodoroMaster)) return;
    final count = await _pomodoroRepo.getTotalMinutesToday(userId);
    if (count >= 600) {
      await _unlock(userId, BadgeType.pomodoroMaster);
    }
  }

  Future<void> _checkJournaling(
    String userId,
    Set<BadgeType> unlocked,
  ) async {
    if (unlocked.contains(BadgeType.journaling)) return;
    final entries = await _journalRepo.getEntries(userId, limit: 100);
    if (entries.length >= 30) {
      await _unlock(userId, BadgeType.journaling);
    }
  }

  Future<void> _unlock(String userId, BadgeType badge) async {
    try {
      await _achievementRepo.unlockAchievement(userId, badge);
      await NotificationService().showNotification(
        title: '🏆 Badge débloqué !',
        body: 'Tu as obtenu le badge "${badge.label}"',
      );
      debugPrint('🏆 Badge débloqué : ${badge.label}');
    } catch (e) {
      debugPrint('Erreur déblocage badge: $e');
    }
  }
}
