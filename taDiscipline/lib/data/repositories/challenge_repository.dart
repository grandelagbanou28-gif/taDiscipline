import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/data/models/challenge.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';
import 'package:uuid/uuid.dart';

class ChallengeRepository {
  final SupabaseClient _client;

  ChallengeRepository() : _client = AppSupabase.client;

  Future<List<Challenge>> getPublicChallenges() async {
    final response = await _client
        .from('challenges')
        .select()
        .eq('is_public', true)
        .eq('status', 'active')
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Challenge>> getMyChallenges(String userId) async {
    final participantChallenges = await _client
        .from('challenge_participants')
        .select('challenge_id')
        .eq('user_id', userId);
    final ids =
        (participantChallenges as List).map((e) => e['challenge_id'] as String).toList();
    if (ids.isEmpty) return [];

    final response = await _client
        .from('challenges')
        .select()
        .inFilter('id', ids)
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Challenge>> getCreatedChallenges(String userId) async {
    final response = await _client
        .from('challenges')
        .select()
        .eq('creator_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Challenge> createChallenge(Challenge challenge) async {
    final response = await _client
        .from('challenges')
        .insert(challenge.toJson())
        .select()
        .single();
    return Challenge.fromJson(response);
  }

  Future<void> joinChallenge(String challengeId, String userId) async {
    await _client.from('challenge_participants').insert({
      'id': const Uuid().v4(),
      'challenge_id': challengeId,
      'user_id': userId,
      'progress': 0.0,
      'joined_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> leaveChallenge(String challengeId, String userId) async {
    await _client
        .from('challenge_participants')
        .delete()
        .eq('challenge_id', challengeId)
        .eq('user_id', userId);
  }

  Future<void> updateProgress(
      String challengeId, String userId, double progress) async {
    await _client
        .from('challenge_participants')
        .update({'progress': progress})
        .eq('challenge_id', challengeId)
        .eq('user_id', userId);
  }

  Future<List<ChallengeParticipant>> getParticipants(
      String challengeId) async {
    final response = await _client
        .from('challenge_participants')
        .select()
        .eq('challenge_id', challengeId)
        .order('progress', ascending: false);
    return (response as List)
        .map(
            (json) => ChallengeParticipant.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<int> getParticipantsCount(String challengeId) async {
    final response = await _client
        .from('challenge_participants')
        .select('id')
        .eq('challenge_id', challengeId);
    return (response as List).length;
  }

  Future<bool> isParticipant(String challengeId, String userId) async {
    final response = await _client
        .from('challenge_participants')
        .select('id')
        .eq('challenge_id', challengeId)
        .eq('user_id', userId)
        .maybeSingle();
    return response != null;
  }

  Future<List<ChallengeMessage>> getMessages(String challengeId,
      {int limit = 50}) async {
    final response = await _client
        .from('challenge_messages')
        .select()
        .eq('challenge_id', challengeId)
        .order('created_at', ascending: true)
        .limit(limit);
    return (response as List)
        .map((json) => ChallengeMessage.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ChallengeMessage> sendMessage(ChallengeMessage message) async {
    final response = await _client
        .from('challenge_messages')
        .insert(message.toJson())
        .select()
        .single();
    return ChallengeMessage.fromJson(response);
  }
}
