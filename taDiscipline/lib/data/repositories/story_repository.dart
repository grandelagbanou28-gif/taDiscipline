import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/data/models/story.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

class StoryRepository {
  final SupabaseClient _client;

  StoryRepository() : _client = AppSupabase.client;

  Future<List<Story>> getActiveStories(String userId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    try {
      final response = await _client.rpc('get_active_stories', params: {
        'p_user_id': userId,
        'p_now': now,
      });
      return (response as List)
          .map((json) => Story.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final response = await _client
          .from('stories')
          .select()
          .or('user_id.eq.$userId')
          .gte('expires_at', now)
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => Story.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<List<Story>> getStoriesByUser(String userId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final response = await _client
        .from('stories')
        .select()
        .eq('user_id', userId)
        .gte('expires_at', now)
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => Story.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Story> createStory(Story story) async {
    final response = await _client
        .from('stories')
        .insert(story.toJson())
        .select()
        .single();
    return Story.fromJson(response);
  }

  Future<void> deleteStory(String storyId) async {
    await _client.from('stories').delete().eq('id', storyId);
  }

  Future<void> cleanupExpired() async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _client.from('stories').delete().lt('expires_at', now);
  }
}
