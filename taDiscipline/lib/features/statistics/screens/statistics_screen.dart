import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/shared/widgets/animated_circular_progress.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
            tooltip: 'Exporter PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Score',
                    value: '78',
                    chart: const AnimatedCircularProgress(
                      progress: 0.78,
                      size: 70,
                      centerText: '78',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Productivité',
                    value: '85%',
                    icon: Icons.bolt,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Régularité',
                    value: '72%',
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
            GlassCard(height: 220, child: _WeeklyChart()),
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
            GlassCard(height: 220, child: _CategoryPieChart()),
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
            GlassCard(height: 140, child: _HabitHeatmap()),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final data = [0.3, 0.65, 0.45, 0.8, 0.9, 0.5, 0.7];
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
  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Santé', 0.30, AppColors.success),
      ('Carrière', 0.25, AppColors.primary),
      ('Apprentissage', 0.20, AppColors.cyan),
      ('Finances', 0.15, AppColors.accent),
      ('Autre', 0.10, AppColors.textMuted),
    ];
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
                    value: c.$2 * 100,
                    color: c.$3,
                    radius: 30,
                    title: '${(c.$2 * 100).toInt()}%',
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
                          color: c.$3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        c.$1,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(c.$2 * 100).toInt()}%',
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
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final cells = <Widget>[];
    for (int row = 0; row < 7; row++) {
      for (int col = 0; col < 10; col++) {
        final day = today.subtract(Duration(days: (9 - col) * 7 + (6 - row)));
        final intensity = (day.day % 5) / 5.0;
        cells.add(
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: intensity > 0
                  ? AppColors.success.withValues(alpha: intensity)
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
