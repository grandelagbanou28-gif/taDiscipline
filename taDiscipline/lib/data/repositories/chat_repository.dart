import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/core/constants/app_constants.dart';
import 'package:ta_discipline/data/models/journal_entry.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

class ChatRepository {
  final SupabaseClient _client;

  ChatRepository() : _client = AppSupabase.client;

  Future<List<ChatMessage>> getMessages(
    String userId, {
    int limit = 50,
  }) async {
    final response = await _client
        .from('chat_messages')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true)
        .limit(limit);
    return (response as List)
        .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> saveMessage(ChatMessage message) async {
    final response = await _client
        .from('chat_messages')
        .insert(message.toJson())
        .select()
        .single();
    return ChatMessage.fromJson(response);
  }

  Future<String> sendToDelAide({
    required String userId,
    required String message,
    required List<ChatMessage> history,
    required Map<String, dynamic> userContext,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.delaideApiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
        },
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'history': history
              .map((m) => {'role': m.role, 'content': m.content})
              .toList(),
          'user_context': userContext,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['response'] as String? ?? '';
      }
      return 'Désolé, je rencontre des difficultés. Réessaie dans un instant.';
    } catch (e) {
      return 'Oups ! Je n\'arrive pas à me connecter. Vérifie ta connexion et réessaie.';
    }
  }
}
