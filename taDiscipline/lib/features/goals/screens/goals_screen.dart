import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/core/constants/goal_categories.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/features/goals/providers/goal_provider.dart';
import 'package:apex/data/models/goal.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  GoalStatus? _filter;

  @override
  Widget build(BuildContext context) {
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
                  const Text('🎯', style: TextStyle(fontSize: 64)),
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

          final total = goals.length;
          final inProgress = goals.where((g) => g.status == GoalStatus.inProgress).length;
          final completed = goals.where((g) => g.status == GoalStatus.completed).length;

          final filtered = _filter != null
              ? goals.where((g) => g.status == _filter).toList()
              : goals;

          return RefreshIndicator(
            onRefresh: () => ref.refresh(goalListProvider.future),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _SummaryRow(total: total, inProgress: inProgress, completed: completed)),
                SliverToBoxAdapter(child: _FilterRow(filter: _filter, onChanged: (f) => setState(() => _filter = f))),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final goal = filtered[index];
                        return _GoalListItem(goal: goal);
                      },
                      childCount: filtered.length,
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
  final int inProgress;
  final int completed;
  const _SummaryRow({required this.total, required this.inProgress, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _MiniStat(label: 'Total', value: '$total', color: AppColors.textPrimary),
          const SizedBox(width: 12),
          _MiniStat(label: 'En cours', value: '$inProgress', color: AppColors.primaryLight),
          const SizedBox(width: 12),
          _MiniStat(label: 'Terminé', value: '$completed', color: AppColors.success),
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

class _FilterRow extends StatelessWidget {
  final GoalStatus? filter;
  final ValueChanged<GoalStatus?> onChanged;
  const _FilterRow({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = <GoalStatus?>[null, GoalStatus.inProgress, GoalStatus.completed, GoalStatus.abandoned];
    final labels = <String>['Tous', 'En cours', 'Terminé', 'Abandonné'];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: List.generate(filters.length, (i) {
          final selected = filter == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(filters[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: selected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.glassBorder,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GoalListItem extends ConsumerWidget {
  final Goal goal;
  const _GoalListItem({required this.goal});

  int _daysLeft(DateTime? deadline) {
    if (deadline == null) return -1;
    return deadline.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = goal.category;
    final daysLeft = _daysLeft(goal.deadline);
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _statusColor(goal.status).withValues(alpha: 0.15),
                  ),
                  child: Text(
                    goal.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(goal.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.progress / 100,
                      backgroundColor: AppColors.glassBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goal.status == GoalStatus.completed
                            ? AppColors.success
                            : goal.status == GoalStatus.abandoned
                                ? AppColors.error
                                : AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${goal.progress.toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (daysLeft >= 0)
                  Row(
                    children: [
                      Icon(
                        daysLeft <= 3 ? Icons.warning_amber_rounded : Icons.schedule,
                        size: 14,
                        color: daysLeft <= 3 ? AppColors.error : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        daysLeft == 0
                            ? 'Aujourd\'hui'
                            : daysLeft < 0
                                ? 'Expiré'
                                : '$daysLeft jours',
                        style: TextStyle(
                          fontSize: 12,
                          color: daysLeft <= 3 ? AppColors.error : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                const Spacer(),
                Text(
                  'Créé le ${goal.createdAt.day}/${goal.createdAt.month}',
                  style: const TextStyle(
                    fontSize: 11,
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
