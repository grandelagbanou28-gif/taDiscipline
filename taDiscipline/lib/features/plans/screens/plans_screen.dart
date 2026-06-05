import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/core/utils/date_utils.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/data/repositories/plan_repository.dart';
import 'package:ta_discipline/data/models/plan.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';
import 'package:uuid/uuid.dart';

final plansProvider = FutureProvider.family<List<Plan>, DateTime>((ref, date) {
  final userId = AppSupabase.currentUser?.id;
  if (userId == null) return Future.value([]);
  final weekStart = DateFormats.startOfWeek(date);
  final weekEnd = DateFormats.endOfWeek(date);
  return PlanRepository().getPlans(userId, from: weekStart, to: weekEnd);
});

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  DateTime _currentWeekStart = DateFormats.startOfWeek(DateTime.now());
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  Future<void> _addTask(DateTime day) async {
    final planRepo = PlanRepository();
    final userId = AppSupabase.currentUser!.id;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tâche pour le ${day.day}/${day.month}'),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Que dois-tu faire ?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_taskController.text.trim().isEmpty) return;
              final existing = await planRepo.getPlanByDate(userId, day);
              final tasks = [
                ...existing.tasks,
                PlanTask(
                  id: const Uuid().v4(),
                  title: _taskController.text.trim(),
                  order: existing.tasks.length,
                ),
              ];
              await planRepo.savePlan(existing.copyWith(tasks: tasks));
              _taskController.clear();
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(plansProvider(_currentWeekStart));
    final weekDays = List.generate(
      7,
      (i) => _currentWeekStart.add(Duration(days: i)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Planification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: AppColors.textMuted),
                      onPressed: _previousWeek,
                    ),
                    Text(
                      DateFormats.monthYear.format(_currentWeekStart),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right,
                          color: AppColors.textMuted),
                      onPressed: _nextWeek,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDays.map((day) {
                    final isToday = DateFormats.isToday(day);
                    return GestureDetector(
                      onTap: () => _addTask(day),
                      child: Column(
                        children: [
                          Text(
                            DateFormats.weekDay
                                .format(day)
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isToday
                                  ? AppColors.primaryLight
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isToday
                                  ? AppColors.primary
                                  : Colors.transparent,
                              border: isToday
                                  ? null
                                  : Border.all(
                                      color: AppColors.glassBorder),
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isToday
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          plansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
            data: (plans) {
              final allTasks = <PlanTask>[];
              for (final plan in plans) {
                allTasks.addAll(plan.tasks);
              }
              allTasks.sort((a, b) => a.order.compareTo(b.order));

              if (allTasks.isEmpty) {
                return const GlassCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aucune tâche cette semaine.\nTape sur un jour pour en ajouter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: allTasks.map((task) => _TaskBlock(
                  title: task.title,
                  completed: task.completed,
                  onToggle: () async {
                    final day = task.startTime ?? _currentWeekStart;
                    final existing = await PlanRepository().getPlanByDate(
                      AppSupabase.currentUser!.id,
                      day,
                    );
                    final updated = existing.copyWith(
                      tasks: existing.tasks.map((t) {
                        return t.id == task.id
                            ? t.copyWith(completed: !t.completed)
                            : t;
                      }).toList(),
                    );
                    await PlanRepository().savePlan(updated);
                    setState(() {});
                  },
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _TaskBlock extends StatelessWidget {
  final String title;
  final bool completed;
  final VoidCallback onToggle;

  const _TaskBlock({
    required this.title,
    required this.completed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: onToggle,
        child: Row(
          children: [
            Container(
              width: 3,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: completed ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: completed ? AppColors.success : AppColors.textMuted,
                    width: 2,
                  ),
                  color: completed ? AppColors.success : Colors.transparent,
                ),
                child: completed
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  decoration: completed ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
