import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';
import 'package:ta_discipline/data/models/journal_entry.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

class AchievementRepository {
  final SupabaseClient _client;

  AchievementRepository() : _client = AppSupabase.client;

  Future<List<Achievement>> getAchievements(String userId) async {
    final response = await _client
        .from('achievements')
        .select()
        .eq('user_id', userId)
        .order('unlocked_at', ascending: false);
    return (response as List)
        .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> unlockAchievement(String userId, BadgeType badge) async {
    await _client.from('achievements').insert({
      'user_id': userId,
      'badge_id': badge.name,
    });
  }

  Future<bool> hasAchievement(String userId, BadgeType badge) async {
    final response = await _client
        .from('achievements')
        .select('id')
        .eq('user_id', userId)
        .eq('badge_id', badge.name)
        .maybeSingle();
    return response != null;
  }

  Future<Set<BadgeType>> getUnlockedBadges(String userId) async {
    final achievements = await getAchievements(userId);
    return achievements.map((a) => a.badge).toSet();
  }
}
