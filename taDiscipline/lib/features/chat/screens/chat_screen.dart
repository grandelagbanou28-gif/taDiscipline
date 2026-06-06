import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/data/repositories/chat_repository.dart';
import 'package:apex/data/repositories/goal_repository.dart';
import 'package:apex/data/repositories/habit_repository.dart';
import 'package:apex/data/models/journal_entry.dart';
import 'package:apex/data/local/app_session.dart';

final chatHistoryProvider = FutureProvider<List<ChatMessage>>((ref) {
  final userId = AppSession.userId;
  if (userId == null) return Future.value([]);
  return ChatRepository().getMessages(userId);
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _loadHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(_ChatMessage(
      role: 'assistant',
      content:
          'Salut ! 👋 Je suis **Apex IA**, ton assistant intelligent.\n\n'
          'Je peux répondre à toutes tes questions, t\'aider avec :\n'
          '• Tes objectifs et habitudes 🎯\n'
          '• De la culture, tech, programmation 💻\n'
          '• Du brainstorming et rédaction ✍️\n'
          '• Des conseils et analyses 📊\n\n'
          'De quoi as-tu besoin aujourd\'hui ?',
    ));
  }

  Future<void> _loadHistory() async {
    final userId = AppSession.userId;
    if (userId == null) return;
    try {
      final history = await ChatRepository().getMessages(userId);
      if (mounted && history.isNotEmpty) {
        setState(() {
          _messages.clear();
          _messages.addAll(history.reversed.map((m) => _ChatMessage(
            role: m.role,
            content: m.content,
          )));
          if (!_messages.any((m) => m.role == 'assistant')) {
            _addWelcomeMessage();
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final userId = AppSession.userId;
      if (userId == null) return;

      // Contexte utilisateur pour l'IA
      final goalRepo = GoalRepository();
      final habitRepo = HabitRepository();
      final goals = await goalRepo.getGoals(userId);
      final habits = await habitRepo.getHabits(userId);

      final chatRepo = ChatRepository();

      // Sauvegarder le message utilisateur
      await chatRepo.saveMessage(ChatMessage(
        id: '',
        userId: userId,
        role: 'user',
        content: text,
        createdAt: DateTime.now(),
      ));

      // Appeler Apex IA
      final history = _messages
          .where((m) => m.role != 'system')
          .map((m) => ChatMessage(
                id: '',
                userId: userId,
                role: m.role,
                content: m.content,
                createdAt: DateTime.now(),
              ))
          .toList();

      final response = await chatRepo.sendToApexIA(
        userId: userId,
        message: text,
        history: history,
        userContext: {
          'goals_count': goals.length,
          'goals_in_progress':
              goals.where((g) => g.status.name == 'inProgress').length,
          'habits_count': habits.length,
        },
      );

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(role: 'assistant', content: response));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            role: 'assistant',
            content:
                'Désolé, je rencontre des difficultés. Vérifie ta connexion et réessaie. 🌟',
          ));
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
              ),
              child: const Center(
                child: Text('A',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apex IA',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('En ligne',
                    style: TextStyle(fontSize: 11, color: AppColors.success)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryLight),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Apex IA réfléchit...',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }
                final msg = _messages[index];
                return _MessageBubble(message: msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.glassBorder,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Parle à DelAide...',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  _ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
              ),
              child: const Center(
                child: Text('A',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(isUser ? 18 : 18),
                color: isUser
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surface,
                border: Border.all(
                  color: isUser
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.glassBorder,
                ),
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
