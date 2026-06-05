import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/shared/widgets/app_text_field.dart';
import 'package:ta_discipline/features/goals/providers/goal_provider.dart';
import 'package:ta_discipline/data/models/goal.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';
import 'package:uuid/uuid.dart';

class GoalCreateScreen extends ConsumerStatefulWidget {
  const GoalCreateScreen({super.key});

  @override
  ConsumerState<GoalCreateScreen> createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends ConsumerState<GoalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  GoalCategory _category = GoalCategory.career;
  DateTime? _deadline;
  bool _isLoading = false;

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
      final userId = AppSupabase.currentUser!.id;
      final goal = Goal(
        id: const Uuid().v4(),
        userId: userId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        deadline: _deadline,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(goalListProvider.notifier).createGoal(goal);
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
      appBar: AppBar(title: const Text('Nouvel objectif SMART')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'S - Spécifique\nM - Mesurable\nA - Atteignable\nR - Réaliste\nT - Temporel',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Titre de l\'objectif',
                hint: 'Ex: Courir un semi-marathon',
                controller: _titleController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Titre requis';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Description (optionnelle)',
                hint: 'Pourquoi cet objectif est important pour toi...',
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
                children: GoalCategory.values.map((cat) {
                  final selected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
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
                        cat.displayName,
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
                'Date d\'échéance (optionnelle)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
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
                  if (date != null) setState(() => _deadline = date);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _deadline != null
                            ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _deadline != null
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GlassButton(
                label: 'Créer l\'objectif',
                onPressed: _create,
                isLoading: _isLoading,
                icon: Icons.flag,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
