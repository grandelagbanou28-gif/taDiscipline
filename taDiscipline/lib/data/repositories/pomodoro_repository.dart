import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/data/models/journal_entry.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

class PomodoroRepository {
  final SupabaseClient _client;

  PomodoroRepository() : _client = AppSupabase.client;

  Future<List<PomodoroSession>> getSessions(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    var query = _client
        .from('pomodoro_sessions')
        .select()
        .eq('user_id', userId);
    if (from != null) query = query.gte('created_at', from.toIso8601String());
    if (to != null) {
      query = query.lte(
        'created_at',
        DateTime(to.year, to.month, to.day, 23, 59, 59).toIso8601String(),
      );
    }
    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map((json) => PomodoroSession.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PomodoroSession> createSession(PomodoroSession session) async {
    final response = await _client
        .from('pomodoro_sessions')
        .insert(session.toJson())
        .select()
        .single();
    return PomodoroSession.fromJson(response);
  }

  Future<PomodoroSession> completeSession(String sessionId) async {
    final response = await _client
        .from('pomodoro_sessions')
        .update({'completed_at': DateTime.now().toIso8601String()})
        .eq('id', sessionId)
        .select()
        .single();
    return PomodoroSession.fromJson(response);
  }

  Future<int> getTodaySessionsCount(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    final response = await _client
        .from('pomodoro_sessions')
        .select('id')
        .eq('user_id', userId)
        .gte('created_at', startOfDay.toIso8601String())
        .lte('created_at', endOfDay.toIso8601String())
        .not('completed_at', 'is', null);
    return (response as List).length;
  }

  Future<int> getTotalMinutesToday(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    final response = await _client
        .from('pomodoro_sessions')
        .select('duration')
        .eq('user_id', userId)
        .gte('created_at', startOfDay.toIso8601String())
        .lte('created_at', endOfDay.toIso8601String())
        .not('completed_at', 'is', null);
    final sessions = response as List;
    return sessions.fold<int>(0, (sum, s) => sum + ((s['duration'] as num?)?.toInt() ?? 0));
  }
}
