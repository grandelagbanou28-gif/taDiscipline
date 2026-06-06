import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:apex/data/repositories/goal_repository.dart';
import 'package:apex/data/models/goal.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:uuid/uuid.dart';

part 'goal_provider.g.dart';

@riverpod
class GoalList extends _$GoalList {
  @override
  Future<List<Goal>> build() async {
    final userId = AppSession.userId;
    if (userId == null) return [];
    return GoalRepository().getGoals(userId);
  }

  Future<void> createGoal(Goal goal) async {
    final repo = GoalRepository();
    final created = await repo.createGoal(goal);
    state = AsyncValue.data([created, ...state.valueOrNull ?? []]);
  }

  Future<void> updateGoal(Goal goal) async {
    final repo = GoalRepository();
    await repo.updateGoal(goal);
    final goals = state.valueOrNull ?? [];
    state = AsyncValue.data(
      goals.map((g) => g.id == goal.id ? goal : g).toList(),
    );
  }

  Future<void> deleteGoal(String goalId) async {
    await GoalRepository().deleteGoal(goalId);
    final goals = state.valueOrNull ?? [];
    state = AsyncValue.data(goals.where((g) => g.id != goalId).toList());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await build());
  }
}

@riverpod
class SubTaskList extends _$SubTaskList {
  @override
  Future<List<SubTask>> build(String goalId) async {
    return GoalRepository().getSubTasks(goalId);
  }

  Future<void> addTask(SubTask task) async {
    final repo = GoalRepository();
    final created = await repo.createSubTask(task);
    state = AsyncValue.data([...state.valueOrNull ?? [], created]);
  }

  Future<void> toggleTask(SubTask task) async {
    final repo = GoalRepository();
    final updated = await repo.updateSubTask(
      task.copyWith(completed: !task.completed),
    );
    final tasks = state.valueOrNull ?? [];
    state = AsyncValue.data(
      tasks.map((t) => t.id == task.id ? updated : t).toList(),
    );
  }

  Future<void> deleteTask(String taskId) async {
    await GoalRepository().deleteSubTask(taskId);
    final tasks = state.valueOrNull ?? [];
    state = AsyncValue.data(tasks.where((t) => t.id != taskId).toList());
  }
}
