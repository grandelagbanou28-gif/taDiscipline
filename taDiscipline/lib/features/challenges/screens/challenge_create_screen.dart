import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/data/models/challenge.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/features/challenges/providers/challenge_provider.dart';
import 'package:apex/shared/widgets/app_text_field.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:uuid/uuid.dart';

class ChallengeCreateScreen extends ConsumerStatefulWidget {
  const ChallengeCreateScreen({super.key});

  @override
  ConsumerState<ChallengeCreateScreen> createState() =>
      _ChallengeCreateScreenState();
}

class _ChallengeCreateScreenState
    extends ConsumerState<ChallengeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'fitness';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _goalType = 'sessions';
  int _goalTarget = 10;
  bool _isPublic = true;
  bool _isLoading = false;

  final _categories = [
    ('fitness', '🏋️ Sport'),
    ('learning', '📚 Apprentissage'),
    ('health', '🏥 Santé'),
    ('creativity', '🎨 Créativité'),
    ('finance', '💰 Finances'),
    ('career', '💼 Carrière'),
    ('spirituality', '🧘 Spiritualité'),
    ('other', '📌 Autre'),
  ];

  final _goalTypes = [
    ('sessions', 'Séances'),
    ('streak', 'Jours consécutifs'),
    ('minutes', 'Minutes'),
    ('distance', 'Distance (km)'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userId = AppSession.userId!;
      final challenge = Challenge(
        id: const Uuid().v4(),
        creatorId: userId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        startDate: _startDate,
        endDate: _endDate,
        goalType: _goalType,
        goalTarget: _goalTarget,
        isPublic: _isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(challengeProvider.notifier).createChallenge(challenge);
      if (mounted) context.pop();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un défi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Titre du défi',
                hint: 'Ex: 30 jours de méditation',
                controller: _titleController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Titre requis';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Description (optionnelle)',
                hint: 'Explique le défi et ses règles...',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              const Text(
                'Catégorie',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _category == cat.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.surface,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        cat.$2,
                        style: TextStyle(
                          fontSize: 13,
                          color: selected
                              ? AppColors.primaryLight
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Date de début',
                      date: _startDate,
                      onPicked: (d) => setState(() => _startDate = d),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Date de fin',
                      date: _endDate,
                      onPicked: (d) => setState(() => _endDate = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Type d'objectif",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _goalTypes.map((gt) {
                  final selected = _goalType == gt.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _goalType = gt.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.surface,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        gt.$2,
                        style: TextStyle(
                          fontSize: 13,
                          color: selected
                              ? AppColors.primaryLight
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Objectif à atteindre',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove,
                          color: AppColors.primaryLight),
                      onPressed: _goalTarget > 1
                          ? () => setState(() => _goalTarget--)
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        '$_goalTarget',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add,
                          color: AppColors.primaryLight),
                      onPressed: () => setState(() => _goalTarget++),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Défi public',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isPublic,
                    onChanged: (v) => setState(() => _isPublic = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              GlassButton(
                label: 'Créer le défi',
                onPressed: _create,
                isLoading: _isLoading,
                icon: Icons.emoji_events,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPicked;

  const _DateField({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.surface,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.surface,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Center(
              child: Text(
                '${date.day}/${date.month}/${date.year}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
