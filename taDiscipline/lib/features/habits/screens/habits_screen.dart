import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/shared/widgets/habit_grid.dart';
import 'package:ta_discipline/features/habits/providers/habit_provider.dart';
import 'package:ta_discipline/data/models/habit.dart';
import 'package:ta_discipline/core/utils/date_utils.dart';

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
          return RefreshIndicator(
            onRefresh: () => ref.refresh(habitListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return _HabitCard(habit: habit);
              },
            ),
          );
        },
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
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: AppColors.textMuted),
                  onPressed: () => ref
                      .read(habitListProvider.notifier)
                      .deleteHabit(habit.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            logsAsync.when(
              loading: () => const SizedBox.shrink(),
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
                      DateTime(log.date.year, log.date.month, log.date.day):
                          true,
                };
                return HabitGrid(
                  dates: dates,
                  completed: completed,
                  activeColor: AppColors.success,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
