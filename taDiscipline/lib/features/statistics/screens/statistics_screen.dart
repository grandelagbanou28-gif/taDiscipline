import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/core/constants/goal_categories.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/shared/widgets/animated_circular_progress.dart';
import 'package:apex/shared/widgets/activity_grid.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/data/repositories/goal_repository.dart';
import 'package:apex/data/repositories/habit_repository.dart';
import 'package:apex/data/repositories/journal_repository.dart';
import 'package:apex/data/models/goal.dart';
import 'package:apex/data/models/habit.dart';
import 'package:apex/data/models/journal_entry.dart';

final statsDataProvider = FutureProvider<StatsData>((ref) async {
  final userId = AppSession.userId;
  if (userId == null) return StatsData.empty();

  final goalRepo = GoalRepository();
  final habitRepo = HabitRepository();
  final journalRepo = JournalRepository();

  final goals = await goalRepo.getGoals(userId);
  final habits = await habitRepo.getHabits(userId);
  final journalEntries = await journalRepo.getEntries(userId, limit: 200);

  return StatsData._compute(goals, habits, journalEntries, userId);
});

class StatsData {
  final Map<DateTime, int> activityGrid;
  final double overallScore;
  final double productivity;
  final double regularity;
  final List<double> weeklyData;
  final Map<String, double> categoryDistribution;
  final List<bool> habitHeatmap;
  final int completedGoals;
  final int totalGoals;
  final int habitStreak;

  const StatsData({
    required this.activityGrid,
    required this.overallScore,
    required this.productivity,
    required this.regularity,
    required this.weeklyData,
    required this.categoryDistribution,
    required this.habitHeatmap,
    required this.completedGoals,
    required this.totalGoals,
    required this.habitStreak,
  });

  StatsData.empty()
      : activityGrid = <DateTime, int>{},
        overallScore = 0,
        productivity = 0,
        regularity = 0,
        weeklyData = List.filled(7, 0),
        categoryDistribution = <String, double>{},
        habitHeatmap = List.filled(70, false),
        completedGoals = 0,
        totalGoals = 0,
        habitStreak = 0;

  factory StatsData._compute(
    List<Goal> goals,
    List<Habit> habits,
    List<JournalEntry> entries,
    String userId,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final activityGrid = <DateTime, int>{};
    for (int i = 0; i < 90; i++) {
      final date = today.subtract(Duration(days: i));
      activityGrid[date] = 0;
    }

    for (final goal in goals) {
      final d = DateTime(goal.updatedAt.year, goal.updatedAt.month, goal.updatedAt.day);
      activityGrid[d] = (activityGrid[d] ?? 0) + 1;
      if (goal.status == GoalStatus.completed) activityGrid[d] = (activityGrid[d] ?? 0) + 2;
    }

    for (final entry in entries) {
      final d = DateTime(entry.date.year, entry.date.month, entry.date.day);
      activityGrid[d] = (activityGrid[d] ?? 0) + 1;
    }

    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.status == GoalStatus.completed).length;
    final overallScore = totalGoals > 0 ? (completedGoals / totalGoals * 100) : 0.0;

    final totalActive = totalGoals - completedGoals;
    final productivity = totalActive > 0
        ? (goals.fold(0.0, (sum, g) => sum + g.progress) / totalActive)
        : (completedGoals > 0 ? 100.0 : 0);

    final activeDays = activityGrid.values.where((v) => v > 0).length;
    final regularity = 90 > 0 ? (activeDays / 90 * 100) : 0;

    final weeklyData = List.filled(7, 0.0);
    final weeklyCount = List.filled(7, 0);
    for (int i = 0; i < 90; i++) {
      final date = today.subtract(Duration(days: i));
      final weekday = date.weekday - 1;
      if (activityGrid[date] != null) {
        weeklyData[weekday] += (activityGrid[date]! as num).clamp(0, 5).toDouble();
        weeklyCount[weekday]++;
      }
    }
    for (int i = 0; i < 7; i++) {
      if (weeklyCount[i] > 0) {
        weeklyData[i] = (weeklyData[i] / weeklyCount[i]) / 5;
      }
    }

    final categoryDistribution = <String, double>{};
    if (totalGoals > 0) {
      final catCounts = <String, int>{};
      for (final g in goals) {
        catCounts[g.category.label] = (catCounts[g.category.label] ?? 0) + 1;
      }
      for (final entry in catCounts.entries) {
        categoryDistribution[entry.key] = entry.value / totalGoals;
      }
    }

    final heatmapValues = List.filled(70, false);
    if (habits.isNotEmpty) {
      for (int i = 0; i < 70; i++) {
        final date = today.subtract(Duration(days: 69 - i));
        heatmapValues[i] = activityGrid[date] != null && activityGrid[date]! > 0;
      }
    }

    int habitStreak = 0;
    if (habits.isNotEmpty) {
      for (int i = 0; i < 70; i++) {
        if (heatmapValues[i]) habitStreak++;
        else habitStreak = 0;
      }
    }

    return StatsData(
      activityGrid: activityGrid,
      overallScore: overallScore.toDouble(),
      productivity: productivity.clamp(0, 100).toDouble(),
      regularity: regularity.toDouble(),
      weeklyData: weeklyData,
      categoryDistribution: categoryDistribution,
      habitHeatmap: heatmapValues,
      completedGoals: completedGoals,
      totalGoals: totalGoals,
      habitStreak: habitStreak,
    );
  }
}

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activité',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: ActivityGrid(
                  data: stats.activityGrid,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Score',
                      value: stats.overallScore.toInt().toString(),
                      chart: AnimatedCircularProgress(
                        progress: stats.overallScore / 100,
                        size: 70,
                        centerText: stats.overallScore.toInt().toString(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Productivité',
                      value: '${stats.productivity.toInt()}%',
                      icon: Icons.bolt,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Régularité',
                      value: '${stats.regularity.toInt()}%',
                      icon: Icons.repeat,
                      color: AppColors.cyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Progression hebdomadaire',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(height: 220, child: _WeeklyChart(data: stats.weeklyData)),
              const SizedBox(height: 24),
              const Text(
                'Répartition par catégorie',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(height: 220, child: _CategoryPieChart(data: stats.categoryDistribution)),
              const SizedBox(height: 24),
              const Text(
                'Habitudes — Vue d\'ensemble',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(height: 140, child: _HabitHeatmap(data: stats.habitHeatmap)),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<double> data;
  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= days.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    days[idx],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.glassBorder,
              strokeWidth: 0.5,
            ),
          ),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  color: AppColors.primary,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;
  const _CategoryPieChart({required this.data});

  Color _categoryColor(String label) {
    if (label.startsWith('Santé')) return AppColors.success;
    if (label.startsWith('Carrière')) return AppColors.primary;
    if (label.startsWith('Apprentissage')) return AppColors.cyan;
    if (label.startsWith('Finances')) return AppColors.accent;
    if (label.startsWith('Sport')) return Colors.orange;
    if (label.startsWith('Loisir')) return Colors.purple;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final categories = data.entries.toList();
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'Aucun objectif',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    final total = categories.fold(0.0, (s, e) => s + e.value);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: categories.map((c) {
                  return PieChartSectionData(
                    value: (c.value / total * 100).clamp(1, 100),
                    color: _categoryColor(c.key),
                    radius: 30,
                    title: '${(c.value * 100).toInt()}%',
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: categories.map((c) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _categoryColor(c.key),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        c.key,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(c.value * 100).toInt()}%',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitHeatmap extends StatelessWidget {
  final List<bool> data;
  const _HabitHeatmap({required this.data});

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    for (int row = 0; row < 7; row++) {
      for (int col = 0; col < 10; col++) {
        final idx = col * 7 + row;
        final active = idx < data.length ? data[idx] : false;
        cells.add(
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: active
                  ? AppColors.success.withValues(alpha: 0.8)
                  : AppColors.surface,
            ),
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((d) => SizedBox(
                      width: 12,
                      child: Text(d,
                          style: const TextStyle(
                              fontSize: 8, color: AppColors.textMuted)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Wrap(
              direction: Axis.vertical,
              children: cells,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final Widget? chart;

  const _StatCard({
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: chart ?? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
