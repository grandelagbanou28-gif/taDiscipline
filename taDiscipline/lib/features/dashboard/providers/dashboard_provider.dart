import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:apex/data/repositories/goal_repository.dart';
import 'package:apex/data/repositories/habit_repository.dart';
import 'package:apex/data/repositories/pomodoro_repository.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/data/models/goal.dart';
import 'package:apex/features/auth/providers/auth_provider.dart';

part 'dashboard_provider.g.dart';

class DashboardData {
  final int disciplineScore;
  final int streak;
  final String quote;
  final List<Goal> recentGoals;
  final List<Map<String, dynamic>> todayHabits;
  final DateTime? nextDeadline;

  const DashboardData({
    required this.disciplineScore,
    required this.streak,
    required this.quote,
    required this.recentGoals,
    required this.todayHabits,
    this.nextDeadline,
  });
}

@riverpod
class Dashboard extends _$Dashboard {
  @override
  Future<DashboardData> build() async {
    final userId = AppSession.userId;
    if (userId == null) {
      return const DashboardData(
        disciplineScore: 0,
        streak: 0,
        quote: 'Bienvenue sur Apex !',
        recentGoals: [],
        todayHabits: [],
      );
    }
    return _loadData(userId);
  }

  Future<DashboardData> _loadData(String userId) async {
    try {
      final goalRepo = GoalRepository();
      final habitRepo = HabitRepository();
      final pomodoroRepo = PomodoroRepository();

      final goals = await goalRepo.getGoals(userId);
      final habits = await habitRepo.getHabits(userId);
      final pomodorosToday = await pomodoroRepo.getTotalMinutesToday(userId);

      final activeGoals = goals
          .where((g) => g.status.name != 'completed' && g.status.name != 'abandoned')
          .toList();

      final orderedGoals = activeGoals
        ..sort((a, b) => (a.deadline ?? DateTime(2100))
            .compareTo(b.deadline ?? DateTime(2100)));

      final nextDeadline = orderedGoals
          .where((g) => g.deadline != null && g.deadline!.isAfter(DateTime.now()))
          .map((g) => g.deadline!)
          .fold<DateTime?>(null, (prev, d) =>
              prev == null || d.isBefore(prev) ? d : prev);

      final todayHabits = habits.map((h) => {
            'name': h.name,
            'status': 'À faire',
          }).toList();

      final pomodoroScore = (pomodorosToday / 120).clamp(0.0, 1.0);
      final goalsScore = activeGoals.isEmpty
          ? 0.5
          : activeGoals.fold(0.0, (sum, g) => sum + g.progress / 100) /
              activeGoals.length;
      final habitsScore = habits.isEmpty
          ? 0.5
          : habits.length / (habits.length + 1);
      final disciplineScore =
          ((pomodoroScore * 0.3 + goalsScore * 0.4 + habitsScore * 0.3) * 100)
              .round();

      final streak = await _calculateStreak(userId, habitRepo);

      return DashboardData(
        disciplineScore: disciplineScore.clamp(0, 100),
        streak: streak,
        quote: _getDailyQuote(),
        recentGoals: orderedGoals.take(3).toList(),
        todayHabits: todayHabits,
        nextDeadline: nextDeadline,
      );
    } catch (e, st) {
      debugPrint('Erreur chargement dashboard: $e\n$st');
      rethrow;
    }
  }

  Future<int> _calculateStreak(String userId, HabitRepository habitRepo) async {
    final habits = await habitRepo.getHabits(userId);
    if (habits.isEmpty) return 0;

    // Batch load tous les logs des 90 derniers jours en UNE seule requête par habitude
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    final allLogs = <String, Set<String>>{};
    for (final habit in habits) {
      final logs = await habitRepo.getHabitLogs(
        habit.id,
        from: thirtyDaysAgo,
      );
      allLogs[habit.id] = logs
          .where((l) => l.completed)
          .map((l) => '${l.date.year}-${l.date.month}-${l.date.day}')
          .toSet();
    }

    var streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 90; i++) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month}-${date.day}';
      var allDone = true;
      for (final habit in habits) {
        if (!allLogs[habit.id]!.contains(dateKey)) {
          allDone = false;
          break;
        }
      }
      if (allDone) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _getDailyQuote() {
    final quotes = [
      'La discipline est le pont entre les objectifs et leurs accomplissements.',
      'Le succès est la somme de petits efforts répétés jour après jour.',
      'Ne compte pas les jours, fais en sorte que les jours comptent.',
      'Le moment idéal pour commencer, c\'est maintenant.',
      'La motivation vous fait démarrer, la discipline vous fait continuer.',
      'Petits pas, grandes victoires.',
      'Tu es plus fort que tes excuses.',
      'Chaque jour est une nouvelle chance de changer ta vie.',
    ];
    final day = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    return quotes[day % quotes.length];
  }
}
