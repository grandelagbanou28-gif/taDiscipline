import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/data/models/plan.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

class PlanRepository {
  final SupabaseClient _client;

  PlanRepository() : _client = AppSupabase.client;

  Future<List<Plan>> getPlans(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    var query = _client
        .from('plans')
        .select()
        .eq('user_id', userId);
    if (from != null) query = query.gte('date', from.toIso8601String());
    if (to != null) query = query.lte('date', to.toIso8601String());
    final response = await query.order('date', ascending: false);
    return (response as List)
        .map((json) => Plan.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Plan> getPlanByDate(String userId, DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await _client
        .from('plans')
        .select()
        .eq('user_id', userId)
        .eq('date', dateStr)
        .maybeSingle();
    if (response == null) {
      return Plan(
        id: '',
        userId: userId,
        date: date,
        createdAt: DateTime.now(),
      );
    }
    return Plan.fromJson(response);
  }

  Future<Plan> savePlan(Plan plan) async {
    final response = await _client
        .from('plans')
        .upsert(plan.toJson(), onConflict: 'user_id,date')
        .select()
        .single();
    return Plan.fromJson(response);
  }

  Future<void> deletePlan(String planId) async {
    await _client.from('plans').delete().eq('id', planId);
  }
}
