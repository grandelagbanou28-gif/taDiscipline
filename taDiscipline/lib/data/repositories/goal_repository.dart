import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/data/models/goal.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

class GoalRepository {
  final SupabaseClient _client;

  GoalRepository() : _client = AppSupabase.client;

  Future<List<Goal>> getGoals(String userId) async {
    final response = await _client
        .from('goals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => Goal.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Goal> getGoal(String goalId) async {
    final response = await _client
        .from('goals')
        .select()
        .eq('id', goalId)
        .single();
    return Goal.fromJson(response);
  }

  Future<Goal> createGoal(Goal goal) async {
    final response = await _client
        .from('goals')
        .insert(goal.toJson())
        .select()
        .single();
    return Goal.fromJson(response);
  }

  Future<Goal> updateGoal(Goal goal) async {
    final response = await _client
        .from('goals')
        .update(goal.toJson())
        .eq('id', goal.id)
        .select()
        .single();
    return Goal.fromJson(response);
  }

  Future<void> deleteGoal(String goalId) async {
    await _client.from('goals').delete().eq('id', goalId);
  }

  Future<List<SubTask>> getSubTasks(String goalId) async {
    final response = await _client
        .from('subtasks')
        .select()
        .eq('goal_id', goalId)
        .order('order', ascending: true);
    return (response as List)
        .map((json) => SubTask.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SubTask> createSubTask(SubTask task) async {
    final response = await _client
        .from('subtasks')
        .insert(task.toJson())
        .select()
        .single();
    return SubTask.fromJson(response);
  }

  Future<SubTask> updateSubTask(SubTask task) async {
    final response = await _client
        .from('subtasks')
        .update(task.toJson())
        .eq('id', task.id)
        .select()
        .single();
    return SubTask.fromJson(response);
  }

  Future<void> deleteSubTask(String taskId) async {
    await _client.from('subtasks').delete().eq('id', taskId);
  }

  Future<int> getGoalsCount(String userId) async {
    final response = await _client
        .from('goals')
        .select('id')
        .eq('user_id', userId);
    return (response as List).length;
  }
}
