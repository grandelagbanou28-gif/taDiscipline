import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/features/goals/providers/goal_provider.dart';
import 'package:ta_discipline/data/models/goal.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Objectifs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/goals/create'),
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎯',
                    style: TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun objectif pour le moment',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Définis ton premier objectif SMART',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/goals/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un objectif'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(goalListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return _GoalListItem(goal: goal);
              },
            ),
          );
        },
      ),
    );
  }
}

class _GoalListItem extends ConsumerWidget {
  final Goal goal;
  const _GoalListItem({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = goal.category;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => context.push('/goals/${goal.id}'),
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
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      category.emoji,
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
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        category.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _statusColor(goal.status).withValues(alpha: 0.15),
                  ),
                  child: Text(
                    goal.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: _statusColor(goal.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progress / 100,
                backgroundColor: AppColors.glassBorder,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.progress.toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (goal.deadline != null)
                  Text(
                    'Échéance: ${goal.deadline!.day}/${goal.deadline!.month}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.notStarted:
        return AppColors.textMuted;
      case GoalStatus.inProgress:
        return AppColors.primaryLight;
      case GoalStatus.completed:
        return AppColors.success;
      case GoalStatus.abandoned:
        return AppColors.error;
    }
  }
}
