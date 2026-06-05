import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/data/models/habit.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

class HabitRepository {
  final SupabaseClient _client;

  HabitRepository() : _client = AppSupabase.client;

  Future<List<Habit>> getHabits(String userId) async {
    final response = await _client
        .from('habits')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => Habit.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Habit> createHabit(Habit habit) async {
    final response = await _client
        .from('habits')
        .insert(habit.toJson())
        .select()
        .single();
    return Habit.fromJson(response);
  }

  Future<Habit> updateHabit(Habit habit) async {
    final response = await _client
        .from('habits')
        .update(habit.toJson())
        .eq('id', habit.id)
        .select()
        .single();
    return Habit.fromJson(response);
  }

  Future<void> deleteHabit(String habitId) async {
    await _client.from('habits').delete().eq('id', habitId);
  }

  Future<List<HabitLog>> getHabitLogs(
    String habitId, {
    DateTime? from,
    DateTime? to,
  }) async {
    var query = _client
        .from('habit_logs')
        .select()
        .eq('habit_id', habitId);
    if (from != null) query = query.gte('date', from.toIso8601String());
    if (to != null) query = query.lte('date', to.toIso8601String());
    final response = await query.order('date', ascending: false);
    return (response as List)
        .map((json) => HabitLog.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<HabitLog> logHabit(HabitLog log) async {
    final response = await _client
        .from('habit_logs')
        .upsert(log.toJson(), onConflict: 'habit_id,date')
        .select()
        .single();
    return HabitLog.fromJson(response);
  }

  Future<int> getCurrentStreak(String habitId) async {
    final logs = await getHabitLogs(habitId);
    if (logs.isEmpty) return 0;
    final sorted = logs
        .where((l) => l.completed)
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    if (sorted.isEmpty) return 0;
    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i - 1].difference(sorted[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
