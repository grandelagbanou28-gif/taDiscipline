import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/shared/widgets/confetti_overlay.dart';
import 'package:apex/features/goals/providers/goal_provider.dart';
import 'package:apex/data/models/goal.dart';
import 'package:uuid/uuid.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);
    final tasksAsync = ref.watch(subTaskListProvider(goalId));

    return goalsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
      data: (goals) {
        final goal = goals.where((g) => g.id == goalId).firstOrNull;
        if (goal == null) {
          return const Scaffold(
            body: Center(child: Text('Objectif introuvable')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(goal.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await ref
                      .read(goalListProvider.notifier)
                      .deleteGoal(goalId);
                  if (context.mounted) context.pop();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: goal.progress / 100,
                              strokeWidth: 8,
                              backgroundColor: AppColors.glassBorder,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                            Text(
                              '${goal.progress.toInt()}%',
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (goal.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            goal.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _InfoChip(
                            icon: Icons.category_outlined,
                            label: goal.category.label,
                          ),
                          if (goal.deadline != null)
                            _InfoChip(
                              icon: Icons.calendar_today,
                              label:
                                  '${goal.deadline!.day}/${goal.deadline!.month}',
                            ),
                          _InfoChip(
                            icon: Icons.flag_outlined,
                            label: goal.status.label,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sous-tâches',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primaryLight,
                      onPressed: () => _addTask(context, ref, goalId),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                tasksAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Erreur: $e'),
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return const GlassCard(
                        child: Center(
                          child: Text(
                            'Aucune sous-tâche. Ajoutes-en une !',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: tasks.map((task) => _TaskItem(
                        task: task,
                        onToggle: () => ref
                            .read(subTaskListProvider(goalId).notifier)
                            .toggleTask(task),
                        onDelete: () => ref
                            .read(subTaskListProvider(goalId).notifier)
                            .deleteTask(task.id),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addTask(BuildContext context, WidgetRef ref, String goalId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle sous-tâche'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ex: Rechercher un plan d\'entraînement',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(subTaskListProvider(goalId).notifier).addTask(
                      SubTask(
                        id: const Uuid().v4(),
                        goalId: goalId,
                        title: controller.text.trim(),
                        order: 0,
                      ),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final SubTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.completed ? AppColors.success : AppColors.textMuted,
                    width: 2,
                  ),
                  color: task.completed
                      ? AppColors.success
                      : Colors.transparent,
                ),
                child: task.completed
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  decoration: task.completed
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: AppColors.textMuted,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
