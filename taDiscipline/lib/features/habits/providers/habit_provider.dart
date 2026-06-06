import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:apex/data/repositories/habit_repository.dart';
import 'package:apex/data/models/habit.dart';
import 'package:apex/data/local/app_session.dart';

part 'habit_provider.g.dart';

@riverpod
class HabitList extends _$HabitList {
  @override
  Future<List<Habit>> build() async {
    final userId = AppSession.userId;
    if (userId == null) return [];
    return HabitRepository().getHabits(userId);
  }

  Future<void> createHabit(Habit habit) async {
    final repo = HabitRepository();
    final created = await repo.createHabit(habit);
    state = AsyncValue.data([...state.valueOrNull ?? [], created]);
  }

  Future<void> deleteHabit(String habitId) async {
    await HabitRepository().deleteHabit(habitId);
    final habits = state.valueOrNull ?? [];
    state = AsyncValue.data(habits.where((h) => h.id != habitId).toList());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await build());
  }
}

@riverpod
class HabitLogs extends _$HabitLogs {
  @override
  Future<List<HabitLog>> build(String habitId) async {
    return HabitRepository().getHabitLogs(habitId);
  }

  Future<void> log(HabitLog log) async {
    final repo = HabitRepository();
    await repo.logHabit(log);
    state = AsyncValue.data(
      [log, ...state.valueOrNull ?? []],
    );
  }
}
