import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/core/constants/goal_categories.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/shared/widgets/app_text_field.dart';
import 'package:apex/features/habits/providers/habit_provider.dart';
import 'package:apex/data/models/habit.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:uuid/uuid.dart';

class HabitCreateScreen extends ConsumerStatefulWidget {
  const HabitCreateScreen({super.key});

  @override
  ConsumerState<HabitCreateScreen> createState() => _HabitCreateScreenState();
}

class _HabitCreateScreenState extends ConsumerState<HabitCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  HabitFrequency _frequency = HabitFrequency.daily;
  int _target = 1;
  bool _isPositive = true;
  String _selectedColor = '#7C3AED';
  String _selectedIcon = '⭐';
  int _cycleInterval = 2;
  String _cycleUnit = 'day';
  bool _isLoading = false;

  final _icons = ['⭐', '💪', '📚', '🧘', '🏃', '🎯', '🎨', '🧠', '💧', '🥗'];
  final _colors = [
    '#7C3AED', '#F59E0B', '#10B981', '#06B6D4',
    '#D946EF', '#3B82F6', '#EF4444', '#84CC16',
  ];
  final _cycleUnits = [
    ('day', 'jours'),
    ('week', 'semaines'),
    ('month', 'mois'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userId = AppSession.userId!;
      final habit = Habit(
        id: const Uuid().v4(),
        userId: userId,
        name: _nameController.text.trim(),
        frequency: _frequency,
        target: _target,
        color: _selectedColor,
        icon: _selectedIcon,
        isPositive: _isPositive,
        cycleInterval: _frequency == HabitFrequency.custom ? _cycleInterval : 1,
        cycleUnit: _frequency == HabitFrequency.custom ? _cycleUnit : 'day',
        createdAt: DateTime.now(),
      );
      await ref.read(habitListProvider.notifier).createHabit(habit);
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
      appBar: AppBar(title: const Text('Nouvelle habitude')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Nom de l\'habitude',
                hint: 'Ex: Méditer 10 minutes',
                controller: _nameController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nom requis';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Type',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPositive = true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _isPositive
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.surface,
                          border: Border.all(
                            color: _isPositive
                                ? AppColors.success
                                : AppColors.glassBorder,
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.add_circle, color: AppColors.success),
                            SizedBox(height: 4),
                            Text('Positive', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPositive = false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: !_isPositive
                              ? AppColors.error.withValues(alpha: 0.15)
                              : AppColors.surface,
                          border: Border.all(
                            color: !_isPositive
                                ? AppColors.error
                                : AppColors.glassBorder,
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.remove_circle, color: AppColors.error),
                            SizedBox(height: 4),
                            Text('À éliminer', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Fréquence',
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
                children: HabitFrequency.values.map((f) {
                  final selected = _frequency == f;
                  return GestureDetector(
                    onTap: () => setState(() => _frequency = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
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
                        f.label,
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
              if (_frequency == HabitFrequency.custom) ...[
                const SizedBox(height: 20),
                const Text(
                  'Cycle personnalisé',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: _cycleInterval.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.glassBorder,
                            ),
                          ),
                        ),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null && parsed > 0) {
                            setState(() => _cycleInterval = parsed);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _cycleUnit,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            items: _cycleUnits.map((u) {
                              return DropdownMenuItem(
                                value: u.$1,
                                child: Text(
                                  'Tous les $_cycleInterval ${u.$2}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _cycleUnit = v);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Icône',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _icons.map((icon) {
                  final selected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.surface,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Couleur',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((c) {
                  final selected = _selectedColor == c;
                  final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(
                          color: selected ? AppColors.textPrimary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              GlassButton(
                label: 'Créer l\'habitude',
                onPressed: _create,
                isLoading: _isLoading,
                icon: Icons.repeat,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
