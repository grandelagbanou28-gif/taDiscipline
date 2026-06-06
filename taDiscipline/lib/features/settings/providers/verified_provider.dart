import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/data/repositories/goal_repository.dart';
import 'package:apex/data/repositories/habit_repository.dart';
import 'package:apex/data/repositories/achievement_repository.dart';
import 'package:apex/data/local/app_session.dart';

final verifiedProvider = FutureProvider<bool>((ref) async {
  final userId = AppSession.userId;
  if (userId == null) return false;

  final goalRepo = GoalRepository();
  final habitRepo = HabitRepository();
  final achievementRepo = AchievementRepository();

  final goals = await goalRepo.getGoals(userId);
  final completedGoals = goals.where((g) => g.status.name == 'completed').length;
  if (completedGoals < 5) return false;

  final habits = await habitRepo.getHabits(userId);
  if (habits.isEmpty) return false;

  int maxStreak = 0;
  for (final habit in habits) {
    final streak = await habitRepo.getCurrentStreak(habit.id);
    if (streak > maxStreak) maxStreak = streak;
  }
  if (maxStreak < 30) return false;

  final badges = await achievementRepo.getUnlockedBadges(userId);
  if (badges.length < 3) return false;

  return true;
});
