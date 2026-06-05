import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';
import 'package:ta_discipline/core/utils/date_utils.dart';
import 'package:ta_discipline/core/utils/encryption.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/data/repositories/journal_repository.dart';
import 'package:ta_discipline/data/models/journal_entry.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final journalProvider =
    FutureProvider.family<JournalEntry?, DateTime>((ref, date) {
  final userId = AppSupabase.currentUser?.id;
  if (userId == null) return Future.value(null);
  return JournalRepository().getEntryByDate(userId, date);
});

final moodHistoryProvider =
    FutureProvider.family<Map<DateTime, Mood>, int>((ref, days) {
  final userId = AppSupabase.currentUser?.id;
  if (userId == null) return Future.value({});
  return JournalRepository().getMoodHistory(userId, days);
});

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _morningController = TextEditingController();
  final _eveningController = TextEditingController();
  Mood _selectedMood = Mood.neutral;
  JournalType _journalType = JournalType.morning;
  bool _isLoading = false;
  bool _editing = false;

  static const _encryptionKey = 'taDiscipline-journal-key-2026';

  @override
  void initState() {
    super.initState();
    _loadTodayEntry();
  }

  @override
  void dispose() {
    _morningController.dispose();
    _eveningController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayEntry() async {
    final userId = AppSupabase.currentUser?.id;
    if (userId == null) return;

    final repo = JournalRepository();
    final morning = await repo.getEntryByDate(
      userId,
      DateTime.now(),
    );
    if (morning != null && mounted) {
      try {
        final decrypted = await EncryptionService.decryptText(
          encryptedBase64: morning.contentEncrypted,
          secretKey: _encryptionKey,
        );
        _morningController.text = decrypted;
        _selectedMood = morning.mood;
        _journalType = morning.type;
        _editing = true;
      } catch (_) {
        // Contenu non déchiffrable, on commence un nouveau journal
      }
    }
  }

  Future<void> _saveEntry() async {
    final userId = AppSupabase.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final content = _journalType == JournalType.morning
          ? _morningController.text
          : _eveningController.text;

      final encrypted = await EncryptionService.encryptText(
        plainText: content,
        secretKey: _encryptionKey,
      );

      final entry = JournalEntry(
        id: const Uuid().v4(),
        userId: userId,
        date: DateTime.now(),
        contentEncrypted: encrypted,
        mood: _selectedMood,
        type: _journalType,
        createdAt: DateTime.now(),
      );

      await JournalRepository().createEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal enregistré ✨'),
            backgroundColor: AppColors.success,
          ),
        );
        _morningController.clear();
        _eveningController.clear();
        setState(() {
          _editing = true;
          _journalType = _journalType == JournalType.morning
              ? JournalType.evening
              : JournalType.morning;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final entryAsync = ref.watch(journalProvider(today));
    final moodAsync = ref.watch(moodHistoryProvider(30));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: Icon(
              _journalType == JournalType.morning
                  ? Icons.wb_sunny
                  : Icons.nights_stay,
            ),
            onPressed: () {
              setState(() {
                _journalType = _journalType == JournalType.morning
                    ? JournalType.evening
                    : JournalType.morning;
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sélecteur matin/soir
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _journalType = JournalType.morning),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _journalType == JournalType.morning
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.surface,
                      border: Border.all(
                        color: _journalType == JournalType.morning
                            ? AppColors.accent
                            : AppColors.glassBorder,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.wb_sunny, color: AppColors.accent),
                        SizedBox(height: 4),
                        Text('Matin',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _journalType = JournalType.evening),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _journalType == JournalType.evening
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      border: Border.all(
                        color: _journalType == JournalType.evening
                            ? AppColors.primary
                            : AppColors.glassBorder,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.nights_stay, color: AppColors.primary),
                        SizedBox(height: 4),
                        Text('Soir',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Titre
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _journalType == JournalType.morning
                          ? Icons.wb_sunny
                          : Icons.nights_stay,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_journalType.label} — ${DateFormats.fullDate.format(today)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _journalType == JournalType.morning
                      ? _morningController
                      : _eveningController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: _journalType == JournalType.morning
                        ? 'Quelle est mon intention pour aujourd\'hui ?\nSur quoi vais-je me concentrer ?'
                        : 'Pourquoi suis-je reconnaissant aujourd\'hui ?\nQu\'ai-je appris ?',
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mood tracker
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comment te sens-tu ?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: Mood.values.map((mood) {
                    final selected = _selectedMood == mood;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = mood),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(mood.emoji,
                                style: const TextStyle(fontSize: 28)),
                            Text(
                              mood.label,
                              style: TextStyle(
                                fontSize: 9,
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bouton enregistrer
          GlassButton(
            label: _editing ? 'Modifier l\'entrée' : 'Enregistrer',
            onPressed: _saveEntry,
            isLoading: _isLoading,
            icon: Icons.save,
          ),
          const SizedBox(height: 24),

          // Historique d'humeur
          const Text(
            'Humeur — 30 derniers jours',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          moodAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (moods) {
              if (moods.isEmpty) {
                return const Text(
                  'Pas encore de données d\'humeur.',
                  style: TextStyle(color: AppColors.textMuted),
                );
              }
              return GlassCard(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(30, (i) {
                    final date = DateTime.now()
                        .subtract(Duration(days: 29 - i));
                    final dayKey = DateTime(date.year, date.month, date.day);
                    final mood = moods[dayKey];
                    return Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: mood != null
                            ? _moodColor(mood)
                            : AppColors.surface,
                      ),
                      child: Center(
                        child: Text(
                          mood?.emoji ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Color _moodColor(Mood mood) {
    switch (mood) {
      case Mood.amazing:
        return AppColors.success.withValues(alpha: 0.3);
      case Mood.good:
        return AppColors.success.withValues(alpha: 0.15);
      case Mood.neutral:
        return AppColors.textMuted.withValues(alpha: 0.15);
      case Mood.low:
        return AppColors.warning.withValues(alpha: 0.2);
      case Mood.terrible:
        return AppColors.error.withValues(alpha: 0.2);
    }
  }
}
