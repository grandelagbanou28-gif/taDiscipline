import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/shared/widgets/habit_grid.dart';
import 'package:apex/features/habits/providers/habit_provider.dart';
import 'package:apex/data/models/habit.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitudes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/habits/create'),
          ),
        ],
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔄', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune habitude suivie',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajoute une habitude à tracer',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/habits/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une habitude'),
                  ),
                ],
              ),
            );
          }

          final total = habits.length;
          final daily = habits.where((h) => h.frequency.name == 'daily').length;

          return RefreshIndicator(
            onRefresh: () => ref.refresh(habitListProvider.future),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _SummaryRow(total: total, daily: daily)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final habit = habits[index];
                        return _HabitCard(habit: habit);
                      },
                      childCount: habits.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int total;
  final int daily;
  const _SummaryRow({required this.total, required this.daily});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _MiniStat(label: 'Total', value: '$total', color: AppColors.textPrimary),
          const SizedBox(width: 12),
          _MiniStat(label: 'Quotidiennes', value: '$daily', color: AppColors.primaryLight),
          const SizedBox(width: 12),
          _MiniStat(label: 'Aujourd\'hui', value: '✓', color: AppColors.success),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends ConsumerWidget {
  final Habit habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(habitLogsProvider(habit.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (habit.color != null
                            ? Color(int.parse(habit.color!.replaceFirst('#', '0xFF')))
                            : AppColors.primary)
                        .withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      habit.icon ?? '⭐',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        habit.frequency.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStreakBadge(ref),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: AppColors.textMuted),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('Supprimer', style: TextStyle(color: AppColors.textPrimary)),
                        content: Text('Supprimer « ${habit.name} » ?', style: const TextStyle(color: AppColors.textSecondary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(habitListProvider.notifier).deleteHabit(habit.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Supprimer', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            logsAsync.when(
              loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const SizedBox.shrink(),
              data: (logs) {
                final now = DateTime.now();
                final dates = List.generate(
                  70,
                  (i) => DateTime(now.year, now.month, now.day)
                      .subtract(Duration(days: 69 - i)),
                );
                final completed = {
                  for (final log in logs)
                    if (log.completed)
                      DateTime(log.date.year, log.date.month, log.date.day): true,
                };

                final today = DateTime(now.year, now.month, now.day);
                final doneToday = completed[today] ?? false;

                return Column(
                  children: [
                    HabitGrid(
                      dates: dates,
                      completed: completed,
                      activeColor: AppColors.success,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: doneToday
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: TextButton.icon(
                          onPressed: () async {
                            final now = DateTime.now();
                            final log = HabitLog(
                              id: const Uuid().v4(),
                              habitId: habit.id,
                              date: now,
                              completed: !doneToday,
                            );
                            await ref.read(habitLogsProvider(habit.id).notifier).log(log);
                            ref.invalidate(habitLogsProvider(habit.id));
                          },
                          icon: Icon(
                            doneToday ? Icons.check_circle : Icons.check_circle_outline,
                            color: doneToday ? AppColors.success : AppColors.textMuted,
                          ),
                          label: Text(
                            doneToday ? 'Fait aujourd\'hui ✓' : 'Marquer fait aujourd\'hui',
                            style: TextStyle(
                              fontSize: 13,
                              color: doneToday ? AppColors.success : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBadge(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primary.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '0',
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
