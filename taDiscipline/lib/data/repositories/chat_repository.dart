import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:apex/core/constants/app_constants.dart';
import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/journal_entry.dart';

class ChatRepository {
  final LocalDatabase _db = LocalDatabase();

  static const String _systemPrompt = '''Tu es Apex IA, l'assistant intelligent tout-en-un de l'application Apex. Tu es propulsé par Grok (xAI).

Personnalité :
- Sympathique, serviable et naturel
- Tutoiement décontracté mais respectueux
- Réponses claires, utiles et précises
- Utilise des emojis avec modération

Capacités :
- Coaching personnalisé selon le profil et l'historique
- Décomposition d'objectifs ambitieux en plans d'action concrets (SMART)
- Feedback quotidien sur la progression
- Suggestions d'habitudes alignées sur les objectifs
- Défis hebdomadaires sur-mesure
- Analyse de tendances et insights

Règles :
- TOUJOURS répondre en français
- Ne jamais donner de conseils médicaux ou psychologiques professionnels
- En cas de détection de crise, recommander de contacter un professionnel
- Privilégier les actions concrètes aux encouragements vagues
- Adapter le ton à l'humeur détectée de l'utilisateur

Outils disponibles :
1. create_goal : Créer un nouvel objectif SMART
2. add_habit : Ajouter une nouvelle habitude
3. schedule_task : Planifier une tâche dans l'agenda
4. log_mood : Enregistrer l'humeur du jour''';

  Future<List<ChatMessage>> getMessages(
    String userId, {
    int limit = 50,
  }) async {
    final rows = await _db.query('chat_messages',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at ASC', limit: limit);
    return rows.map((j) => ChatMessage.fromJson(j)).toList();
  }

  Future<ChatMessage> saveMessage(ChatMessage message) async {
    await _db.insert('chat_messages', message.toJson());
    return message;
  }

  Future<String> sendToApexIA({
    required String userId,
    required String message,
    required List<ChatMessage> history,
    required Map<String, dynamic> userContext,
  }) async {
    try {
      await _db.insert('chat_messages', {
        'user_id': userId,
        'role': 'user',
        'content': message,
        'created_at': DateTime.now().toIso8601String(),
      });

      final grokMessages = [
        {'role': 'system', 'content': _systemPrompt},
        ...history.map((m) => {'role': m.role, 'content': m.content}),
        {'role': 'user', 'content': message},
      ];

      final grokRes = await http.post(
        Uri.parse('https://api.x.ai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.xaiApiKey}',
        },
        body: jsonEncode({
          'model': 'grok-2-latest',
          'messages': grokMessages,
          'temperature': 0.7,
          'max_tokens': 1024,
          'tools': [
            {
              'type': 'function',
              'function': {
                'name': 'create_goal',
                'description': "Créer un nouvel objectif SMART",
                'parameters': {
                  'type': 'object',
                  'properties': {
                    'title': {'type': 'string', 'description': "Titre de l'objectif"},
                    'category': {
                      'type': 'string',
                      'enum': ['career', 'health', 'finance', 'spirituality', 'relationships', 'learning']
                    },
                    'deadline': {'type': 'string', 'description': 'Date limite ISO 8601'},
                  },
                  'required': ['title'],
                },
              },
            },
            {
              'type': 'function',
              'function': {
                'name': 'add_habit',
                'description': 'Ajouter une nouvelle habitude',
                'parameters': {
                  'type': 'object',
                  'properties': {
                    'name': {'type': 'string'},
                    'frequency': {'type': 'string', 'enum': ['daily', 'weekly', 'monthly']},
                    'target': {'type': 'number'},
                  },
                  'required': ['name', 'frequency'],
                },
              },
            },
          ],
        }),
      );

      if (!grokRes.statusCode.toString().startsWith('2')) {
        throw Exception('Grok API error: ${grokRes.statusCode}');
      }

      final grokData = jsonDecode(grokRes.body) as Map<String, dynamic>;
      final assistantMessage = (grokData['choices'] as List?)?.firstOrNull?['message'];
      final content = assistantMessage?['content'] as String? ?? '';
      final toolCalls = assistantMessage?['tool_calls'] as List?;

      if (toolCalls != null && toolCalls.isNotEmpty) {
        for (final call in toolCalls) {
          final args = jsonDecode(call['function']['arguments']) as Map<String, dynamic>;
          await _handleToolCall(userId, call['function']['name'] as String, args);
        }
      }

      await _db.insert('chat_messages', {
        'user_id': userId,
        'role': 'assistant',
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });

      return content;
    } catch (e) {
      return 'Oups ! Je n\'arrive pas à me connecter. Vérifie ta connexion et réessaie.';
    }
  }

  Future<void> _handleToolCall(
    String userId,
    String toolName,
    Map<String, dynamic> args,
  ) async {
    switch (toolName) {
      case 'create_goal':
        await _db.insert('goals', {
          'user_id': userId,
          'title': args['title'],
          'category': args['category'] ?? 'other',
          'deadline': args['deadline'],
          'status': 'notStarted',
          'progress': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        break;
      case 'add_habit':
        await _db.insert('habits', {
          'user_id': userId,
          'name': args['name'],
          'frequency': args['frequency'] ?? 'daily',
          'target': args['target'] ?? 1,
          'created_at': DateTime.now().toIso8601String(),
        });
        break;
      case 'schedule_task':
        final today = DateTime.now().toIso8601String().split('T')[0];
        final rng = Random();
        await _db.insert('plans', {
          'user_id': userId,
          'date': args['date'] ?? today,
          'tasks': jsonEncode([
            {
              'id': rng.nextInt(999999999).toString(),
              'title': args['title'],
              'completed': false,
            }
          ]),
          'type': 'weekly',
          'created_at': DateTime.now().toIso8601String(),
        });
        break;
      case 'log_mood':
        final dateStr = DateTime.now().toIso8601String().split('T')[0];
        await _db.insert('journal_entries', {
          'user_id': userId,
          'date': dateStr,
          'content_encrypted': '',
          'mood': args['mood'],
          'type': 'morning',
          'created_at': DateTime.now().toIso8601String(),
        });
        break;
    }
  }
}
